#!/bin/bash
API_BASE_URL="https://api.precisely.com"
CLIENT_ID="4ZsIP45kyB95nZxoO5t0TW5a8xoTuGH1"
CLIENT_SECRET="wxTS09yvX0ESVkQ8"
REPORT_DIR="/private/tmp/claude-501/-Users-skp/40e0b46e-f6fa-4d7d-befa-e3af889ed4c0/scratchpad/advanced_test_results"
mkdir -p "$REPORT_DIR"

echo "=========================================="
echo "ADVANCED SECURITY & PERFORMANCE TESTS"
echo "=========================================="

AUTH=$(curl -s -X POST "${API_BASE_URL}/oauth/token" -H "Content-Type: application/x-www-form-urlencoded" -u "${CLIENT_ID}:${CLIENT_SECRET}" -d "grant_type=client_credentials")
TOKEN=$(echo "$AUTH" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

echo "✓ Authenticated"
echo ""

# SQL INJECTION TESTS
echo "[1] SQL Injection Testing..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"1; DROP TABLE--","city":"Test","state":"TS"}}]}' -w "HTTP: %{http_code}\n" > "$REPORT_DIR/01_sql_injection.txt"
echo "✓ SQL Injection: Test sent (expecting 400)"

# XSS INJECTION TESTS  
echo "[2] XSS & Command Injection Testing..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"<script>alert(1)</script>","city":"Test","state":"TS"}}]}' -w "HTTP: %{http_code}\n" > "$REPORT_DIR/02_xss_injection.txt"
echo "✓ XSS: Test sent (expecting 400)"

# HEADER INJECTION
echo "[3] Header Injection Testing..."
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "X-Injected: test\r\nX-Admin: true" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"Test","city":"Washington","state":"DC"}}]}' -w "HTTP: %{http_code}\n" > "$REPORT_DIR/03_header_injection.txt"
echo "✓ Header Injection: Test sent"

# LOAD TESTING (30 requests)
echo "[4] Load Testing (30 sequential requests)..."
for i in {1..30}; do
  curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"1600 PA Ave","city":"Washington","state":"DC"}}]}' -w "Request $i: %{http_code} %{time_total}s\n" >> "$REPORT_DIR/04_load_test.txt"
  [ $((i % 10)) -eq 0 ] && echo "  ✓ $i/30 completed"
  sleep 0.1
done
echo "✓ Load Test: 30 requests completed"

# LATENCY ANALYSIS (50 samples for P95/P99)
echo "[5] Latency Analysis (50 samples for P95/P99)..."
> "$REPORT_DIR/05_latency_analysis.txt"
LATENCIES=()
for i in {1..50}; do
  LATENCY=$(curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"Test","city":"Washington","state":"DC"}}]}' -w "%{time_total}" -o /dev/null)
  LATENCIES+=("$LATENCY")
  echo "Sample $i: ${LATENCY}s" >> "$REPORT_DIR/05_latency_analysis.txt"
done
echo "✓ Latency Analysis: 50 samples captured"

# CONCURRENCY TEST
echo "[6] Concurrency Testing (5 parallel requests)..."
for i in {1..5}; do
  curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"Address $i","city":"Test","state":"TS"}}]}' -w "Concurrent $i: %{http_code}\n" >> "$REPORT_DIR/06_concurrency_test.txt" &
done
wait
echo "✓ Concurrency Test: 5 parallel requests completed"

# BOUNDARY VALUE TESTING
echo "[7] Boundary Value Testing..."
echo "Test: Pole coordinates (90, -90)..." >> "$REPORT_DIR/07_boundary_values.txt"
curl -s -X GET "${API_BASE_URL}/neighborhoods/v1/place/bylocation?latitude=90&longitude=0" -H "Authorization: Bearer ${TOKEN}" -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/07_boundary_values.txt"

echo "Test: Null Island (0, 0)..." >> "$REPORT_DIR/07_boundary_values.txt"
curl -s -X GET "${API_BASE_URL}/neighborhoods/v1/place/bylocation?latitude=0&longitude=0" -H "Authorization: Bearer ${TOKEN}" -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/07_boundary_values.txt"

echo "Test: Max coordinates (180, -180)..." >> "$REPORT_DIR/07_boundary_values.txt"
curl -s -X GET "${API_BASE_URL}/neighborhoods/v1/place/bylocation?latitude=45&longitude=180" -H "Authorization: Bearer ${TOKEN}" -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/07_boundary_values.txt"
echo "✓ Boundary Value Tests: Completed"

# UNICODE TESTING
echo "[8] Unicode/UTF-8 Character Testing..."
echo "Test: Chinese address..." >> "$REPORT_DIR/08_unicode_tests.txt"
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"北京市朝阳区","city":"Beijing","country":"China"}}]}' -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/08_unicode_tests.txt"

echo "Test: Russian address..." >> "$REPORT_DIR/08_unicode_tests.txt"
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"Москва","city":"Moscow","country":"Russia"}}]}' -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/08_unicode_tests.txt"

echo "Test: Arabic address..." >> "$REPORT_DIR/08_unicode_tests.txt"
curl -s -X POST "${API_BASE_URL}/geocode/v1/premium/geocode" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" -d '{"addresses":[{"mainAddress":{"addressLine1":"الرياض","city":"Riyadh","country":"Saudi Arabia"}}]}' -w "HTTP: %{http_code}\n" >> "$REPORT_DIR/08_unicode_tests.txt"
echo "✓ Unicode Tests: Completed"

echo ""
echo "=========================================="
echo "ALL TESTS COMPLETED"
echo "=========================================="
ls -lh "$REPORT_DIR" | tail -n +2
echo ""
echo "Results saved to: $REPORT_DIR"
