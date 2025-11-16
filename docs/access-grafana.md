# Access Grafana and View Traefik Metrics

## 🌐 Access Grafana

**URL:** `https://grafana.armadillo-hamal.ts.net/`

**Credentials:**
- **Username:** `admin`
- **Password:** `ocnrdla89ZiXp3L5g8PmJTPVSjrjyTx3`

## 📊 View Official Traefik Dashboard

1. **Login to Grafana** using the credentials above
2. **Navigate to Dashboards** → Browse
3. **Find "Traefik Official Kubernetes Dashboard"** in the list
4. **Click to open** the dashboard

### Alternative: Direct Dashboard URL
Once logged in, you can access the dashboard directly:
`https://grafana.armadillo-hamal.ts.net/d/traefik-official/traefik-official-kubernetes-dashboard`

## 📈 What You'll See

The official Traefik dashboard includes comprehensive monitoring panels:

### **General Section:**
- **Traefik Instances** - Number of running Traefik instances
- **Requests per Entrypoint** - Traffic by entrypoint (web, websecure)
- **Apdex Score** - Application performance index
- **HTTP Code Distribution** - Pie chart of response codes

### **Performance Metrics:**
- **Top Slow Services** - Services with highest response times
- **Most Requested Services** - Services with highest traffic
- **SLO Monitoring** - Services failing 300ms and 1200ms SLOs

### **HTTP Details:**
- **2xx Responses** - Successful requests over time
- **5xx Responses** - Server errors over time
- **Other HTTP Codes** - 3xx, 4xx responses
- **Request/Response Sizes** - Data transfer metrics
- **Connection Metrics** - Open connections per service/entrypoint

## 🔍 Available Metrics

The official dashboard uses comprehensive Traefik metrics:
- `traefik_service_requests_total` - Total requests by service and status code
- `traefik_entrypoint_requests_total` - Requests by entrypoint
- `traefik_service_request_duration_seconds` - Response time histograms
- `traefik_service_open_connections` - Active connections
- `traefik_entrypoint_open_connections` - Entrypoint connections
- `traefik_config_reloads_total` - Configuration reloads
- `traefik_service_requests_bytes_total` - Request sizes
- `traefik_service_responses_bytes_total` - Response sizes

## 🎯 What to Look For

### **Normal Traffic Patterns:**
- Steady request rates during business hours
- Mostly 200 (success) and 302 (redirect) status codes
- Apdex score above 0.8 (good user experience)
- Response times under 300ms for most services

### **Potential Issues:**
- **High 4xx rates** - Client errors, check application logs
- **High 5xx rates** - Server errors, check backend services
- **Low Apdex score** - Poor user experience, investigate slow services
- **SLO violations** - Services exceeding 300ms or 1200ms thresholds
- **Traffic spikes** - May indicate DDoS or viral content
- **Connection buildup** - May indicate connection leaks

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
