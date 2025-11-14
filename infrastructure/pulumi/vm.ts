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
    ddosSettings: {
      protectionMode: "VirtualNetworkInherited",
    },
    idleTimeoutInMinutes: 4,
    ipAddress: "4.236.123.221",
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
        name: "testconfiguration1", // Must match existing IP config name (cannot rename primary)
        subnet: {
          id: args.subnetId,
        },
        privateIPAllocationMethod: "Static",
        privateIPAddress: "10.10.1.4",
        publicIPAddress: {
          id: publicIp.id,
        },
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
      vmSize: "Standard_B2as_v2",
    },
    osProfile: {
      computerName: "ameciclo-k3s-vm", // Must match existing (cannot rename)
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
        name: "ameciclo-k3s-vm_OsDisk_1_6fdbe0eb5d384f0cb44764648e92d771", // Must match existing disk (cannot rename)
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
