import * as azure from "@pulumi/azure-native";
import * as pulumi from "@pulumi/pulumi";

export interface VmArgs {
  resourceGroupName: pulumi.Input<string>;
  location: pulumi.Input<string>;
  subnetId: pulumi.Input<string>;
  networkSecurityGroupId: pulumi.Input<string>;
  projectName: string;
  tags: Record<string, string>;
}

export function createK3sVm(
  name: string,
  args: VmArgs,
): {
  vm: azure.compute.VirtualMachine;
  publicIp: azure.network.PublicIPAddress;
  networkInterface: azure.network.NetworkInterface;
} {
  const config = new pulumi.Config();

  // Public IP for K3s VM
  const publicIp = new azure.network.PublicIPAddress(`${name}-pip`, {
    publicIpAddressName: `${args.projectName}-k3s-pip`,
    resourceGroupName: args.resourceGroupName,
    location: args.location,
    publicIPAllocationMethod: "Static",
    sku: {
      name: "Standard",
      tier: "Regional",
    },
    publicIPAddressVersion: "IPv4",
    tags: args.tags,
  });

  // Network Interface for K3s VM
  const networkInterface = new azure.network.NetworkInterface(`${name}-nic`, {
    networkInterfaceName: `${args.projectName}-k3s-nic`,
    resourceGroupName: args.resourceGroupName,
    location: args.location,
    ipConfigurations: [
      {
        name: "ipconfig1",
        subnet: {
          id: args.subnetId,
        },
        privateIPAllocationMethod: "Static",
        privateIPAddress: "10.10.1.4",
        publicIPAddress: {
          id: publicIp.id,
        },
        primary: true,
      },
    ],
    networkSecurityGroup: {
      id: args.networkSecurityGroupId,
    },
    tags: args.tags,
  });

  // K3s Virtual Machine
  const vm = new azure.compute.VirtualMachine(`${name}-vm`, {
    vmName: `${args.projectName}-k3s-vm`,
    resourceGroupName: args.resourceGroupName,
    location: args.location,
    hardwareProfile: {
      // Upgraded from Standard_B2as_v2 (2 vCPU, 8GB) to support Superset + Zitadel
      vmSize: "Standard_B4as_v2",  // 4 vCPU, 16GB RAM (AMD, same family)
    },
    osProfile: {
      computerName: `${args.projectName}-k3s`,
      adminUsername: "azureuser",
      linuxConfiguration: {
        disablePasswordAuthentication: true,
        ssh: {
          publicKeys: [
            {
              path: "/home/azureuser/.ssh/authorized_keys",
              keyData: config.requireSecret("adminSshPublicKey"),
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
        name: `${args.projectName}-k3s-osdisk`,
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
          id: networkInterface.id,
          primary: true,
        },
      ],
    },
    tags: {
      ...args.tags,
      Name: "K3s",
    },
  });

  return {
    vm,
    publicIp,
    networkInterface,
  };
}
