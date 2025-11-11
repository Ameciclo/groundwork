/**
 * Kubernetes Resources for Ameciclo
 * Deploys applications and infrastructure components to K3s cluster
 */

import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

// Kubernetes provider configuration
export function createK8sProvider(kubeconfig: pulumi.Output<string>) {
  return new k8s.Provider("k3s", {
    kubeconfig: kubeconfig,
  });
}

// Create namespaces
export function createNamespaces(provider: k8s.Provider) {
  const namespaces = [
    "argocd",
    "strapi",
    "atlas",
    "kestra",
    "kong",
    "tailscale",
    "monitoring",
  ];

  const createdNamespaces: Record<string, k8s.core.v1.Namespace> = {};

  for (const ns of namespaces) {
    createdNamespaces[ns] = new k8s.core.v1.Namespace(
      ns,
      {
        metadata: {
          name: ns,
          labels: {
            "app.kubernetes.io/managed-by": "pulumi",
          },
        },
      },
      { provider }
    );
  }

  return createdNamespaces;
}

// Deploy ArgoCD using Helm
export function deployArgoCD(
  provider: k8s.Provider,
  namespace: k8s.core.v1.Namespace
) {
  const argocdVersion = config.get("argocd_version") || "7.3.3";

  return new k8s.helm.v3.Chart(
    "argocd",
    {
      chart: "argo-cd",
      version: argocdVersion,
      namespace: namespace.metadata.name,
      fetchOpts: {
        repo: "https://argoproj.github.io/argo-helm",
      },
      values: {
        server: {
          service: {
            type: "LoadBalancer",
          },
        },
        configs: {
          secret: {
            argocdServerAdminPassword: config.requireSecret(
              "argocd_admin_password"
            ),
          },
        },
      },
    },
    { provider }
  );
}

// Deploy Tailscale Operator using Helm
export function deployTailscaleOperator(
  provider: k8s.Provider,
  namespace: k8s.core.v1.Namespace
) {
  const tailscaleVersion = config.get("tailscale_operator_version") || "1.90.6";

  return new k8s.helm.v3.Chart(
    "tailscale-operator",
    {
      chart: "tailscale-operator",
      version: tailscaleVersion,
      namespace: namespace.metadata.name,
      fetchOpts: {
        repo: "https://pkgs.tailscale.com/helmcharts",
      },
      values: {
        oauth: {
          clientId: config.requireSecret("tailscale_oauth_client_id"),
          clientSecret: config.requireSecret("tailscale_oauth_client_secret"),
        },
      },
    },
    { provider }
  );
}

