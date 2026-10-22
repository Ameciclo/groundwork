import * as azure from "@pulumi/azure-native";
import * as azuread from "@pulumi/azuread";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";

// Dedicated identity for the Ameciclops Telegram agent. It must NOT reuse the human
// "TI Ameciclo" group: the agent gets its own service principal with the minimum role.
//
// Rotate by changing AGENT_SECRET_EXPIRES (a new secret is issued and the old one removed),
// then update the Worker: pulumi stack output ameciclopsClientSecret --show-secrets |
//   wrangler secret put AZURE_CLIENT_SECRET   (run by a human, never by the agent).
const AGENT_SECRET_EXPIRES = "2027-04-22T00:00:00Z";

// Built-in "Reader" role
const READER_ROLE_ID = "acdd72a7-3385-48ef-bd42-f606fba81ae7";

export function createAgentIdentity(args: {
  resourceGroupId: pulumi.Input<string>;
  subscriptionId: pulumi.Input<string>;
}) {
  const app = new azuread.Application("ameciclops-app", {
    displayName: "ameciclops-agent",
    description: "Ameciclops Telegram DevOps agent (read-only)",
  });

  const sp = new azuread.ServicePrincipal("ameciclops-sp", {
    clientId: app.clientId,
  });

  const secret = new azuread.ApplicationPassword("ameciclops-secret", {
    applicationId: app.id,
    displayName: "ameciclops-worker",
    endDate: AGENT_SECRET_EXPIRES,
  });

  // Reader on the production resource group only, nothing broader
  const roleAssignmentId = new random.RandomUuid("ameciclops-reader-id");
  const reader = new azure.authorization.RoleAssignment("ameciclops-reader", {
    roleAssignmentName: roleAssignmentId.result,
    scope: args.resourceGroupId,
    principalId: sp.objectId,
    principalType: azure.authorization.PrincipalType.ServicePrincipal,
    roleDefinitionId: pulumi.interpolate`/subscriptions/${args.subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${READER_ROLE_ID}`,
  });

  return { app, sp, secret, reader };
}
