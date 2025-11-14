import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import * as random from "@pulumi/random";
import { createK3sVm } from "./vm";
import { createDatabaseUser } from "./database-users";

// Get configuration
const config = new pulumi.Config();
const location = config.get("location") || "westus3";
const projectName = config.get("projectName") || "ameciclo";
const environment = config.get("environment") || "production";

// Generate secure random password for PostgreSQL admin
const postgresqlPassword = new random.RandomPassword("postgresql-admin-password", {
  length: 32,
  special: true,
  overrideSpecial: "!#$%&*()-_=+[]{}<>:?",
});

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

// Database Subnet
const databaseSubnet = new azure.network.Subnet("database-subnet", {
  subnetName: "database-subnet",
  resourceGroupName: resourceGroup.name,
  virtualNetworkName: vnet.name,
  addressPrefix: "10.10.2.0/24",
  serviceEndpoints: [{ service: "Microsoft.Storage" }],
  delegations: [
    {
      name: "fs",
      serviceName: "Microsoft.DBforPostgreSQL/flexibleServers",
    },
  ],
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
    virtualNetwork: {
      id: vnet.id,
    },
    registrationEnabled: false,
    tags: commonTags,
  },
);

// PostgreSQL Flexible Server
const postgresqlServer = new azure.dbforpostgresql.Server(
  "postgresql",
  {
    serverName: `${projectName}-postgres`,
    resourceGroupName: resourceGroup.name,
    location: location,
    administratorLogin: "psqladmin",
    administratorLoginPassword: postgresqlPassword.result,
    version: azure.dbforpostgresql.ServerVersion.ServerVersion_16,
    sku: {
      name: "Standard_B2s",
      tier: azure.dbforpostgresql.SkuTier.Burstable,
    },
    storage: {
      storageSizeGB: 32,
      autoGrow: azure.dbforpostgresql.StorageAutoGrow.Disabled,
      iops: 120,
      tier: azure.dbforpostgresql.AzureManagedDiskPerformanceTiers.P4,
      type: "",
    },
    availabilityZone: "1",
    authConfig: {
      activeDirectoryAuth: azure.dbforpostgresql.ActiveDirectoryAuthEnum.Disabled,
      passwordAuth: azure.dbforpostgresql.PasswordAuthEnum.Enabled,
    },
    dataEncryption: {
      type: azure.dbforpostgresql.ArmServerKeyType.SystemManaged,
    },
    highAvailability: {
      mode: azure.dbforpostgresql.HighAvailabilityMode.Disabled,
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
    network: {
      delegatedSubnetResourceId: databaseSubnet.id,
      privateDnsZoneArmResourceId: postgresqlDnsZone.id,
      publicNetworkAccess:
        azure.dbforpostgresql.ServerPublicNetworkAccessState.Disabled,
    },
    backup: {
      backupRetentionDays: 7,
      geoRedundantBackup: azure.dbforpostgresql.GeoRedundantBackupEnum.Disabled,
    },
    tags: commonTags,
  },
  { dependsOn: [postgresqlDnsLink] },
);

// PostgreSQL Databases
const atlasDatabase = new azure.dbforpostgresql.Database("atlas-db", {
  databaseName: "atlas",
  serverName: postgresqlServer.name,
  resourceGroupName: resourceGroup.name,
  charset: "UTF8",
  collation: "en_US.utf8",
});

const strapiDatabase = new azure.dbforpostgresql.Database("strapi-db", {
  databaseName: "strapi",
  serverName: postgresqlServer.name,
  resourceGroupName: resourceGroup.name,
  charset: "UTF8",
  collation: "en_US.utf8",
});

const zitadelDatabase = new azure.dbforpostgresql.Database("zitadel-db", {
  databaseName: "zitadel",
  serverName: postgresqlServer.name,
  resourceGroupName: resourceGroup.name,
  charset: "UTF8",
  collation: "en_US.utf8",
});

// Create dedicated database users with the PostgreSQL provider
// These are managed declaratively and passwords are stored encrypted in Pulumi state
const strapiUser = createDatabaseUser("strapi-user", {
  serverFqdn: postgresqlServer.fullyQualifiedDomainName,
  adminUsername: "psqladmin",
  adminPassword: postgresqlPassword.result,
  databaseName: "strapi",
  userName: "strapi_user",
  databases: [strapiDatabase],
});

const atlasUser = createDatabaseUser("atlas-user", {
  serverFqdn: postgresqlServer.fullyQualifiedDomainName,
  adminUsername: "psqladmin",
  adminPassword: postgresqlPassword.result,
  databaseName: "atlas",
  userName: "atlas_user",
  databases: [atlasDatabase],
});

const zitadelUser = createDatabaseUser("zitadel-user", {
  serverFqdn: postgresqlServer.fullyQualifiedDomainName,
  adminUsername: "psqladmin",
  adminPassword: postgresqlPassword.result,
  databaseName: "zitadel",
  userName: "zitadel_user",
  databases: [zitadelDatabase],
});





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
  allowBlobPublicAccess: false,
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
  publicAccess: azure.storage.PublicAccess.None,
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

// Create K3s VM
const k3sVm = createK3sVm("k3s", {
  resourceGroupName: resourceGroup.name,
  location: location,
  subnetId: k3sSubnet.id,
  networkSecurityGroupId: k3sNsg.id,
  projectName: projectName,
  tags: commonTags,
});

// Export important values
export const resourceGroupName = resourceGroup.name;
export const resourceGroupId = resourceGroup.id;
export const vnetName = vnet.name;
export const vnetId = vnet.id;
export const k3sSubnetId = k3sSubnet.id;
export const databaseSubnetId = databaseSubnet.id;
export const postgresqlServerName = postgresqlServer.name;
export const postgresqlServerFqdn = postgresqlServer.fullyQualifiedDomainName;
export const k3sVmId = k3sVm.vm.id;
export const k3sVmName = k3sVm.vm.name;
export const k3sPublicIp = k3sVm.publicIp.ipAddress;
export const k3sPrivateIp = pulumi.output("10.10.1.4");
export const k3sSshCommand = pulumi.interpolate`ssh azureuser@${k3sVm.publicIp.ipAddress}`;

// Storage exports
export const storageAccountName = storageAccount.name;
export const storageAccountId = storageAccount.id;
export const storageAccountPrimaryEndpoints = storageAccount.primaryEndpoints;
export const mediaContainerName = mediaContainer.name;
export const backupsContainerName = backupsContainer.name;
export const logsContainerName = logsContainer.name;

// PostgreSQL admin credentials (encrypted in Pulumi state)
export const postgresqlAdminUsername = pulumi.output("psqladmin");
export const postgresqlAdminPassword = pulumi.secret(postgresqlPassword.result);

// Database user credentials (encrypted in Pulumi state)
export const strapiDbUsername = pulumi.output(strapiUser.username);
export const strapiDbPassword = pulumi.secret(strapiUser.password);
export const atlasDbUsername = pulumi.output(atlasUser.username);
export const atlasDbPassword = pulumi.secret(atlasUser.password);
export const zitadelDbUsername = pulumi.output(zitadelUser.username);
export const zitadelDbPassword = pulumi.secret(zitadelUser.password);
