# Uptime Kuma - Status Page & Monitoring

Self-hosted uptime monitoring and status page for Ameciclo services.

## 🌐 Access

**Public URL:** https://status.az.ameciclo.org

**First-time Setup:**
1. Visit https://status.az.ameciclo.org
2. Create admin account (first user becomes admin)
3. Set a strong password
4. Configure monitors

## 📊 What to Monitor

### Recommended Monitors

**1. Strapi CMS**
- Type: HTTP(s)
- URL: `https://strapi.ameciclo.org/admin`
- Interval: 60 seconds
- Expected Status: 200

**2. Atlas API**
- Type: HTTP(s)
- URL: `https://api.ameciclo.org/health`
- Interval: 60 seconds
- Expected Status: 200

**3. Zitadel Auth**
- Type: HTTP(s)
- URL: `https://auth.ameciclo.org`
- Interval: 60 seconds
- Expected Status: 200

**4. ArgoCD**
- Type: HTTP(s)
- URL: `https://argocd.armadillo-hamal.ts.net`
- Interval: 300 seconds (5 min)
- Expected Status: 200
- Note: Only accessible via Tailscale

**5. Traefik Dashboard**
- Type: HTTP(s)
- URL: `https://traefik.armadillo-hamal.ts.net/dashboard/`
- Interval: 300 seconds (5 min)
- Expected Status: 200
- Note: Only accessible via Tailscale

**6. Grafana**
- Type: HTTP(s)
- URL: `https://grafana.armadillo-hamal.ts.net`
- Interval: 300 seconds (5 min)
- Expected Status: 200
- Note: Only accessible via Tailscale

**7. K3s Cluster**
- Type: TCP Port
- Hostname: `10.10.1.4`
- Port: `6443`
- Interval: 120 seconds (2 min)
- Note: Kubernetes API server

**8. PostgreSQL Database**
- Type: TCP Port
- Hostname: `<postgres-private-ip>`
- Port: `5432`
- Interval: 120 seconds (2 min)

## 🔔 Notification Setup

### Telegram Notifications

1. **Create Telegram Bot:**
   - Message @BotFather on Telegram
   - Send `/newbot`
   - Follow instructions to create bot
   - Save the bot token

2. **Get Chat ID:**
   - Message your bot
   - Visit: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
   - Find your `chat_id` in the response

3. **Configure in Uptime Kuma:**
   - Settings → Notifications
   - Add Notification
   - Type: Telegram
   - Bot Token: `<your_bot_token>`
   - Chat ID: `<your_chat_id>`
   - Test notification

4. **Apply to Monitors:**
   - Edit each monitor
   - Notifications → Select your Telegram notification
   - Save

### Other Notification Options

- **Email** - SMTP configuration
- **Slack** - Webhook URL
- **Discord** - Webhook URL
- **Webhook** - Custom HTTP endpoint
- **Pushover** - Mobile push notifications
- **Gotify** - Self-hosted push notifications

## 📈 Status Page

### Create Public Status Page

1. **Settings → Status Pages**
2. Click "Add New Status Page"
3. Configure:
   - Slug: `ameciclo` (URL will be: `/status/ameciclo`)
   - Title: "Ameciclo Services Status"
   - Description: "Real-time status of Ameciclo infrastructure"
   - Theme: Choose your preference
4. Add monitors to display
5. Save

**Public URL:** https://status.az.ameciclo.org/status/ameciclo

### Customize Status Page

- **Custom Domain:** Already configured (status.az.ameciclo.org)
- **Custom CSS:** Settings → Appearance
- **Custom Footer:** Add links, contact info
- **Incident History:** Automatically tracked

## 🔒 Security

### Current Setup

✅ **Rate Limiting** - 30 requests/min average, 60 burst  
✅ **HTTPS** - Let's Encrypt certificate via Traefik  
✅ **Strong Password** - Set during first login  
✅ **Public Read-Only** - Status page is public, admin is protected  

### Best Practices

1. **Strong Admin Password**
   - Use password manager
   - At least 16 characters
   - Mix of letters, numbers, symbols

2. **Disable Registration**
   - Settings → Security
   - Disable "Allow Registration"
   - Only admin can create accounts

3. **Two-Factor Authentication**
   - Settings → Security
   - Enable 2FA for admin account

4. **Regular Backups**
   - Data stored in PVC: `/app/data`
   - Backup the SQLite database regularly

## 💾 Backup & Restore

### Backup

```bash
# Create backup of Uptime Kuma data
kubectl exec -n monitoring deploy/uptime-kuma -- tar czf /tmp/backup.tar.gz /app/data

# Copy backup to local machine
kubectl cp monitoring/uptime-kuma-<pod-name>:/tmp/backup.tar.gz ./uptime-kuma-backup-$(date +%Y%m%d).tar.gz
```

### Restore

```bash
# Copy backup to pod
kubectl cp ./uptime-kuma-backup.tar.gz monitoring/uptime-kuma-<pod-name>:/tmp/backup.tar.gz

# Restore data
kubectl exec -n monitoring deploy/uptime-kuma -- tar xzf /tmp/backup.tar.gz -C /
kubectl rollout restart -n monitoring deploy/uptime-kuma
```

## 🐛 Troubleshooting

### Can't Access Status Page

**Check ingress:**
```bash
kubectl get ingress -n monitoring uptime-kuma
```

**Check DNS:**
```bash
dig status.az.ameciclo.org
```

Should point to your K3s LoadBalancer IP.

### Monitor Shows Down (But Service is Up)

**Check from pod:**
```bash
kubectl exec -n monitoring deploy/uptime-kuma -- wget -qO- https://your-service.com
```

**Common issues:**
- Firewall blocking outbound requests
- DNS resolution issues
- Certificate validation errors

### High Memory Usage

Uptime Kuma uses SQLite, which can grow over time.

**Check database size:**
```bash
kubectl exec -n monitoring deploy/uptime-kuma -- du -sh /app/data
```

**Optimize:**
- Reduce monitor frequency
- Reduce retention period
- Clean old data: Settings → Maintenance

## 📊 Integration with Grafana

You can visualize Uptime Kuma data in Grafana:

1. **Export Metrics** - Uptime Kuma has Prometheus exporter
2. **Create Dashboard** - Show uptime percentage, response times
3. **Combine Data** - Correlate uptime with Traefik metrics

## 🔧 Advanced Configuration

### Custom Monitor Types

- **HTTP(s)** - Web services, APIs
- **TCP Port** - Database, SSH, custom services
- **Ping** - ICMP ping (requires NET_RAW capability)
- **DNS** - DNS resolution checks
- **Docker Container** - Monitor container health
- **Keyword** - Check for specific text in response

### Maintenance Windows

Schedule maintenance to prevent false alerts:

1. Edit monitor
2. Maintenance → Add Maintenance
3. Set date/time range
4. Notifications will be paused during maintenance

## 📚 Resources

- [Uptime Kuma Documentation](https://github.com/louislam/uptime-kuma/wiki)
- [Notification Setup Guide](https://github.com/louislam/uptime-kuma/wiki/Notification-Setup)
- [Status Page Guide](https://github.com/louislam/uptime-kuma/wiki/Status-Page)

