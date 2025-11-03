# K3s Bootstrap - Troubleshooting Guide

## Common Issues & Solutions

### 1. **kubectl: Unauthorized Error**

**Problem:**
```
error: You must be logged in to the server (Unauthorized)
```

**Solution:**
Update kubeconfig with fresh credentials from the VM:
```bash
ssh -o StrictHostKeyChecking=no azureuser@VM_IP "sudo cat /etc/rancher/k3s/k3s.yaml" | \
  sed 's|server: https://127.0.0.1:6443|server: https://10.10.1.4:6443|g' > ~/.kube/config-azure

# Then use it
export KUBECONFIG=~/.kube/config-azure
kubectl get nodes
```

---

### 2. **Cannot Connect to K3s via Private IP**

**Problem:**
```
Unable to connect to the server: dial tcp 10.10.1.4:6443: i/o timeout
```

**Causes:**
- Not connected to Tailscale
- Tailscale subnet routes not accepted
- Firewall blocking access

**Solution:**
```bash
# 1. Check Tailscale status
tailscale status

# 2. Accept subnet routes
sudo tailscale up --accept-routes --operator=plpbs

# 3. Verify routes are accepted
tailscale status --json | jq '.Self.AllowedIPs'

# 4. Test connectivity
ping 10.10.1.4
```

---

### 3. **Tailscale Operator Stuck in CrashLoopBackOff**

**Problem:**
```
operator-xxx   0/1   CrashLoopBackOff
```

**Causes:**
- OAuth credentials invalid
- OAuth client missing "Devices" permission
- Operator version incompatible with K3s

**Solution:**
```bash
# Check operator logs
kubectl logs -n tailscale deployment/operator

# Verify OAuth credentials
echo $TAILSCALE_OAUTH_CLIENT_ID
echo $TAILSCALE_OAUTH_CLIENT_SECRET

# Update OAuth permissions at:
# https://login.tailscale.com/admin/settings/oauth
# Ensure "Devices" permission is enabled

# Restart operator
kubectl rollout restart deployment/operator -n tailscale
```

---

### 4. **ArgoCD Not Accessible via Tailscale Hostname**

**Problem:**
```
Cannot resolve argocd.armadillo-hamal.ts.net
```

**Causes:**
- Tailscale DNS not enabled
- MagicDNS not configured
- Ingress not created properly

**Solution:**
```bash
# 1. Enable Tailscale DNS
sudo tailscale up --accept-dns=true

# 2. Check Ingress status
kubectl get ingress -n argocd

# 3. Verify Ingress device in Tailscale
tailscale status | grep argocd

# 4. Test DNS resolution
nslookup argocd.armadillo-hamal.ts.net

# 5. If still not working, check Tailscale admin console:
# https://login.tailscale.com/admin/machines
```

---

### 5. **K9s Cannot Connect to Cluster**

**Problem:**
```
Unable to connect to the server: tls: failed to verify certificate
```

**Solution:**
```bash
# 1. Verify kubeconfig is set correctly
echo $KUBECONFIG

# 2. Test with kubectl first
kubectl get nodes

# 3. If kubectl works but k9s doesn't, try:
k9s --insecure-skip-tls-verify

# 4. Update kubeconfig with correct credentials (see issue #1)
```

---

### 6. **Playbook Fails: "Helm repo add" Error**

**Problem:**
```
Error: repository name (tailscale) already exists
```

**Solution:**
This is expected on re-runs. The playbook now handles this gracefully.
If you still get errors:
```bash
# Remove existing repos
helm repo remove tailscale
helm repo remove argo

# Re-run playbook
ansible-playbook -i "IP," ansible/k3s-bootstrap-playbook.yml -u azureuser
```

---

### 7. **K3s Certificate Issues**

**Problem:**
```
x509: certificate signed by unknown authority
```

**Causes:**
- Certificate doesn't include private IP
- Using wrong server address in kubeconfig

**Solution:**
```bash
# Verify certificate includes private IP
ssh -o StrictHostKeyChecking=no azureuser@VM_IP \
  "sudo cat /etc/rancher/k3s/config.yaml"

# Should show:
# tls-san:
#   - 10.10.1.4

# If not present, restart K3s:
ssh -o StrictHostKeyChecking=no azureuser@VM_IP \
  "sudo systemctl restart k3s"
```

---

### 8. **Tailscale Subnet Routes Not Advertised**

**Problem:**
```
Cannot access pod CIDR (10.10.0.0/16) or service CIDR (10.43.0.0/16)
```

**Solution:**
```bash
# Check Connector status
kubectl get connector -n tailscale -o yaml

# Should show:
# subnetRoutes: 10.10.0.0/16,10.43.0.0/16

# If not, check Connector pod logs
kubectl logs -n tailscale ts-k3s-subnet-router-xxx

# Recreate Connector if needed
kubectl delete connector k3s-subnet-router -n tailscale
# Re-run playbook to recreate
```

---

### 9. **Out of Memory or Resource Issues**

**Problem:**
```
Pod evicted due to memory pressure
```

**Solution:**
```bash
# Check node resources
kubectl top nodes
kubectl top pods -A

# Check available resources
kubectl describe node

# If needed, increase VM resources or reduce component replicas
```

---

### 10. **Playbook Timeout Issues**

**Problem:**
```
FAILED - RETRYING: Wait for ArgoCD to be ready (59 retries left)
```

**Solution:**
```bash
# 1. Check pod status
kubectl get pods -n argocd

# 2. Check pod logs
kubectl logs -n argocd argocd-server-xxx

# 3. Increase retry count in playbook if needed
# Edit ansible/k3s-bootstrap-playbook.yml:
# retries: 120  # Increase from 60

# 4. Check VM resources
ssh -o StrictHostKeyChecking=no azureuser@VM_IP "free -h"
```

---

## 🔍 Debugging Commands

```bash
# General cluster health
kubectl get nodes
kubectl get pods -A
kubectl get events -A

# Tailscale debugging
kubectl get connector -n tailscale -o yaml
kubectl logs -n tailscale -l app=operator
kubectl logs -n tailscale ts-k3s-subnet-router-xxx

# ArgoCD debugging
kubectl get pods -n argocd
kubectl logs -n argocd argocd-server-xxx
kubectl get ingress -n argocd

# K3s debugging
ssh -o StrictHostKeyChecking=no azureuser@VM_IP "sudo journalctl -u k3s -n 50"
ssh -o StrictHostKeyChecking=no azureuser@VM_IP "sudo cat /etc/rancher/k3s/config.yaml"

# Tailscale debugging
tailscale status
tailscale status --json | jq '.Self'
sudo tailscale debug derp
```

---

## 📞 Getting Help

1. Check logs: `kubectl logs -n <namespace> <pod-name>`
2. Describe resources: `kubectl describe pod -n <namespace> <pod-name>`
3. Check events: `kubectl get events -A --sort-by='.lastTimestamp'`
4. SSH to VM: `ssh -o StrictHostKeyChecking=no azureuser@VM_IP`
5. Check Tailscale admin: https://login.tailscale.com/admin/machines

