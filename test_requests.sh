#!/usr/bin/env bash
# Tests against the FastAPI backend directly (port 8001).
URL="http://localhost:8002/summarise"
KEY="change-me-secret"   # must match API_KEY in your .env

echo "--- Test 1: happy path (expect 200 + summary) ---"
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -H "x-api-key: $KEY" \
  -d '{"event_id":"evt-001","student_email":"you@gmail.com","topic":"Photosynthesis","lesson_note":"Plants turn light, water and CO2 into sugar and oxygen.","difficulty":"beginner"}'

echo "--- Test 2: missing text (expect 400 lesson_note is empty) ---"
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -H "x-api-key: $KEY" \
  -d '{"event_id":"evt-002","student_email":"you@gmail.com","topic":"Photosynthesis","lesson_note":"","difficulty":"beginner"}'

echo "--- Test 3: wrong auth (expect 401 Bad or missing API key) ---"
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -H "x-api-key: wrong" \
  -d '{"event_id":"evt-003","student_email":"you@gmail.com","topic":"Photosynthesis","lesson_note":"Some text","difficulty":"beginner"}'

echo "--- Test 4: idempotency (send evt-001 again, expect identical response) ---"
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -H "x-api-key: $KEY" \
  -d '{"event_id":"evt-001","student_email":"you@gmail.com","topic":"Photosynthesis","lesson_note":"Plants turn light, water and CO2 into sugar and oxygen.","difficulty":"beginner"}'

echo
echo "--- Webhook test (n8n must be listening on the test URL) ---"
echo "curl -X POST http://localhost:5678/webhook-test/lesson-note -H 'Content-Type: application/json' -d '{\"event_id\":\"evt-010\",\"student_email\":\"you@gmail.com\",\"topic\":\"Photosynthesis\",\"lesson_note\":\"Plants turn light, water and CO2 into sugar and oxygen.\",\"difficulty\":\"beginner\"}'"
