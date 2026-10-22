import * as azure from "@pulumi/azure-native";
import * as pulumi from "@pulumi/pulumi";

export interface AiArgs {
  resourceGroupName: pulumi.Input<string>;
  location: pulumi.Input<string>;
  projectName: string;
  tags: Record<string, string>;
}

// Azure AI Foundry account (kind AIServices) hosting the model used by the
// Ameciclops Telegram agent. Pay-per-token (GlobalStandard), no provisioned capacity.
export function createAiAccount(args: AiArgs): {
  account: azure.cognitiveservices.Account;
  deployment: azure.cognitiveservices.Deployment;
} {
  const account = new azure.cognitiveservices.Account("ameciclo-ai", {
    accountName: args.projectName,
    resourceGroupName: args.resourceGroupName,
    location: args.location,
    kind: "AIServices",
    sku: { name: "S0" },
    identity: { type: "SystemAssigned" },
    properties: {
      // Also the DNS label: https://<name>.cognitiveservices.azure.com
      customSubDomainName: args.projectName,
      publicNetworkAccess: "Enabled",
    },
    tags: args.tags,
  });

  const deployment = new azure.cognitiveservices.Deployment("gpt-5-4-mini", {
    deploymentName: "gpt-5-4-mini",
    accountName: account.name,
    resourceGroupName: args.resourceGroupName,
    properties: {
      model: { format: "OpenAI", name: "gpt-5.4-mini", version: "2026-03-17" },
    },
    // capacity is a rate-limit ceiling (thousands of tokens/min), not a cost
    sku: { name: "GlobalStandard", capacity: 50 },
  });

  return { account, deployment };
}
