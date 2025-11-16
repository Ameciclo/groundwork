#!/bin/bash
# Script to create Grafana admin credentials secret
# This should be run before deploying the monitoring stack

set -e

NAMESPACE="monitoring"
SECRET_NAME="grafana-admin-credentials"

# Check if secret already exists
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Secret $SECRET_NAME already exists in namespace $NAMESPACE"
    echo "To recreate it, delete the existing secret first:"
    echo "kubectl delete secret $SECRET_NAME -n $NAMESPACE"
    exit 1
fi

# Generate a strong password (32 characters)
ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

echo "Creating Grafana admin credentials secret..."
echo "Username: admin"
echo "Password: $ADMIN_PASSWORD"
echo ""
echo "⚠️  IMPORTANT: Save this password securely! It will not be displayed again."
echo ""

# Create the secret
kubectl create secret generic "$SECRET_NAME" \
    --namespace="$NAMESPACE" \
    --from-literal=admin-user="admin" \
    --from-literal=admin-password="$ADMIN_PASSWORD"

# Add labels
kubectl label secret "$SECRET_NAME" -n "$NAMESPACE" \
    app.kubernetes.io/name=grafana \
    app.kubernetes.io/component=credentials \
    app.kubernetes.io/part-of=monitoring

echo "✅ Secret created successfully!"
echo ""
echo "You can now deploy the monitoring stack:"
echo "kubectl apply -f kubernetes/environments/prod/monitoring-app.yaml"
echo ""
echo "Access Grafana at: https://grafana.armadillo-hamal.ts.net"
echo "Username: admin"
echo "Password: $ADMIN_PASSWORD"
