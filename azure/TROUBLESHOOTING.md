# Troubleshooting Guide - Azure Migration

Common issues and solutions during and after migration.

## Terraform Issues

### Error: "Storage account name already exists"

**Problem**: Storage account name is not globally unique.

**Solution**:
```bash
# Check if name is available
az storage account check-name --name ameciclostorage

# If taken, modify terraform.tfvars
storage_account_name = "ameciclostorage2024"

# Re-run terraform
terraform plan
terraform apply
```

### Error: "Container registry name already exists"

**Problem**: Container registry name is not globally unique.

**Solution**:
```bash
# Check if name is available
az acr check-name --name amecicloregistry

# If taken, modify terraform.tfvars
container_registry_name = "amecicloregistry2024"

# Re-run terraform
terraform plan
terraform apply
```

### Error: "Insufficient quota"

**Problem**: Azure subscription doesn't have enough quota for resources.

**Solution**:
```bash
# Check current quota
az vm list-usage --location eastus

# Request quota increase in Azure Portal
# Settings > Quotas > Request quota increase
```

### Error: "Authentication failed"

**Problem**: Azure credentials are invalid or expired.

**Solution**:
```bash
# Re-authenticate
az login

# Verify subscription
az account show

# Update terraform.tfvars with correct credentials
az ad sp create-for-rbac --role="Contributor"
```

## AKS Cluster Issues

### Cluster not accessible

**Problem**: Cannot connect to AKS cluster with kubectl.

**Solution**:
```bash
# Get fresh kubeconfig
az aks get-credentials --resource-group ameciclo-rg \
  --name ameciclo-aks --overwrite-existing

# Verify connection
kubectl cluster-info
kubectl get nodes

# Check kubeconfig location
echo $KUBECONFIG
```

### Nodes not ready

**Problem**: AKS nodes showing "NotReady" status.

**Solution**:
```bash
# Check node status
kubectl get nodes -o wide

# Describe problematic node
kubectl describe node <node-name>

# Check node logs
az aks get-diagnostics --resource-group ameciclo-rg \
  --name ameciclo-aks

# Restart node pool
az aks nodepool restart --resource-group ameciclo-rg \
  --cluster-name ameciclo-aks \
  --nodepool-name default
```

### Pods stuck in pending

**Problem**: Pods not starting, stuck in "Pending" state.

**Solution**:
```bash
# Check pod status
kubectl describe pod <pod-name> -n ameciclo

# Common causes:
# 1. Insufficient resources
kubectl top nodes
kubectl top pods -n ameciclo

# 2. Image pull errors
kubectl logs <pod-name> -n ameciclo

# 3. Volume mount issues
kubectl get pvc -n ameciclo

# Scale down other pods if needed
kubectl scale deployment <deployment> --replicas=0 -n ameciclo
```

## PostgreSQL Issues

### Cannot connect to database

**Problem**: Connection refused or timeout.

**Solution**:
```bash
# Verify database is running
az postgres flexible-server show --resource-group ameciclo-rg \
  --name ameciclo-postgres

# Check firewall rules
az postgres flexible-server firewall-rule list \
  --resource-group ameciclo-rg \
  --name ameciclo-postgres

# Test connectivity from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
nc -zv ameciclo-postgres.postgres.database.azure.com 5432

# Check connection string
terraform output -raw postgresql_connection_string
```

### Database migration failed

**Problem**: Data not imported correctly.

**Solution**:
```bash
# Verify backup file
file atlas_backup.sql
wc -l atlas_backup.sql

# Check database exists
psql -h ameciclo-postgres.postgres.database.azure.com \
  -U psqladmin \
  -l

# Try importing again with verbose output
psql -h ameciclo-postgres.postgres.database.azure.com \
  -U psqladmin \
  -d atlas \
  -f atlas_backup.sql \
  --verbose

# Check for errors
psql -h ameciclo-postgres.postgres.database.azure.com \
  -U psqladmin \
  -d atlas \
  -c "SELECT COUNT(*) FROM information_schema.tables;"
```

### Slow database performance

**Problem**: Queries running slowly.

**Solution**:
```bash
# Check database size
psql -h ameciclo-postgres.postgres.database.azure.com \
  -U psqladmin \
  -d atlas \
  -c "SELECT pg_size_pretty(pg_database_size('atlas'));"

# Check slow queries
psql -h ameciclo-postgres.postgres.database.azure.com \
  -U psqladmin \
  -d atlas \
  -c "SELECT query, calls, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# Upgrade database SKU if needed
az postgres flexible-server update \
  --resource-group ameciclo-rg \
  --name ameciclo-postgres \
  --sku-name B_Standard_B2s
```

## Container Registry Issues

### Cannot push images

**Problem**: Docker push fails to ACR.

**Solution**:
```bash
# Login to ACR
az acr login --name amecicloregistry

# Verify credentials
az acr credential show --resource-group ameciclo-rg \
  --name amecicloregistry

# Check image tag format
docker tag myimage:latest \
  amecicloregistry.azurecr.io/myimage:latest

# Push with verbose output
docker push amecicloregistry.azurecr.io/myimage:latest -v
```

### Cannot pull images in AKS

**Problem**: ImagePullBackOff error.

**Solution**:
```bash
# Verify image exists in ACR
az acr repository list --resource-group ameciclo-rg \
  --name amecicloregistry

# Check image pull secret
kubectl get secrets -n ameciclo

# Recreate image pull secret
kubectl delete secret acr-secret -n ameciclo
kubectl create secret docker-registry acr-secret \
  --docker-server=amecicloregistry.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  -n ameciclo

# Verify pod can pull
kubectl describe pod <pod-name> -n ameciclo
```

## Service Issues

### Service not accessible

**Problem**: Cannot reach service via LoadBalancer or Ingress.

**Solution**:
```bash
# Check service status
kubectl get svc -n ameciclo

# Get external IP
kubectl get svc kong-proxy -n ameciclo

# Test connectivity
curl http://<EXTERNAL_IP>:80

# Check service endpoints
kubectl get endpoints -n ameciclo

# Verify pod is running
kubectl get pods -n ameciclo -l app=kong

# Check service logs
kubectl logs -f svc/kong-proxy -n ameciclo
```

### Ingress not working

**Problem**: Ingress rules not routing traffic.

**Solution**:
```bash
# Check ingress status
kubectl get ingress -n ameciclo

# Describe ingress
kubectl describe ingress <ingress-name> -n ameciclo

# Check ingress controller
kubectl get pods -n ingress-nginx

# View ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verify DNS resolution
nslookup kong-admin.example.com

# Test ingress directly
curl -H "Host: kong-admin.example.com" http://<INGRESS_IP>
```

## Storage Issues

### PersistentVolumeClaim stuck in pending

**Problem**: PVC not binding to PV.

**Solution**:
```bash
# Check PVC status
kubectl get pvc -n ameciclo

# Describe PVC
kubectl describe pvc <pvc-name> -n ameciclo

# Check available storage classes
kubectl get storageclass

# Check PV status
kubectl get pv

# Manually create PV if needed
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: manual-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  azureDisk:
    kind: Managed
    diskName: myDisk
    diskURI: /subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/disks/myDisk
EOF
```

## Monitoring Issues

### Cannot access Grafana/Prometheus

**Problem**: Services not accessible.

**Solution**:
```bash
# Port forward to service
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Access via localhost:3000

# Check service status
kubectl get svc -n monitoring

# Check pod logs
kubectl logs -f deployment/grafana -n monitoring
```

## DNS Issues

### DNS not resolving

**Problem**: Cannot resolve service names.

**Solution**:
```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check DNS resolution from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
nslookup kubernetes.default
nslookup cyclist-profile.ameciclo.svc.cluster.local

# Check DNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## Performance Issues

### High CPU/Memory usage

**Problem**: Pods consuming excessive resources.

**Solution**:
```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n ameciclo

# Check resource requests/limits
kubectl describe pod <pod-name> -n ameciclo

# Update resource limits
kubectl set resources deployment cyclist-profile \
  --limits=cpu=1000m,memory=1Gi \
  --requests=cpu=100m,memory=256Mi \
  -n ameciclo

# Check for memory leaks
kubectl logs -f <pod-name> -n ameciclo | grep -i memory
```

### Slow API responses

**Problem**: APIs responding slowly.

**Solution**:
```bash
# Check pod logs for errors
kubectl logs -f deployment/cyclist-profile -n ameciclo

# Check database performance
# (See PostgreSQL section above)

# Check network latency
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
ping cyclist-profile.ameciclo.svc.cluster.local

# Scale up replicas
kubectl scale deployment cyclist-profile --replicas=3 -n ameciclo
```

## General Debugging

### Get comprehensive cluster info

```bash
# Cluster info
kubectl cluster-info dump --output-directory=./cluster-dump

# Node info
kubectl describe nodes

# Pod info
kubectl describe pods -n ameciclo

# Events
kubectl get events -n ameciclo --sort-by='.lastTimestamp'

# Resource usage
kubectl top nodes
kubectl top pods -n ameciclo
```

### Enable debug logging

```bash
# Increase log verbosity
kubectl logs -f <pod-name> -n ameciclo --tail=100

# Check pod events
kubectl describe pod <pod-name> -n ameciclo

# Check previous logs (if pod crashed)
kubectl logs <pod-name> -n ameciclo --previous
```

## Getting Help

If issues persist:

1. Check Azure Portal for resource status
2. Review Azure Activity Log for errors
3. Check AKS cluster diagnostics
4. Review Kubernetes events
5. Contact Azure Support

### Useful Commands for Support

```bash
# Collect diagnostics
az aks get-diagnostics --resource-group ameciclo-rg \
  --name ameciclo-aks

# Export cluster info
kubectl cluster-info dump --output-directory=./cluster-info

# Export pod logs
kubectl logs <pod-name> -n ameciclo > pod-logs.txt

# Export events
kubectl get events -n ameciclo > events.txt
```

