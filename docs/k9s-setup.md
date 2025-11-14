# K9s Setup - Local Cluster Access

This guide shows you how to access the K3s cluster from your local machine using k9s.

## Prerequisites

- ✅ Infrastructure deployed (Pulumi)
- ✅ K3s provisioned (Ansible)
- ✅ Tailscale routes accepted on local machine

## Step 1: Install k9s

### macOS
```bash
brew install k9s
```

### Linux
```bash
# Download latest release
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz -C /tmp
sudo mv /tmp/k9s /usr/local/bin/
```

## Step 2: Get Kubeconfig from K3s VM

### Option A: Copy kubeconfig directly

```bash
# Get K3s VM IP
cd infrastructure/pulumi
K3S_IP=$(pulumi stack output k3sPublicIp)

# Copy kubeconfig
scp azureuser@$K3S_IP:~/.kube/config ~/.kube/k3s-config

# Update server URL to use Tailscale
# The kubeconfig uses 127.0.0.1, we need to change it to the private IP
sed -i.bak 's|https://127.0.0.1:6443|https://10.10.1.4:6443|g' ~/.kube/k3s-config
```

### Option B: Manual setup

```bash
# SSH into K3s VM
ssh azureuser@$K3S_IP

# Display kubeconfig
cat ~/.kube/config
```

Copy the output and save it to `~/.kube/k3s-config` on your local machine.

Then edit the file and change:
```yaml
server: https://127.0.0.1:6443
```

To:
```yaml
server: https://10.10.1.4:6443
```

## Step 3: Accept Tailscale Routes

Make sure you've accepted Tailscale subnet routes:

```bash
sudo tailscale up --accept-routes
```

Verify you can reach the K3s API:
```bash
curl -k https://10.10.1.4:6443
```

You should see: `{"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure"...`

## Step 4: Test kubectl Access

```bash
# Set kubeconfig
export KUBECONFIG=~/.kube/k3s-config

# Test connection
kubectl get nodes
```

Expected output:
```
NAME           STATUS   ROLES                  AGE   VERSION
ameciclo-k3s   Ready    control-plane,master   10m   v1.32.4+k3s1
```

## Step 5: Launch k9s

```bash
# Use the k3s config
export KUBECONFIG=~/.kube/k3s-config
k9s
```

Or specify the config directly:
```bash
k9s --kubeconfig ~/.kube/k3s-config
```

## Step 6: Make it Permanent (Optional)

### Option A: Merge with default kubeconfig

```bash
# Backup existing config
cp ~/.kube/config ~/.kube/config.backup

# Merge configs
KUBECONFIG=~/.kube/config:~/.kube/k3s-config kubectl config view --flatten > ~/.kube/config.merged
mv ~/.kube/config.merged ~/.kube/config

# Set k3s as default context
kubectl config use-context default
```

### Option B: Use kubectx/kubens

```bash
# Install kubectx
brew install kubectx

# Switch between contexts
kubectx default  # k3s cluster
kubectx -        # previous context
```

### Option C: Add alias

Add to your `~/.zshrc` or `~/.bashrc`:
```bash
alias k9s-k3s='KUBECONFIG=~/.kube/k3s-config k9s'
alias kubectl-k3s='KUBECONFIG=~/.kube/k3s-config kubectl'
```

Then:
```bash
source ~/.zshrc
k9s-k3s
```

## Troubleshooting

### "Unable to connect to the server"

1. Check Tailscale routes are accepted:
   ```bash
   tailscale status
   sudo tailscale up --accept-routes
   ```

2. Verify you can reach the K3s API:
   ```bash
   curl -k https://10.10.1.4:6443
   ```

3. Check the server URL in kubeconfig:
   ```bash
   grep server ~/.kube/k3s-config
   ```
   Should be: `https://10.10.1.4:6443`

### "x509: certificate is valid for ... not 10.10.1.4"

The K3s certificate includes the private IP. If you still get this error, you can:

1. Use `--insecure-skip-tls-verify` (not recommended):
   ```bash
   kubectl --insecure-skip-tls-verify get nodes
   ```

2. Or regenerate K3s certificates (requires re-provisioning)

### k9s shows "Boom!!"

This usually means connection issues. Check:
```bash
kubectl get nodes
```

If kubectl works but k9s doesn't, try:
```bash
k9s --headless
```

## k9s Quick Reference

Once in k9s:

- `:pods` - View pods
- `:svc` - View services
- `:deploy` - View deployments
- `:ns` - View namespaces
- `/` - Filter
- `l` - View logs
- `d` - Describe
- `e` - Edit
- `?` - Help
- `:q` - Quit

## Additional Resources

- [k9s Documentation](https://k9scli.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Tailscale Kubernetes](https://tailscale.com/kb/1185/kubernetes)

