# Access Grafana and View Traefik Metrics

## 🌐 Access Grafana

**URL:** `https://grafana.armadillo-hamal.ts.net/`

**Credentials:**
- **Username:** `admin`
- **Password:** `ocnrdla89ZiXp3L5g8PmJTPVSjrjyTx3`

## 📊 View Traefik Dashboard

1. **Login to Grafana** using the credentials above
2. **Navigate to Dashboards** → Browse
3. **Find "Traefik Metrics Dashboard"** in the list
4. **Click to open** the dashboard

### Alternative: Direct Dashboard URL
Once logged in, you can access the dashboard directly:
`https://grafana.armadillo-hamal.ts.net/d/traefik-metrics/traefik-metrics-dashboard`

## 📈 What You'll See

The Traefik dashboard includes:

### **Panel 1: Request Rate by Service and Status Code**
- Shows requests per second for each service
- Broken down by HTTP status codes (200, 302, 404, etc.)
- Useful for identifying traffic patterns and errors

### **Panel 2: Total Requests**
- Overall request count across all services
- Single stat showing cumulative requests

## 🔍 Available Metrics

The dashboard uses these Traefik metrics:
- `traefik_service_requests_total` - Total requests by service and status code
- `rate(traefik_service_requests_total[5m])` - Request rate over 5 minutes

## 🎯 What to Look For

### **Normal Traffic Patterns:**
- Steady request rates during business hours
- Mostly 200 (success) and 302 (redirect) status codes
- Occasional 404s are normal

### **Potential Issues:**
- **High 4xx rates** - Client errors, check application logs
- **High 5xx rates** - Server errors, check backend services
- **Traffic spikes** - May indicate DDoS or viral content
- **Zero traffic** - Service might be down

## 🔧 Customizing the Dashboard

You can customize the dashboard by:
1. **Clicking the gear icon** (Dashboard settings)
2. **Adding new panels** with additional metrics
3. **Modifying time ranges** (default: last 1 hour)
4. **Setting up alerts** for specific thresholds

## 📊 Additional Traefik Metrics Available

If you want to add more panels, these metrics are available:
- `traefik_service_request_duration_seconds` - Response time
- `traefik_service_requests_bytes_total` - Request size
- `traefik_service_responses_bytes_total` - Response size
- `traefik_entrypoint_requests_total` - Requests by entrypoint

## 🚨 Setting Up Alerts

To get notified of issues:
1. **Go to Alerting** → Alert Rules
2. **Create new rule** based on Traefik metrics
3. **Set thresholds** (e.g., error rate > 5%)
4. **Configure notifications** (email, Slack, etc.)

## 🔄 Refresh Rate

The dashboard refreshes every 30 seconds automatically. You can change this in the dashboard settings if needed.

## 🎉 Next Steps

1. **Explore the data** - Click on different time ranges
2. **Add more panels** - Response time, error rates, etc.
3. **Set up alerts** - Get notified of issues
4. **Create additional dashboards** - For specific services or time periods
