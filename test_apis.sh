#!/bin/bash

# Precisely APIs Validation Script
API_BASE_URL="https://api.precisely.com"
CLIENT_ID="4ZsIP45kyB95nZxoO5t0TW5a8xoTuGH1"
CLIENT_SECRET="wxTS09yvX0ESVkQ8"

echo "=== STEP 1: OAuth2 Authentication ==="
echo "Testing token generation..."

AUTH_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=client_credentials")

echo "Auth Response:"
echo "$AUTH_RESPONSE" | jq '.' 2>/dev/null || echo "$AUTH_RESPONSE"

# Extract token
ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token' 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
  echo "ERROR: Failed to obtain access token"
  exit 1
fi

echo ""
echo "✓ Access Token obtained: ${ACCESS_TOKEN:0:20}..."
echo ""

# Test each endpoint
echo "=== STEP 2: Testing Endpoints ==="
echo ""

# Typeahead
echo "--- Typeahead (Autocomplete) ---"
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=1600+Pennsylvania&maxResults=5" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.' 2>/dev/null || echo "Response (raw)"

echo ""
echo "--- Geocode Premium ---"
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC","country":"USA"}}' | jq '.' 2>/dev/null

