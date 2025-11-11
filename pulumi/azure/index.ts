/**
 * Ameciclo Azure Infrastructure with K3s
 * Pulumi program to provision Azure resources for Ameciclo
 */

import * as azure from "@pulumi/azure-native";
import * as k8s from "@pulumi/kubernetes";
import * as command from "@pulumi/command";
import * as pulumi from "@pulumi/pulumi";
import * as fs from "fs";
import * as path from "path";
import * as k8sConfig from "./k8s";
import * as argocdApps from "./argocd-apps";

// ============================================================================
// Configuration
// ============================================================================

const config = new pulumi.Config();
const azureConfig = new pulumi.Config("azure-native");

// General Configuration
const environment = config.get("environment") || "production";
const region = azureConfig.get("location") || "westus3";
const projectName = config.get("project_name") || "ameciclo";

// Resource Group Configuration
const resourceGroupNameConfig =
  config.get("resource_group_name") || "ameciclo-rg";

// Network Configuration
const vnetName = config.get("vnet_name") || "ameciclo-vnet";
const vnetAddressSpace = config.getObject<string[]>("vnet_address_space") || [
  "10.10.0.0/16",
];
const databaseSubnetName =
  config.get("database_subnet_name") || "database-subnet";
const databaseSubnetPrefix = config.getObject<string[]>(
  "database_subnet_prefix",
) || ["10.10.2.0/24"];

// PostgreSQL Configuration
const postgresqlServerName = config.require("postgresql_server_name");
const postgresqlAdminUsername = config.require("postgresql_admin_username");
const postgresqlAdminPassword = config.requireSecret(
  "postgresql_admin_password",
);
const postgresqlVersion = config.get("postgresql_version") || "16";
const postgresqlSkuName = config.get("postgresql_sku_name") || "B_Standard_B2s";
const postgresqlStorageMb = config.getNumber("postgresql_storage_mb") || 32768;

// K3s VM Configuration
const k3sVmSize = config.get("k3s_vm_size") || "Standard_B2as_v2";
const adminUsername = config.get("admin_username") || "azureuser";
const adminSshPublicKey = config.requireSecret("admin_ssh_public_key");

// Storage Configuration (currently disabled in Terraform)
const storageAccountName =
  config.get("storage_account_name") || "ameciclostorage";
const storageAccountTier = config.get("storage_account_tier") || "Standard";
const storageAccountReplicationType =
  config.get("storage_account_replication_type") || "LRS";

// Tags
const tags = config.getObject<Record<string, string>>("tags") || {
  Environment: environment,
  Project: projectName,
  ManagedBy: "pulumi",
  CostCenter: "ameciclo-infrastructure",
};

// ============================================================================
// Resource Group
// ============================================================================

const resourceGroup = new azure.resources.ResourceGroup("ameciclo", {
  resourceGroupName: resourceGroupNameConfig,
  location: region,
  tags: tags,
});

// ============================================================================
// Virtual Network
// ============================================================================

const vnet = new azure.network.VirtualNetwork("ameciclo-vnet", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  virtualNetworkName: vnetName,
  addressSpace: {
    addressPrefixes: vnetAddressSpace,
  },
  tags: tags,
});

// K3s Subnet
const k3sSubnet = new azure.network.Subnet("k3s-subnet", {
  resourceGroupName: resourceGroup.name,
  virtualNetworkName: vnet.name,
  subnetName: "k3s-subnet",
  addressPrefix: "10.10.1.0/24",
  serviceEndpoints: [{ service: "Microsoft.Storage" }],
});

// Database Subnet
const databaseSubnet = new azure.network.Subnet("database-subnet", {
  resourceGroupName: resourceGroup.name,
  virtualNetworkName: vnet.name,
  subnetName: databaseSubnetName,
  addressPrefixes: databaseSubnetPrefix,
  serviceEndpoints: [{ service: "Microsoft.Storage" }],
  delegations: [
    {
      name: "fs",
      serviceName: "Microsoft.DBforPostgreSQL/flexibleServers",
    },
  ],
});

// ============================================================================
// Network Security Groups
// ============================================================================

// K3s NSG
const k3sNsg = new azure.network.NetworkSecurityGroup("k3s-nsg", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  networkSecurityGroupName: `${projectName}-k3s-nsg`,
  tags: tags,
});

// SSH Rule
const sshRule = new azure.network.SecurityRule("k3s-ssh", {
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  securityRuleName: "AllowSSH",
  priority: 100,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "22",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// HTTP Rule
const httpRule = new azure.network.SecurityRule("k3s-http", {
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  securityRuleName: "AllowHTTP",
  priority: 110,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "80",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// HTTPS Rule
const httpsRule = new azure.network.SecurityRule("k3s-https", {
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  securityRuleName: "AllowHTTPS",
  priority: 120,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "443",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// K3s API Rule
const k3sApiRule = new azure.network.SecurityRule("k3s-api", {
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: k3sNsg.name,
  securityRuleName: "AllowK3sAPI",
  priority: 130,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "6443",
  sourceAddressPrefix: "*",
  destinationAddressPrefix: "*",
});

// Database NSG
const databaseNsg = new azure.network.NetworkSecurityGroup("database-nsg", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  networkSecurityGroupName: `${projectName}-database-nsg`,
  tags: tags,
});

// PostgreSQL from K3s Rule
const postgresRule = new azure.network.SecurityRule("allow-postgres-k3s", {
  resourceGroupName: resourceGroup.name,
  networkSecurityGroupName: databaseNsg.name,
  securityRuleName: "AllowPostgresK3s",
  priority: 101,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "5432",
  sourceAddressPrefix: "10.10.1.0/24",
  destinationAddressPrefix: "*",
});

// Note: NSG associations are handled through the Subnet resource's networkSecurityGroup property
// The azure-native provider doesn't have a separate SubnetNetworkSecurityGroupAssociation resource

// ============================================================================
// K3s Virtual Machine
// ============================================================================

// Public IP
const k3sPublicIp = new azure.network.PublicIPAddress("k3s-pip", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  publicIpAddressName: "ameciclo-k3s-pip",
  publicIPAllocationMethod: "Static",
  sku: {
    name: "Standard",
  },
  tags: tags,
});

// Network Interface
const k3sNic = new azure.network.NetworkInterface("k3s-nic", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  networkInterfaceName: "ameciclo-k3s-nic",
  ipConfigurations: [
    {
      name: "testconfiguration1",
      subnet: { id: k3sSubnet.id },
      privateIPAllocationMethod: "Static",
      privateIPAddress: "10.10.1.4",
      publicIPAddress: { id: k3sPublicIp.id },
    },
  ],
  tags: tags,
});

// K3s VM
const k3sVm = new azure.compute.VirtualMachine("k3s-vm", {
  resourceGroupName: resourceGroup.name,
  location: resourceGroup.location,
  vmName: "ameciclo-k3s-vm",
  hardwareProfile: {
    vmSize: k3sVmSize,
  },
  osProfile: {
    computerName: "ameciclo-k3s-vm",
    adminUsername: adminUsername,
    linuxConfiguration: {
      disablePasswordAuthentication: true,
      ssh: {
        publicKeys: [
          {
            path: `/home/${adminUsername}/.ssh/authorized_keys`,
            keyData: adminSshPublicKey,
          },
        ],
      },
    },
  },
  storageProfile: {
    imageReference: {
      publisher: "Canonical",
      offer: "0001-com-ubuntu-server-jammy",
      sku: "22_04-lts-gen2",
      version: "latest",
    },
    osDisk: {
      name: "ameciclo-k3s-vm-osdisk",
      caching: "ReadWrite",
      createOption: "FromImage",
      managedDisk: {
        storageAccountType: "Premium_LRS",
      },
    },
  },
  networkProfile: {
    networkInterfaces: [
      {
        id: k3sNic.id,
        primary: true,
      },
    ],
  },
  tags: { ...tags, Name: "K3s" },
});

// ============================================================================
// PostgreSQL Database
// ============================================================================

// Private DNS Zone for PostgreSQL
const postgresqlDnsZone = new azure.network.PrivateZone("postgresql-dns-zone", {
  resourceGroupName: resourceGroup.name,
  location: "global",
  privateZoneName: "privatelink.postgres.database.azure.com",
  tags: tags,
});

// Link Private DNS Zone to Virtual Network
const postgresqlDnsLink = new azure.network.VirtualNetworkLink(
  "postgresql-vnet-link",
  {
    resourceGroupName: resourceGroup.name,
    privateZoneName: postgresqlDnsZone.name,
    virtualNetworkLinkName: "postgresql-vnet-link",
    location: "global",
    virtualNetwork: { id: vnet.id },
    registrationEnabled: false,
    tags: tags,
  },
);

// PostgreSQL Flexible Server
const postgresqlServer = new azure.dbforpostgresql.Server(
  "postgresql-server",
  {
    resourceGroupName: resourceGroup.name,
    location: resourceGroup.location,
    serverName: postgresqlServerName,
    administratorLogin: postgresqlAdminUsername,
    administratorLoginPassword: postgresqlAdminPassword,
    version: postgresqlVersion,
    sku: {
      name: postgresqlSkuName,
      tier: "Burstable",
    },
    storage: {
      storageSizeGB: Math.floor(postgresqlStorageMb / 1024),
    },
    network: {
      delegatedSubnetResourceId: databaseSubnet.id,
      privateDnsZoneArmResourceId: postgresqlDnsZone.id,
    },
    backup: {
      backupRetentionDays: 7,
      geoRedundantBackup: "Disabled",
    },
    highAvailability: {
      mode: "Disabled",
    },
    availabilityZone: "1",
    tags: tags,
  },
  { dependsOn: [postgresqlDnsLink] },
);

// PostgreSQL Databases
const atlasDb = new azure.dbforpostgresql.Database("atlas-db", {
  resourceGroupName: resourceGroup.name,
  serverName: postgresqlServer.name,
  databaseName: "atlas",
  charset: "UTF8",
  collation: "en_US.utf8",
});

const kongDb = new azure.dbforpostgresql.Database("kong-db", {
  resourceGroupName: resourceGroup.name,
  serverName: postgresqlServer.name,
  databaseName: "kong",
  charset: "UTF8",
  collation: "en_US.utf8",
});

// Private DNS A Record for PostgreSQL
const postgresqlDnsRecord = new azure.network.RecordSet(
  "postgresql-dns-record",
  {
    resourceGroupName: resourceGroup.name,
    zoneName: postgresqlDnsZone.name,
    recordType: "A",
    relativeRecordSetName: "ameciclo-postgres",
    ttl: 300,
    aRecords: [{ ipv4Address: "10.10.2.4" }],
  },
);

// ============================================================================
// Storage Account (Currently disabled in Terraform - commented out)
// ============================================================================
// Uncomment below to enable storage account

// const storageAccount = new azure.storage.StorageAccount("ameciclo-storage", {
//     resourceGroupName: resourceGroup.name,
//     location: resourceGroup.location,
//     accountName: storageAccountName,
//     sku: {
//         name: storageAccountReplicationType
//     },
//     kind: "StorageV2",
//     enableHttpsTrafficOnly: true,
//     minimumTlsVersion: "TLS1_2",
//     tags: tags
// });

// const storageContainer = new azure.storage.BlobContainer("ameciclo-data", {
//     resourceGroupName: resourceGroup.name,
//     accountName: storageAccount.name,
//     containerName: "ameciclo-data",
//     publicAccess: "None"
// });

// ============================================================================
// Kubernetes Configuration
// ============================================================================

// Get kubeconfig from K3s VM
const getKubeconfigCommand = new command.remote.Command(
  "get-kubeconfig",
  {
    connection: {
      host: k3sPublicIp.ipAddress.apply((ip) => ip || ""),
      user: adminUsername,
      privateKey: config.requireSecret("admin_ssh_private_key"),
    },
    create: "sudo cat /etc/rancher/k3s/k3s.yaml",
  },
  { dependsOn: [k3sVm] }
);

// Create Kubernetes provider
const k3sProvider = k8sConfig.createK8sProvider(getKubeconfigCommand.stdout);

// Create namespaces
const namespaces = k8sConfig.createNamespaces(k3sProvider);

// Deploy ArgoCD
const argocd = k8sConfig.deployArgoCD(k3sProvider, namespaces.argocd);

// Deploy Tailscale Operator
const tailscaleOperator = k8sConfig.deployTailscaleOperator(
  k3sProvider,
  namespaces.tailscale
);

// Deploy ArgoCD Applications (depends on ArgoCD being deployed)
const applications = argocdApps.deployApplications(
  k3sProvider,
  namespaces.argocd.metadata.name.apply((name) => name || "argocd"),
  argocd
);

// ============================================================================
// Outputs
// ============================================================================

// K3s VM Outputs
export const k3sVmId = k3sVm.id;
export const k3sVmName = k3sVm.name;
export const k3sVmPublicIp = k3sPublicIp.ipAddress;
export const k3sVmPrivateIp = k3sNic.ipConfigurations.apply(
  (configs) => configs?.[0]?.privateIPAddress,
);
export const k3sVmSshCommand = pulumi.interpolate`ssh ${adminUsername}@${k3sPublicIp.ipAddress}`;

// PostgreSQL Outputs
export const postgresqlServerFqdn = postgresqlServer.fullyQualifiedDomainName;
export const postgresqlServerId = postgresqlServer.id;
export const postgresqlConnectionString = pulumi.interpolate`postgresql://${postgresqlAdminUsername}:${postgresqlAdminPassword}@${postgresqlServer.fullyQualifiedDomainName}:5432/atlas?sslmode=require`;

// Resource Group Outputs
export const resourceGroupName = resourceGroup.name;
export const resourceGroupId = resourceGroup.id;

// Kubernetes Outputs
export const kubeconfig = getKubeconfigCommand.stdout;
export const argocdNamespace = namespaces.argocd.metadata.name;
export const deployedApplications = Object.keys(applications);
