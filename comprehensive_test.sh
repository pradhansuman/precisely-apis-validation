#!/bin/bash

API_BASE_URL="https://api.precisely.com"
CLIENT_ID="4ZsIP45kyB95nZxoO5t0TW5a8xoTuGH1"
CLIENT_SECRET="wxTS09yvX0ESVkQ8"
OUTPUT_DIR="/private/tmp/claude-501/-Users-skp/40e0b46e-f6fa-4d7d-befa-e3af889ed4c0/scratchpad/api_evidence"

mkdir -p "$OUTPUT_DIR"

# Get token
AUTH_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  -d "grant_type=client_credentials")

ACCESS_TOKEN=$(echo "$AUTH_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

echo "Token: $ACCESS_TOKEN"
echo "$AUTH_RESPONSE" > "$OUTPUT_DIR/01_auth_success.json"

# Test Typeahead - Success
echo "Testing Typeahead Success..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=1600+Pennsylvania&maxResults=5" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/02_typeahead_success.txt"

# Test Typeahead - Invalid Input
echo "Testing Typeahead 400 (invalid)..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=&maxResults=5" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/03_typeahead_400.txt"

# Test Typeahead - No Auth
echo "Testing Typeahead 401 (no auth)..."
curl -s -X GET "${API_BASE_URL}/typeahead/v1/locations?input=test&maxResults=5" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/04_typeahead_401.txt"

# Test Geocode Premium - Success
echo "Testing Geocode Premium Success..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC","country":"USA"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/05_geocode_premium_success.txt"

# Test Geocode Advanced - Success
echo "Testing Geocode Advanced Success..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/advanced/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC","country":"USA"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/06_geocode_advanced_success.txt"

# Test Geocode Basic - Success
echo "Testing Geocode Basic Success..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/basic/geocode" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"mainAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC","country":"USA"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/07_geocode_basic_success.txt"

# Test Address Verification - Success
echo "Testing Address Verification Success..."
curl -s -X POST "${API_BASE_URL}/addressverification/v1/validatemailingaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"mailingAddress":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC","postalCode":"20500","country":"USA"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/08_address_verification_success.txt"

# Test Email Verification - Success
echo "Testing Email Verification Success..."
curl -s -X POST "${API_BASE_URL}/emailverification/v1/validateemailaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/09_email_verification_success.txt"

# Test Phone Verification - Success
echo "Testing Phone Verification Success..."
curl -s -X POST "${API_BASE_URL}/phoneverification/v2/validatephonenumber" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"+12025551234"}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/10_phone_verification_success.txt"

# Test Routing - Success
echo "Testing Routing Success..."
curl -s -X POST "${API_BASE_URL}/routing/v1/route/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"startPoint":{"address":"1600 Pennsylvania Avenue NW, Washington, DC"},"endPoint":{"address":"123 Main St, New York, NY"},"travelMode":"Driving"}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/11_routing_success.txt"

# Test Places - Success
echo "Testing Places Success..."
curl -s -X POST "${API_BASE_URL}/places/v1/poi/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"},"radius":1}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/12_places_success.txt"

# Test Zones - Success
echo "Testing Zones Success..."
curl -s -X POST "${API_BASE_URL}/zones/v1/travelboundary/bytime" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"location":{"latitude":38.8951,"longitude":-77.0369},"maxTime":30,"travelMode":"Driving"}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/13_zones_success.txt"

# Test Streets - Success
echo "Testing Streets Success..."
curl -s -X POST "${API_BASE_URL}/streets/v1/intersection/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/14_streets_success.txt"

# Test Neighborhoods - Success
echo "Testing Neighborhoods Success..."
curl -s -X GET "${API_BASE_URL}/neighborhoods/v1/place/bylocation?latitude=38.8951&longitude=-77.0369" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/15_neighborhoods_success.txt"

# Test Schools - Success
echo "Testing Schools Success..."
curl -s -X POST "${API_BASE_URL}/schools/v1/school/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/16_schools_success.txt"

# Test Property - Success
echo "Testing Property Success..."
curl -s -X POST "${API_BASE_URL}/property/v2/attributes/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/17_property_success.txt"

# Test Risks - Success
echo "Testing Risks Success..."
curl -s -X POST "${API_BASE_URL}/risks/v1/crime/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/18_risks_success.txt"

# Test Time Zone - Success
echo "Testing Time Zone Success..."
curl -s -X GET "${API_BASE_URL}/timezone/v1/timezone/byaddress?address=1600+Pennsylvania+Avenue+NW,+Washington,+DC" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/19_timezone_success.txt"

# Test Geolocation - Success
echo "Testing Geolocation Success..."
curl -s -X GET "${API_BASE_URL}/geolocation/v1/location/byipaddress?ipaddress=8.8.8.8" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/20_geolocation_success.txt"

# Test Telecom - Success
echo "Testing Telecom Success..."
curl -s -X POST "${API_BASE_URL}/telecomm/v1/ratecenter/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/21_telecom_success.txt"

# Test Local Tax - Success
echo "Testing Local Tax Success..."
curl -s -X POST "${API_BASE_URL}/localtax/v1/taxrate/General/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/22_localtax_success.txt"

# Test 911/PSAP - Success
echo "Testing 911/PSAP Success..."
curl -s -X POST "${API_BASE_URL}/911/v1/psap/byaddress" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"address":{"addressLine1":"1600 Pennsylvania Avenue NW","city":"Washington","state":"DC"}}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/23_911_success.txt"

# Test Addresses - Success
echo "Testing Addresses Success..."
curl -s -X POST "${API_BASE_URL}/addresses/v1/address/byboundaryname" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"boundaryName":"Washington","boundaryType":"city","country":"USA"}' \
  -w "\n%{http_code}\n" > "$OUTPUT_DIR/24_addresses_success.txt"

echo ""
echo "Evidence collection complete. Results saved to: $OUTPUT_DIR"
ls -lah "$OUTPUT_DIR"

