# Tailscale Setup for K3s Cluster

This guide documents the Tailscale Kubernetes Operator setup on your Azure K3s cluster for VPN access to ArgoCD and other internal services.

## Status: ✅ COMPLETE

- ✅ Tailscale Operator installed and running
- ✅ ArgoCD exposed via Tailscale Service
- ✅ Operator joined tailnet with tag:k8s-operator
- ✅ Proxy pod for ArgoCD running

## Prerequisites

- Tailscale account (free tier available at https://tailscale.com)
- kubectl access to your K3s cluster
- Helm 3.x installed

## Step 1: Create Tailscale OAuth Credentials ✅

1. Go to https://login.tailscale.com/admin/settings/oauth
2. Click **"Generate credential"**
3. In the dialog:
   - **Scopes**: Select `Devices Core` and `Auth Keys write`
   - **Tags**: Select `tag:k8s-operator`
4. Click **"Generate"**
5. Copy both the **Client ID** and **Client Secret**

**Status**: ✅ Completed with credentials:
- Client ID: `kAHfawuK2811CNTRL`
- Client Secret: `tskey-client-kAHfawuK2811CNTRL-BCthpidTYZP7w48NJhQpZPW6A6ZjbuLi6`

## Step 2: Update Tailscale Policy File ✅

1. Go to https://login.tailscale.com/admin/acls
2. Add the following to your policy file (if not already present):

```json
{
  "tagOwners": {
    "tag:k8s-operator": [],
    "tag:k8s": ["tag:k8s-operator"]
  }
}
```

3. Click **"Save"**

**Status**: ✅ Completed - Tags added to policy file

## Step 3: Add Tailscale Helm Repository ✅

```bash
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update
```

**Status**: ✅ Completed

## Step 4: Install Tailscale Operator ✅

```bash
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId="kAHfawuK2811CNTRL" \
  --set-string oauth.clientSecret="tskey-client-kAHfawuK2811CNTRL-BCthpidTYZP7w48NJhQpZPW6A6ZjbuLi6" \
  --wait
```

**Status**: ✅ Completed
- Operator deployed to `tailscale` namespace
- Operator pod: `operator-588944759-xvlmk` (Running)
- Operator joined tailnet with tag:k8s-operator

## Step 5: Verify Operator Installation ✅

```bash
# Check operator pod
kubectl get pods -n tailscale

# Check operator logs
kubectl logs -n tailscale deployment/operator

# Verify operator joined tailnet
# Go to https://login.tailscale.com/admin/machines
# Look for a machine named "tailscale-operator" with tag:k8s-operator
```

**Status**: ✅ Verified - Operator running and healthy

## Step 6: Expose ArgoCD via Tailscale Service ✅

Created a Tailscale Service to expose ArgoCD:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: argocd-tailscale
  namespace: argocd
  annotations:
    tailscale.com/expose: "true"
    tailscale.com/hostname: argocd
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: argocd-server
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
```

**Status**: ✅ Completed
- Service created: `argocd-tailscale` (ClusterIP: 10.43.172.79)
- Proxy StatefulSet: `ts-argocd-tailscale-vb8bf` (Running)
- Proxy pod: `ts-argocd-tailscale-vb8bf-0` (Running)

## Step 7: Access ArgoCD via Tailscale ✅

1. ✅ Tailscale installed on your local machine
2. ✅ Connected to Tailscale
3. Access ArgoCD at: `http://argocd`

## Verification ✅

```bash
# Check Tailscale Service
kubectl get svc -n argocd argocd-tailscale

# Check Tailscale proxy pod
kubectl get pods -n tailscale

# Check Tailscale proxy logs
kubectl logs -n tailscale -l app=ts-argocd-tailscale-vb8bf
```

**Status**: ✅ All components verified running

## Troubleshooting

### Operator not joining tailnet
- Check logs: `kubectl logs -n tailscale deployment/tailscale-operator`
- Verify OAuth credentials are correct
- Check policy file has correct tags

### Can't access ArgoCD via Tailscale
- Verify you're connected to Tailscale on your local machine
- Check Tailscale proxy pod is running: `kubectl get pods -n tailscale`
- Check proxy logs: `kubectl logs -n tailscale -l tailscale.com/parent-resource=argocd-tailscale`

### DNS not resolving
- Verify MagicDNS is enabled in Tailscale admin console
- Try accessing by IP instead of hostname

## Next Steps

Once Tailscale is working, you can:
1. Expose Kong Admin API via Tailscale Ingress
2. Expose other internal services
3. Set up Tailscale exit nodes for additional security
4. Configure Tailscale ACLs for fine-grained access control

## References

- [Tailscale Kubernetes Operator Docs](https://tailscale.com/kb/1236/kubernetes-operator)
- [Tailscale OAuth Clients](https://tailscale.com/kb/1215/oauth-clients)
- [Tailscale Ingress](https://tailscale.com/kb/1439/kubernetes-operator-cluster-ingress)

