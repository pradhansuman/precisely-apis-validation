#!/bin/bash

API_BASE_URL="https://api.precisely.com"
CLIENT_ID="4ZsIP45kyB95nZxoO5t0TW5a8xoTuGH1"
CLIENT_SECRET="wxTS09yvX0ESVkQ8"
REPORT_DIR="/private/tmp/claude-501/-Users-skp/40e0b46e-f6fa-4d7d-befa-e3af889ed4c0/scratchpad/api_validation_report"

mkdir -p "$REPORT_DIR"

# Get token
AUTH=$(curl -s -X POST "${API_BASE_URL}/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=client_credentials")

TOKEN=$(echo "$AUTH" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
echo "✓ Authenticated: ${TOKEN:0:20}..."

# Function to test endpoint
test_endpoint() {
  local name=$1
  local method=$2
  local endpoint=$3
  local data=$4
  
  echo "Testing: $name"
  
  if [ "$method" = "GET" ]; then
    curl -s -X GET "${API_BASE_URL}${endpoint}" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -w "\n---HTTP_CODE:%{http_code}" >> "$REPORT_DIR/${name}.json"
  else
    curl -s -X POST "${API_BASE_URL}${endpoint}" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$data" \
      -w "\n---HTTP_CODE:%{http_code}" >> "$REPORT_DIR/${name}.json"
  fi
}

# 1. TYPEAHEAD
test_endpoint "01_typeahead_success" "GET" \
  "/typeahead/v1/locations?input=pennsylvania&maxResults=5" ""

test_endpoint "01_typeahead_missing_input" "GET" \
  "/typeahead/v1/locations?input=&maxResults=5" ""

test_endpoint "01_typeahead_invalid_maxresults" "GET" \
  "/typeahead/v1/locations?input=test&maxResults=invalid" ""

# 2. GEOCODE PREMIUM
test_endpoint "02_geocode_premium_success" "POST" \
  "/geocode/v1/premium/geocode" \
  '{"addresses":[{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}]}'

test_endpoint "02_geocode_premium_empty" "POST" \
  "/geocode/v1/premium/geocode" \
  '{"addresses":[]}'

test_endpoint "02_geocode_premium_missing_addresses" "POST" \
  "/geocode/v1/premium/geocode" \
  '{}'

# 3. GEOCODE ADVANCED  
test_endpoint "03_geocode_advanced_success" "POST" \
  "/geocode/v1/advanced/geocode" \
  '{"addresses":[{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}]}'

# 4. GEOCODE BASIC
test_endpoint "04_geocode_basic_success" "POST" \
  "/geocode/v1/basic/geocode" \
  '{"addresses":[{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}]}'

# 5. REVERSE GEOCODE (if exists)
test_endpoint "05_reverse_geocode" "POST" \
  "/geocode/v1/premium/reverseGeocode" \
  '{"locations":[{"latitude":38.8951,"longitude":-77.0369}]}'

# 6. ADDRESS VERIFICATION
test_endpoint "06_address_verification_success" "POST" \
  "/addressverification/v1/validatemailingaddress" \
  '{"mailingAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}'

# 7. EMAIL VERIFICATION
test_endpoint "07_email_verification_success" "POST" \
  "/emailverification/v1/validateemailaddress" \
  '{"email":"test@example.com"}'

test_endpoint "07_email_verification_invalid" "POST" \
  "/emailverification/v1/validateemailaddress" \
  '{"email":"invalid-email"}'

# 8. PHONE VERIFICATION
test_endpoint "08_phone_verification_success" "POST" \
  "/phoneverification/v2/validatephonenumber" \
  '{"phoneNumber":"+12025551234"}'

test_endpoint "08_phone_verification_invalid" "POST" \
  "/phoneverification/v2/validatephonenumber" \
  '{"phoneNumber":"invalid"}'

# 9. TIME ZONE
test_endpoint "09_timezone_success" "GET" \
  "/timezone/v1/timezone/byaddress?address=Washington,DC" ""

test_endpoint "09_timezone_by_location" "GET" \
  "/timezone/v1/timezone/bylocation?latitude=38.8951&longitude=-77.0369" ""

# 10. GEOLOCATION
test_endpoint "10_geolocation_success" "GET" \
  "/geolocation/v1/location/byipaddress?ipaddress=8.8.8.8" ""

test_endpoint "10_geolocation_invalid_ip" "GET" \
  "/geolocation/v1/location/byipaddress?ipaddress=invalid" ""

# 11. NEIGHBORHOODS
test_endpoint "11_neighborhoods_success" "GET" \
  "/neighborhoods/v1/place/bylocation?latitude=38.8951&longitude=-77.0369" ""

# 12. PROPERTY
test_endpoint "12_property_success" "POST" \
  "/property/v2/attributes/byaddress" \
  '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}'

# 13. RISKS (CRIME)
test_endpoint "13_risks_crime_success" "POST" \
  "/risks/v1/crime/byaddress" \
  '{"addresses":[{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}]}'

# 14-15. Check if deprecated endpoints exist
test_endpoint "14_deprecated_routing" "POST" \
  "/routing/v1/route/byaddress" \
  '{"startPoint":{"address":"Washington DC"},"endPoint":{"address":"New York NY"}}'

test_endpoint "15_deprecated_places" "POST" \
  "/places/v1/poi/byaddress" \
  '{"address":{"addressLine1":"Washington DC"}}'

echo ""
echo "=== TEST SUMMARY ==="
echo "Tests completed. Analyzing responses..."

# Analyze results
TOTAL=$(find "$REPORT_DIR" -name "*.json" | wc -l)
SUCCESS=$(grep -l "HTTP_CODE:200" "$REPORT_DIR"/*.json 2>/dev/null | wc -l)
ERRORS=$(grep -l "HTTP_CODE:[4-5]" "$REPORT_DIR"/*.json 2>/dev/null | wc -l)

echo "Total tests: $TOTAL"
echo "Successful (200): $SUCCESS"
echo "Errors (4xx/5xx): $ERRORS"

echo ""
echo "=== SAMPLE RESPONSES ==="
for file in "$REPORT_DIR"/*.json; do
  echo ""
  echo "--- $(basename $file) ---"
  cat "$file" | head -c 400
done

