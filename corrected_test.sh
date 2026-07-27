#!/bin/bash

API_BASE_URL="https://api.precisely.com"
CLIENT_ID="4ZsIP45kyB95nZxoO5t0TW5a8xoTuGH1"
CLIENT_SECRET="wxTS09yvX0ESVkQ8"
OUTPUT_DIR="/private/tmp/claude-501/-Users-skp/40e0b46e-f6fa-4d7d-befa-e3af889ed4c0/scratchpad/api_evidence_v2"

mkdir -p "$OUTPUT_DIR"

# Get token
AUTH_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=client_credentials")

ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
echo "Token obtained: ${ACCESS_TOKEN:0:15}..."

# Test Typeahead with proper parameters
echo "Typeahead (with country)..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=pennsylvania&country=US&maxResults=5" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" > "$OUTPUT_DIR/typeahead_fixed.txt" 2>&1

# Test Geocode with corrected payload
echo "Geocode Premium (corrected)..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "addresses": [
      {
        "mainAddress": {
          "addressLine1": "1600 Pennsylvania Avenue NW",
          "city": "Washington",
          "state": "DC",
          "country": "USA"
        }
      }
    ]
  }' > "$OUTPUT_DIR/geocode_premium_fixed.txt" 2>&1

# Test with malformed JSON
echo "Geocode (malformed JSON test)..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{invalid json}' > "$OUTPUT_DIR/geocode_malformed.txt" 2>&1

# Test with missing required field
echo "Geocode (missing required field)..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{}' > "$OUTPUT_DIR/geocode_missing_field.txt" 2>&1

# Test invalid token
echo "Testing with invalid token..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=test&country=US" \
  -H "Authorization: Bearer INVALID_TOKEN_12345" \
  -H "Content-Type: application/json" > "$OUTPUT_DIR/invalid_token.txt" 2>&1

# Test missing authorization header
echo "Testing without auth header..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=test&country=US" \
  -H "Content-Type: application/json" > "$OUTPUT_DIR/missing_auth.txt" 2>&1

# List all results
echo ""
echo "=== CORRECTED TEST RESULTS ==="
ls -lh "$OUTPUT_DIR"
echo ""
echo "Content samples:"
for file in "$OUTPUT_DIR"/*.txt; do
  echo ""
  echo "--- $(basename $file) ---"
  cat "$file" | head -c 300
  echo ""
done

