#!/bin/bash
#
# Kong Configuration Script for Atlas Services
#
# This script configures Kong Gateway routes and services for Atlas.
# Run this after both Kong and Atlas stacks are deployed.
#
# Prerequisites:
#   - Kong Admin API running on http://localhost:8001
#   - Atlas services deployed and running
#   - Services accessible on Kong network
#
# Usage:
#   chmod +x stacks/kong/atlas-routes.sh
#   ./stacks/kong/atlas-routes.sh
#
# Configuration:
#   - KONG_ADMIN_URL: Kong Admin API endpoint (default: http://localhost:8001)
#   - CYCLIST_PROFILE_HOST: Cyclist Profile service host (default: atlas-cyclist-profile)
#   - CYCLIST_PROFILE_PORT: Cyclist Profile service port (default: 3000)
#   - DOCS_HOST: Docs service host (default: atlas-docs)
#   - DOCS_PORT: Docs service port (default: 3001)

set -e

# Configuration
KONG_ADMIN_URL="${KONG_ADMIN_URL:-http://localhost:8001}"
CYCLIST_PROFILE_HOST="${CYCLIST_PROFILE_HOST:-atlas-cyclist-profile}"
CYCLIST_PROFILE_PORT="${CYCLIST_PROFILE_PORT:-3000}"
DOCS_HOST="${DOCS_HOST:-atlas-docs}"
DOCS_PORT="${DOCS_PORT:-80}"

echo "🔧 Configuring Kong Gateway for Atlas Services"
echo "Kong Admin URL: $KONG_ADMIN_URL"
echo ""

# ============================================================================
# Cyclist Profile Service Configuration
# ============================================================================
echo "📋 Setting up Cyclist Profile Service..."

# Create Cyclist Profile Service
echo "  → Creating service: cyclist-profile"
curl -s -X POST "$KONG_ADMIN_URL/services" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"cyclist-profile\",
    \"url\": \"http://$CYCLIST_PROFILE_HOST:$CYCLIST_PROFILE_PORT\",
    \"tags\": [\"atlas\", \"api\"]
  }" | jq '.' || echo "  ⚠️  Service may already exist"

echo ""

# Create Cyclist Profile Route
echo "  → Creating route: /api/cyclist-profile"
curl -s -X POST "$KONG_ADMIN_URL/services/cyclist-profile/routes" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"cyclist-profile-route\",
    \"paths\": [\"/api/cyclist-profile\"],
    \"strip_path\": true,
    \"tags\": [\"atlas\", \"api\"]
  }" | jq '.' || echo "  ⚠️  Route may already exist"

echo ""

# ============================================================================
# Documentation Service Configuration
# ============================================================================
echo "📋 Setting up Documentation Service..."

# Create Docs Service
echo "  → Creating service: atlas-docs"
curl -s -X POST "$KONG_ADMIN_URL/services" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"atlas-docs\",
    \"url\": \"http://$DOCS_HOST:$DOCS_PORT\",
    \"tags\": [\"atlas\", \"docs\"]
  }" | jq '.' || echo "  ⚠️  Service may already exist"

echo ""

# Create Docs Route
echo "  → Creating route: /docs"
curl -s -X POST "$KONG_ADMIN_URL/services/atlas-docs/routes" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"docs-route\",
    \"paths\": [\"/docs\"],
    \"strip_path\": false,
    \"tags\": [\"atlas\", \"docs\"]
  }" | jq '.' || echo "  ⚠️  Route may already exist"

echo ""

# ============================================================================
# Verification
# ============================================================================
echo "✅ Kong Configuration Complete!"
echo ""
echo "📊 Configured Services:"
curl -s "$KONG_ADMIN_URL/services" | jq '.data[] | select(.tags[] | contains("atlas")) | {name, url, tags}'

echo ""
echo "🛣️  Configured Routes:"
curl -s "$KONG_ADMIN_URL/routes" | jq '.data[] | select(.tags[] | contains("atlas")) | {name, paths, strip_path, tags}'

echo ""
echo "🌐 Access your services at:"
echo "  - Cyclist Profile API: http://localhost/api/cyclist-profile"
echo "  - Documentation: http://localhost/docs"

