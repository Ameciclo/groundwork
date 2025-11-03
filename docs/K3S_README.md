# K3s Bootstrap Documentation

This directory contains comprehensive documentation for the K3s bootstrap playbook.

## 📖 Documentation Files

### 1. **K3S_BOOTSTRAP_SUMMARY.md** ⭐ START HERE
Complete overview of the K3s bootstrap solution.
- What was accomplished
- Architecture diagram
- Quick start guide
- Configuration options
- Maintenance procedures
- Verification checklist

**Read this first to understand the complete solution.**

### 2. **K3S_BOOTSTRAP_IMPROVEMENTS.md**
Details about improvements made to the playbook.
- All improvements implemented
- 10 future enhancement suggestions
- Quick reference guide
- Maintenance tips
- Usage examples

**Read this to understand what was improved and what's planned.**

### 3. **K3S_TROUBLESHOOTING.md**
Comprehensive troubleshooting guide.
- 10 common issues with solutions
- Debugging commands
- Getting help resources
- Log inspection tips

**Read this when you encounter issues.**

## 🚀 Quick Start

### 1. Read the Summary
Start with `K3S_BOOTSTRAP_SUMMARY.md` to understand the architecture and capabilities.

### 2. Deploy the Cluster
```bash
cd /home/plpbs/Projetos/Ameciclo/groundwork

TAILSCALE_OAUTH_CLIENT_ID="k4W58Ys53J11CNTRL" \
TAILSCALE_OAUTH_CLIENT_SECRET="tskey-client-..." \
ansible-playbook -i "VM_IP," ansible/k3s-bootstrap-playbook.yml -u azureuser
```

### 3. Accept Tailscale Routes
```bash
sudo tailscale up --accept-routes --operator=plpbs
```

### 4. Verify Installation
```bash
kubectl get nodes
k9s
```

### 5. Access ArgoCD
```
https://argocd.armadillo-hamal.ts.net
```

## 🔍 Finding Information

### I want to...

**Understand the architecture**
→ Read: K3S_BOOTSTRAP_SUMMARY.md

**See what was improved**
→ Read: K3S_BOOTSTRAP_IMPROVEMENTS.md

**Get ideas for future enhancements**
→ Read: K3S_BOOTSTRAP_IMPROVEMENTS.md (Future Improvements section)

**Troubleshoot an issue**
→ Read: K3S_TROUBLESHOOTING.md

**Configure optional components**
→ Read: K3S_BOOTSTRAP_IMPROVEMENTS.md (Quick Reference section)

**Update component versions**
→ Read: K3S_BOOTSTRAP_SUMMARY.md (Maintenance section)

**Debug a problem**
→ Read: K3S_TROUBLESHOOTING.md (Debugging Commands section)

## 📋 Common Tasks

### Accept Tailscale Subnet Routes
```bash
sudo tailscale up --accept-routes --operator=plpbs
```

### Check Cluster Health
```bash
kubectl get nodes
kubectl get pods -A
```

### View Cluster with k9s
```bash
k9s
```

### Access ArgoCD
```
https://argocd.armadillo-hamal.ts.net
```

### Update K3s Version
1. Edit `ansible/k3s-bootstrap-playbook.yml`
2. Change `k3s_version: "v1.33.0+k3s1"`
3. Run playbook again

### Skip ArgoCD Installation
```bash
ansible-playbook ... -e "install_argocd=false"
```

### Skip Tailscale Operator
```bash
ansible-playbook ... -e "install_tailscale_operator=false"
```

## 🔧 Playbook Location

The playbook is located at:
```
ansible/k3s-bootstrap-playbook.yml
```

## 📊 Key Files

```
groundwork/
├── ansible/
│   └── k3s-bootstrap-playbook.yml    ← Main playbook
├── docs/
│   ├── K3S_README.md                 ← This file
│   ├── K3S_BOOTSTRAP_SUMMARY.md      ← Overview & architecture
│   ├── K3S_BOOTSTRAP_IMPROVEMENTS.md ← Improvements & future ideas
│   └── K3S_TROUBLESHOOTING.md        ← Troubleshooting guide
└── ...
```

## 🎯 What's Included

✓ K3s v1.32.4+k3s1
✓ Tailscale Operator for VPN-based access
✓ ArgoCD v7.3.3 for GitOps
✓ Tailscale Ingress for private access
✓ Automated deployment via Ansible
✓ Comprehensive documentation
✓ Troubleshooting guides

## 🔐 Security

- K3s API only accessible via Tailscale VPN
- All traffic encrypted through Tailscale
- No public IP exposure
- OAuth-based authentication
- Private database connectivity

## 📞 Need Help?

1. **Check the troubleshooting guide**: K3S_TROUBLESHOOTING.md
2. **Review logs**: `kubectl logs -n <namespace> <pod>`
3. **Check Tailscale status**: `tailscale status`
4. **Verify connectivity**: `ping 10.10.1.4`

## 🔄 Maintenance

### Regular Checks
- Monitor cluster: `kubectl get nodes`
- Check pods: `kubectl get pods -A`
- Review logs: `kubectl logs -n <namespace> <pod>`

### Updates
- Update K3s: Change version in playbook, re-run
- Update components: Change versions, re-run
- Backup: Use Velero (future enhancement)

## 📚 External Resources

- **K3s Docs**: https://docs.k3s.io/
- **Tailscale Operator**: https://tailscale.com/kb/1236/kubernetes-operator
- **ArgoCD Docs**: https://argo-cd.readthedocs.io/
- **Ansible Docs**: https://docs.ansible.com/

## 💡 Tips

1. **Idempotent Playbook**: Safe to run multiple times
2. **Optional Components**: Use `-e` flags to skip components
3. **Tailscale Routes**: Must accept routes on local machine
4. **Private IP Access**: K3s API uses 10.10.1.4 via Tailscale
5. **ArgoCD Access**: Use Tailscale hostname, not IP

## 🎉 Next Steps

1. Accept Tailscale routes
2. Access ArgoCD
3. Configure Git repository
4. Deploy applications
5. Monitor cluster
6. Plan enhancements

---

**Last Updated**: November 3, 2025
**K3s Version**: v1.32.4+k3s1
**ArgoCD Version**: 7.3.3
**Tailscale Operator Version**: 1.90.6

