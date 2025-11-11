/**
 * ArgoCD Applications for Ameciclo
 * Defines GitOps applications for continuous deployment
 */

import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

interface ArgoAppConfig {
  name: string;
  namespace: string;
  repoUrl: string;
  path: string;
  targetRevision?: string;
}

// Create ArgoCD Application
export function createArgoApplication(
  name: string,
  appConfig: ArgoAppConfig,
  provider: k8s.Provider,
  argocdNamespace: pulumi.Input<string>
) {
  return new k8s.apiextensions.CustomResource(
    name,
    {
      apiVersion: "argoproj.io/v1alpha1",
      kind: "Application",
      metadata: {
        name: appConfig.name,
        namespace: argocdNamespace,
        annotations: {
          "notifications.argoproj.io/subscribe.on-deployed.telegram": "",
          "notifications.argoproj.io/subscribe.on-sync-failed.telegram": "",
          "notifications.argoproj.io/subscribe.on-health-degraded.telegram":
            "",
        },
      },
      spec: {
        project: "default",
        source: {
          repoURL: appConfig.repoUrl,
          targetRevision: appConfig.targetRevision || "main",
          path: appConfig.path,
        },
        destination: {
          server: "https://kubernetes.default.svc",
          namespace: appConfig.namespace,
        },
        syncPolicy: {
          automated: {
            prune: true,
            selfHeal: true,
          },
          syncOptions: ["CreateNamespace=true"],
        },
        revisionHistoryLimit: 10,
      },
    },
    { provider }
  );
}

// Deploy all applications
export function deployApplications(
  provider: k8s.Provider,
  argocdNamespace: pulumi.Input<string>,
  argocdChart?: k8s.helm.v3.Chart
) {
  const repoUrl = config.get("git_repo_url") || "https://github.com/Ameciclo/groundwork.git";

  const apps: Record<string, ArgoAppConfig> = {
    strapi: {
      name: "strapi",
      namespace: "strapi",
      repoUrl: repoUrl,
      path: "helm/charts/strapi",
    },
    atlas: {
      name: "atlas",
      namespace: "atlas",
      repoUrl: repoUrl,
      path: "helm/charts/atlas",
    },
    kong: {
      name: "kong",
      namespace: "kong",
      repoUrl: repoUrl,
      path: "helm/charts/kong",
    },
    kestra: {
      name: "kestra",
      namespace: "kestra",
      repoUrl: repoUrl,
      path: "helm/charts/kestra",
    },
  };

  const createdApps: Record<string, k8s.apiextensions.CustomResource> = {};
  const opts = argocdChart ? { provider, dependsOn: [argocdChart] } : { provider };

  for (const [key, appConfig] of Object.entries(apps)) {
    createdApps[key] = createArgoApplication(
      key,
      appConfig,
      provider,
      argocdNamespace
    );
  }

  return createdApps;
}

