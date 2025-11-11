import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import { createK3sVm } from "./vm";

// Get configuration
const config = new pulumi.Config();
const location = config.get("location") || "eastus2";
const projectName = config.get("projectName") || "ameciclo";
const environment = config.get("environment") || "production";

// Common tags
const commonTags = {
  Environment: environment,
  Project: projectName,
  ManagedBy: "pulumi",
  CostCenter: "ameciclo-infrastructure",
};

// Resource Group
const resourceGroup = new azure.resources.ResourceGroup("ameciclo-rg", {
  resourceGroupName: `${projectName}-rg`,
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
    serverName: `${projectName}-postgresql`,
    resourceGroupName: resourceGroup.name,
    location: location,
    administratorLogin: config.requireSecret("postgresqlAdminUsername"),
    administratorLoginPassword: config.requireSecret("postgresqlAdminPassword"),
    version: azure.dbforpostgresql.ServerVersion.ServerVersion_16,
    sku: {
      name: "Standard_B2s",
      tier: azure.dbforpostgresql.SkuTier.Burstable,
    },
    storage: {
      storageSizeGB: 32,
    },
    availabilityZone: "1",
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

const kongDatabase = new azure.dbforpostgresql.Database("kong-db", {
  databaseName: "kong",
  serverName: postgresqlServer.name,
  resourceGroupName: resourceGroup.name,
  charset: "UTF8",
  collation: "en_US.utf8",
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
