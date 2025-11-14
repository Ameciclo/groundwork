# DNS Configuration for Uptime Kuma

## 📋 Required DNS Record

To make Uptime Kuma accessible at `https://status.az.ameciclo.org`, you need to configure DNS.

## 🔍 Get K3s LoadBalancer IP

First, get the external IP of your Traefik LoadBalancer:

```bash
# SSH into K3s VM
ssh azureuser@135.234.25.108

# Get Traefik service external IP
kubectl get svc traefik -n kube-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

**Expected output:** `10.10.1.4`

## 🌐 DNS Configuration Options

### Option 1: Azure DNS (Recommended if using Azure)

If you manage `ameciclo.org` DNS in Azure:

1. **Go to Azure Portal**
2. **Navigate to:** DNS zones → `ameciclo.org`
3. **Add Record Set:**
   - Name: `status.az`
   - Type: `A`
   - TTL: `300` (5 minutes)
   - IP Address: `10.10.1.4`
4. **Save**

### Option 2: External DNS Provider

If you use another DNS provider (Cloudflare, GoDaddy, etc.):

1. **Login to your DNS provider**
2. **Add A Record:**
   - Host/Name: `status.az`
   - Type: `A`
   - Value/Points to: `10.10.1.4`
   - TTL: `300` or `Auto`
3. **Save**

### Option 3: Subdomain Delegation

If `az.ameciclo.org` is a separate zone:

1. **Add A Record in `az.ameciclo.org` zone:**
   - Name: `status`
   - Type: `A`
   - Value: `10.10.1.4`
   - TTL: `300`

## ✅ Verify DNS Configuration

### Check DNS Propagation

```bash
# Check DNS resolution
dig status.az.ameciclo.org

# Or using nslookup
nslookup status.az.ameciclo.org

# Or using host
host status.az.ameciclo.org
```

**Expected output:**
```
status.az.ameciclo.org. 300 IN A 10.10.1.4
```

### Test from Different Locations

Use online tools to check DNS propagation:
- https://dnschecker.org
- https://www.whatsmydns.net

Enter: `status.az.ameciclo.org`

## 🔒 Important Notes

### Private IP Address

⚠️ **Note:** `10.10.1.4` is a **private IP address** (RFC 1918).

This means:
- ✅ **Works:** If you're on the same network or VPN (Tailscale)
- ❌ **Doesn't work:** From public internet

### Making it Publicly Accessible

To make Uptime Kuma accessible from the public internet, you need:

**Option A: Azure Public IP + Load Balancer**

1. Create Azure Public IP
2. Create Azure Load Balancer
3. Forward traffic to K3s VM
4. Update DNS to point to public IP

**Option B: Tailscale Funnel (Easiest)**

Use Tailscale Funnel to expose the service publicly:

```yaml
# Update uptime-kuma-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: uptime-kuma
  namespace: monitoring
  annotations:
    tailscale.com/funnel: "true"  # Enable public access
spec:
  ingressClassName: tailscale
  # ... rest of config
```

Then DNS would point to Tailscale's public endpoint.

**Option C: Cloudflare Tunnel**

Use Cloudflare Tunnel to expose the service:
- No public IP needed
- Free tier available
- DDoS protection included

## 🎯 Current Setup (Private Network)

**Current configuration:**
- Uptime Kuma: `https://status.az.ameciclo.org`
- Traefik LoadBalancer: `10.10.1.4` (private)
- Access: Only from Tailscale VPN or same network

**To access:**
1. Connect to Tailscale VPN
2. Accept subnet routes: `sudo tailscale up --accept-routes`
3. Visit: `https://status.az.ameciclo.org`

## 📝 Recommended Approach

For a **public status page**, I recommend:

### Option: Use Tailscale Funnel

1. **Update ingress to use Tailscale Funnel:**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: uptime-kuma
     namespace: monitoring
     annotations:
       tailscale.com/funnel: "true"
   spec:
     ingressClassName: tailscale
     defaultBackend:
       service:
         name: uptime-kuma
         port:
           number: 3001
   ```

2. **Get Tailscale public URL:**
   ```bash
   kubectl get ingress uptime-kuma -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
   ```

3. **Create CNAME record:**
   - Name: `status.az`
   - Type: `CNAME`
   - Value: `<tailscale-hostname>`

**Benefits:**
- ✅ No Azure public IP needed (save costs)
- ✅ Automatic HTTPS
- ✅ DDoS protection via Tailscale
- ✅ Easy to set up

## 🔧 Alternative: Keep Private, Use Tailscale

If you want to keep it private (team only):

1. **Keep current Tailscale ingress**
2. **Access via:** `https://uptime-kuma.armadillo-hamal.ts.net`
3. **No DNS configuration needed**
4. **Only accessible via Tailscale VPN**

This is more secure but requires VPN access.

## 📚 Next Steps

1. **Decide:** Public or private access?
2. **Configure DNS** according to your choice
3. **Deploy monitoring stack**
4. **Test access** to Uptime Kuma
5. **Set up monitors** for your services

---

**Need help deciding?** Consider:
- **Public:** Good for showing status to users/customers
- **Private:** Better for internal monitoring, more secure

