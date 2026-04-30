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

const COOLIFY_CLOUD_INIT = `#cloud-config
package_update: true
package_upgrade: true
packages:
  - curl
  - ca-certificates
runcmd:
  - [ sh, -xc, "curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash" ]
final_message: "Coolify install complete after $UPTIME seconds"
`;

export function createCoolifyVm(
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

  // Coolify Virtual Machine (Pulumi resource name kept as `k3s-vm` so the
  // Public IP / NIC are retained on replace — keeps the same public IP and
  // avoids DNS updates during the migration from k3s to Coolify.)
  const vm = new azure.compute.VirtualMachine(`${name}-vm`, {
    vmName: `${args.projectName}-coolify-vm`,
    resourceGroupName: args.resourceGroupName,
    location: args.location,
    hardwareProfile: {
      vmSize: "Standard_B4as_v2",  // 4 vCPU, 16GB RAM
    },
    osProfile: {
      computerName: `${args.projectName}-coolify`,
      adminUsername: "azureuser",
      customData: Buffer.from(COOLIFY_CLOUD_INIT).toString("base64"),
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
        name: `${args.projectName}-coolify-osdisk`,
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
      Name: "Coolify",
    },
  });

  return {
    vm,
    publicIp,
    networkInterface,
  };
}
