import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as random from "@pulumi/random";
import * as postgresql from "@pulumi/postgresql";
import { createCoolifyVm } from "./vm";

// Get configuration
const config = new pulumi.Config();
const location = config.get("location") || "westus3";
const projectName = config.get("projectName") || "ameciclo";
const environment = config.get("environment") || "production";

// Entra ID (Azure AD) group granted VM SSH login + Postgres admin access
// (currently "TI Ameciclo", Ameciclo's IT managers group)
const entraAdminGroupObjectId = config.require("entraAdminGroupObjectId");
const clientConfig = azure.authorization.getClientConfigOutput();

// Common tags
const commonTags = {
  Environment: environment,
  Project: projectName,
  ManagedBy: "pulumi",
  CostCenter: "ameciclo-infrastructure",
};

// Resource Group
const resourceGroup = new azure.resources.ResourceGroup("ameciclo-rg", {
  resourceGroupName: `${projectName}-rg-prod`,
  location: location,
  tags: commonTags,
});

// Virtual Network
const vnet = new azure.network.VirtualNetwork("ameciclo-vnet", {
  virtualNetworkName: `${projectName}-vnet`,
  resourceGroupName: resourceGroup.name,
  location: location,
  addressSpace: {
    addressPrefixes: ["10.10.0.0/16"],
  },
  tags: commonTags,
});

// K3s Subnet
const k3sSubnet = new azure.network.Subnet("k3s-subnet", {
  subnetName: "k3s-subnet",
  resourceGroupName: resourceGroup.name,
  virtualNetworkName: vnet.name,
  addressPrefix: "10.10.1.0/24",
  serviceEndpoints: [{ service: "Microsoft.Storage" }],
});

// Network Security Group for K3s
const k3sNsg = new azure.network.NetworkSecurityGroup("k3s-nsg", {
  networkSecurityGroupName: `${projectName}-k3s-nsg`,
  resourceGroupName: resourceGroup.name,
  location: location,
  tags: commonTags,
});

// SSH Security Rule
const sshRule = new azure.network.SecurityRule("allow-ssh", {
  securityRuleName: "allow-ssh",
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  priority: 1001,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "22",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// HTTPS Security Rule
const httpsRule = new azure.network.SecurityRule("allow-https", {
  securityRuleName: "allow-https",
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  priority: 1002,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "443",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// HTTP Security Rule
const httpRule = new azure.network.SecurityRule("allow-http", {
  securityRuleName: "allow-http",
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  priority: 1003,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "80",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// Private DNS Zone for PostgreSQL
const postgresqlDnsZone = new azure.privatedns.PrivateZone("postgresql-dns", {
  privateZoneName: "privatelink.postgres.database.azure.com",
  resourceGroupName: resourceGroup.name,
  location: "global",
  tags: commonTags,
});

// Link Private DNS Zone to Virtual Network
const postgresqlDnsLink = new azure.privatedns.VirtualNetworkLink(
  "postgresql-vnet-link",
  {
    virtualNetworkLinkName: "postgresql-vnet-link",
    privateZoneName: postgresqlDnsZone.name,
    resourceGroupName: resourceGroup.name,
    location: "global",
    virtualNetwork: {
      id: vnet.id,
    },
    registrationEnabled: false,
    tags: commonTags,
  },
);

// Roles are always declared (never gate them behind a flag: leaving them out
// makes Pulumi delete them). The provider only connects when a role or grant
// actually changes, so unrelated `pulumi up` / `preview` runs (including CI)
// don't need the tunnel.
//
// Creates a login role (default `<name>_user`) with a generated password and
// grants it access to `database`. Read-only roles get SELECT only. Returns the password so it can
// be exported and pasted into the app's Coolify env vars.
function createDbRole(
  name: string,
  database: string,
  opts: {
    readOnly?: boolean;
    roleName?: string;
    dependsOn?: pulumi.Resource[];
    provider: postgresql.Provider;
  },
) {
  const resourceOpts = { provider: opts.provider, dependsOn: opts.dependsOn };
  const password = new random.RandomPassword(`${name}-db-password`, {
    length: 32,
    special: false,
  });
  const role = new postgresql.Role(
    `${name}-role`,
    { name: opts.roleName ?? `${name}_user`, login: true, password: password.result },
    resourceOpts,
  );
  new postgresql.Grant(
    `${name}-db-grant`,
    {
      database,
      role: role.name,
      objectType: "database",
      privileges: opts.readOnly ? ["CONNECT"] : ["CONNECT", "CREATE", "TEMPORARY"],
    },
    resourceOpts,
  );
  new postgresql.Grant(
    `${name}-schema-grant`,
    {
      database,
      role: role.name,
      schema: "public",
      objectType: "schema",
      privileges: opts.readOnly ? ["USAGE"] : ["USAGE", "CREATE"],
    },
    resourceOpts,
  );
  new postgresql.Grant(
    `${name}-table-grant`,
    {
      database,
      role: role.name,
      schema: "public",
      objectType: "table",
      privileges: opts.readOnly
        ? ["SELECT"]
        : ["SELECT", "INSERT", "UPDATE", "DELETE"],
    },
    resourceOpts,
  );
  return pulumi.secret(password.result);
}

// ---------------------------------------------------------------------------
// PostgreSQL server
//
// A public endpoint (firewalled) AND a Private Endpoint in the VM subnet, so
// Coolify apps talk to it over the VNet while external clients (Cloudflare
// Hyperdrive) can use the public endpoint. It replaced the old VNet-integrated
// server, which could never expose a public endpoint (Azure fixes the
// networking mode at creation). See docs/postgres-migration.md.
//
// Public access is closed by default: nothing can connect from the internet
// until you set `postgresAllowedIps` and/or `postgresAllowAllIps` (below).
// ---------------------------------------------------------------------------

// Admin password for the new server. Humans use the Entra admin group login;
// this exists because the server requires one at creation.
const postgresqlPubPassword = new random.RandomPassword(
  "postgresql-pub-admin-password",
  {
    length: 32,
    special: true,
    overrideSpecial: "!#$%&*()-_=+[]{}<>:?",
  },
);

const postgresqlPubServer = new azure.dbforpostgresql.Server(
  "postgresql-pub",
  {
    serverName: `${projectName}-postgres-pub`,
    resourceGroupName: resourceGroup.name,
    location: location,
    administratorLogin: "psqladmin",
    administratorLoginPassword: postgresqlPubPassword.result,
    version: azure.dbforpostgresql.PostgresMajorVersion.PostgresMajorVersion_18,
    sku: {
      name: "Standard_B2s",
      tier: azure.dbforpostgresql.SkuTier.Burstable,
    },
    storage: {
      storageSizeGB: 32,
      autoGrow: azure.dbforpostgresql.StorageAutoGrow.Disabled,
      iops: 120,
      tier: azure.dbforpostgresql.AzureManagedDiskPerformanceTier.P4,
      type: "",
    },
    availabilityZone: "1",
    authConfig: {
      activeDirectoryAuth: azure.dbforpostgresql.ActiveDirectoryAuth.Enabled,
      passwordAuth: azure.dbforpostgresql.PasswordAuth.Enabled,
    },
    highAvailability: {
      mode: azure.dbforpostgresql.PostgreSqlFlexibleServerHighAvailabilityMode.Disabled,
    },
    maintenanceWindow: {
      customWindow: "Disabled",
      dayOfWeek: 0,
      startHour: 0,
      startMinute: 0,
    },
    replica: {
      role: azure.dbforpostgresql.ReplicationRole.Primary,
    },
    replicationRole: azure.dbforpostgresql.ReplicationRole.Primary,
    // Public access mode: no delegated subnet, no private DNS zone here (the
    // Private Endpoint below brings its own DNS record).
    network: {
      publicNetworkAccess:
        azure.dbforpostgresql.ServerPublicNetworkAccessState.Enabled,
    },
    backup: {
      backupRetentionDays: 7,
      geoRedundantBackup: azure.dbforpostgresql.GeoRedundantBackup.Disabled,
    },
    tags: commonTags,
  },
  // dataEncryption is immutable after creation, and azure-native 3.23.0 has a
  // provider bug updating it (the API rejects the PATCH with
  // "InvalidResourceIdSegment"). ignoreChanges stops Pulumi from touching it.
  { ignoreChanges: ["dataEncryption"] },
);

const postgresqlPubAadAdmin = new azure.dbforpostgresql.Administrator(
  "postgresql-pub-aad-admin",
  {
    serverName: postgresqlPubServer.name,
    resourceGroupName: resourceGroup.name,
    objectId: entraAdminGroupObjectId,
    principalName: "TI Ameciclo",
    principalType: azure.dbforpostgresql.PrincipalType.Group,
    tenantId: clientConfig.tenantId,
  },
  { dependsOn: [postgresqlPubServer] },
);

// Private Endpoint: gives the VM a private IP for the new server, resolved
// through the existing privatelink DNS zone (already linked to the VNet).
const postgresqlPubEndpoint = new azure.network.PrivateEndpoint(
  "postgresql-pub-pe",
  {
    privateEndpointName: `${projectName}-postgres-pub-pe`,
    resourceGroupName: resourceGroup.name,
    location: location,
    subnet: { id: k3sSubnet.id },
    privateLinkServiceConnections: [
      {
        name: "postgresql-pub",
        privateLinkServiceId: postgresqlPubServer.id,
        groupIds: ["postgresqlServer"],
      },
    ],
    tags: commonTags,
  },
  { dependsOn: [postgresqlPubAadAdmin] },
);

new azure.network.PrivateDnsZoneGroup("postgresql-pub-pe-dns", {
  privateDnsZoneGroupName: "default",
  privateEndpointName: postgresqlPubEndpoint.name,
  resourceGroupName: resourceGroup.name,
  privateDnsZoneConfigs: [
    { name: "postgres", privateDnsZoneId: postgresqlDnsZone.id },
  ],
});

// Firewall for the public endpoint. Closed unless configured:
//   pulumi config set --path 'postgresAllowedIps[0]' 203.0.113.7
//   pulumi config set postgresAllowAllIps true   # e.g. for Cloudflare Hyperdrive
// Hyperdrive does not publish a small fixed egress range, so reaching it over
// the public endpoint means allowing all IPs; TLS + strong role passwords are
// then the only barrier.
const postgresAllowedIps = config.getObject<string[]>("postgresAllowedIps") ?? [];
postgresAllowedIps.forEach((ip, i) => {
  new azure.dbforpostgresql.FirewallRule(`postgresql-pub-fw-${i}`, {
    firewallRuleName: `allow-${i}`,
    serverName: postgresqlPubServer.name,
    resourceGroupName: resourceGroup.name,
    startIpAddress: ip,
    endIpAddress: ip,
  });
});
if (config.getBoolean("postgresAllowAllIps") ?? false) {
  new azure.dbforpostgresql.FirewallRule("postgresql-pub-fw-all", {
    firewallRuleName: "allow-all",
    serverName: postgresqlPubServer.name,
    resourceGroupName: resourceGroup.name,
    startIpAddress: "0.0.0.0",
    endIpAddress: "255.255.255.255",
  });
}

const pubDatabases = ["strapi", "atlas", "ameciclo"].map(
  (name) =>
    new azure.dbforpostgresql.Database(`pub-${name}-db`, {
      databaseName: name,
      serverName: postgresqlPubServer.name,
      resourceGroupName: resourceGroup.name,
      charset: "UTF8",
      collation: "en_US.utf8",
    }, { dependsOn: [postgresqlPubAadAdmin] }),
);

// Roles on the new server go through a second tunnel (port 15433) to the new
// server's FQDN, with an AAD token as the password:
//   PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms \
//     --query accessToken -o tsv) pulumi up
//   az ssh vm -g ameciclo-rg-prod -n ameciclo-coolify-vm -- \
//     -N -L 15433:ameciclo-postgres-pub.postgres.database.azure.com:5432
const postgresPubTunnelPort = config.getNumber("postgresPubTunnelPort") ?? 15433;
const postgresPubProvider = new postgresql.Provider("postgres-pub", {
  host: "localhost",
  port: postgresPubTunnelPort,
  username: "TI Ameciclo",
  sslmode: "require",
  superuser: false,
});

const pubRole = (name: string, roleName: string, database: string) =>
  createDbRole(`pub-${name}`, database, {
    roleName,
    provider: postgresPubProvider,
    dependsOn: pubDatabases,
  });
const strapiPubDbPassword = pubRole("strapi", "strapi_user", "strapi");
const atlasPubDbPassword = pubRole("atlas", "atlas_user", "atlas");
const amecicloPubDbPassword = pubRole("ameciclo", "ameciclo", "ameciclo");

// Storage Account for Blob Storage (Azure's S3 equivalent)
const storageAccount = new azure.storage.StorageAccount("ameciclo-storage", {
  accountName: `${projectName}stor${environment.substring(0, 4)}`,
  resourceGroupName: resourceGroup.name,
  location: location,
  sku: {
    name: azure.storage.SkuName.Standard_LRS,
  },
  kind: azure.storage.Kind.StorageV2,
  accessTier: azure.storage.AccessTier.Hot,
  allowBlobPublicAccess: true,
  allowSharedKeyAccess: true,
  minimumTlsVersion: azure.storage.MinimumTlsVersion.TLS1_2,
  networkRuleSet: {
    defaultAction: azure.storage.DefaultAction.Allow,
    virtualNetworkRules: [
      {
        virtualNetworkResourceId: k3sSubnet.id,
        action: azure.storage.Action.Allow,
      },
    ],
  },
  tags: commonTags,
});

// Blob Storage Containers
const mediaContainer = new azure.storage.BlobContainer("media", {
  containerName: "media",
  accountName: storageAccount.name,
  resourceGroupName: resourceGroup.name,
  publicAccess: azure.storage.PublicAccess.Blob,
});

const backupsContainer = new azure.storage.BlobContainer("backups", {
  containerName: "backups",
  accountName: storageAccount.name,
  resourceGroupName: resourceGroup.name,
  publicAccess: azure.storage.PublicAccess.None,
});

const logsContainer = new azure.storage.BlobContainer("logs", {
  containerName: "logs",
  accountName: storageAccount.name,
  resourceGroupName: resourceGroup.name,
  publicAccess: azure.storage.PublicAccess.None,
});

// Create Coolify VM (Pulumi resource constructor name kept as "k3s" so
// the existing Public IP and NIC are retained — renaming would force
// destroy+recreate of the public IP and a DNS update.)
const coolifyVm = createCoolifyVm("k3s", {
  resourceGroupName: resourceGroup.name,
  location: location,
  subnetId: k3sSubnet.id,
  networkSecurityGroupId: k3sNsg.id,
  projectName: projectName,
  tags: commonTags,
});

// Grants TI Ameciclo group members `az ssh vm` access via their own Azure AD
// identity (see the AADSSHLoginForLinux extension in vm.ts).
const vmSshRoleAssignmentId = new random.RandomUuid("vm-ssh-role-assignment-id");
const vmSshRoleAssignment = new azure.authorization.RoleAssignment(
  "vm-ssh-admin-login",
  {
    roleAssignmentName: vmSshRoleAssignmentId.result,
    scope: coolifyVm.vm.id,
    principalId: entraAdminGroupObjectId,
    principalType: azure.authorization.PrincipalType.Group,
    // Built-in "Virtual Machine Administrator Login" role
    roleDefinitionId: clientConfig.subscriptionId.apply(
      (subscriptionId) =>
        `/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4`,
    ),
  },
);

// Export important values
export const resourceGroupName = resourceGroup.name;
export const resourceGroupId = resourceGroup.id;
export const vnetName = vnet.name;
export const vnetId = vnet.id;
export const vmSubnetId = k3sSubnet.id;
export const coolifyVmId = coolifyVm.vm.id;
export const coolifyVmName = coolifyVm.vm.name;
export const coolifyPublicIp = coolifyVm.publicIp.ipAddress;
export const coolifyPrivateIp = pulumi.output("10.10.1.4");
export const coolifySshCommand = pulumi.interpolate`ssh azureuser@${coolifyVm.publicIp.ipAddress}`;

// Storage exports
export const storageAccountName = storageAccount.name;
export const storageAccountId = storageAccount.id;
export const storageAccountPrimaryEndpoints = storageAccount.primaryEndpoints;
export const mediaContainerName = mediaContainer.name;
export const backupsContainerName = backupsContainer.name;
export const logsContainerName = logsContainer.name;

// PostgreSQL server (see docs/postgres-migration.md). Role passwords:
//   pulumi stack output strapiPubDbPassword --show-secrets
export const postgresqlPubServerFqdn = postgresqlPubServer.fullyQualifiedDomainName;
export { strapiPubDbPassword, atlasPubDbPassword, amecicloPubDbPassword };
