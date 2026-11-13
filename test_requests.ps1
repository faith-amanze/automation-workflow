param([string]$BaseUrl = "http://127.0.0.1:8002")

$key = (Select-String -Path .env -Pattern '^API_KEY=').Line.Split('=',2)[1].Trim()
$id  = "evt-" + (Get-Date -Format "HHmmss")
$good  = Join-Path $env:TEMP "good.json"
$empty = Join-Path $env:TEMP "empty.json"

@"
{"event_id":"$id","student_email":"student@example.com","topic":"Photosynthesis","lesson_note":"Plants turn light, water and CO2 into sugar and oxygen.","difficulty":"beginner"}
"@ | Set-Content -Encoding ascii $good
@"
{"event_id":"$id-empty","student_email":"student@example.com","topic":"Photosynthesis","lesson_note":"","difficulty":"beginner"}
"@ | Set-Content -Encoding ascii $empty

Write-Host "--- Test A: happy path (expect 200) ---"
curl.exe -s -w "`nHTTP %{http_code}`n" -X POST "$BaseUrl/summarise" -H "Content-Type: application/json" -H "x-api-key: $key" -d "@$good"
Write-Host "--- Test B: missing text (expect 400 lesson_note is empty) ---"
curl.exe -s -w "`nHTTP %{http_code}`n" -X POST "$BaseUrl/summarise" -H "Content-Type: application/json" -H "x-api-key: $key" -d "@$empty"
Write-Host "--- Test C: wrong key (expect 401) ---"
curl.exe -s -w "`nHTTP %{http_code}`n" -X POST "$BaseUrl/summarise" -H "Content-Type: application/json" -H "x-api-key: wrong" -d "@$good"
Write-Host "--- Test D: idempotency, same event_id again (expect identical response to Test A) ---"
curl.exe -s -w "`nHTTP %{http_code}`n" -X POST "$BaseUrl/summarise" -H "Content-Type: application/json" -H "x-api-key: $key" -d "@$good"

Remove-Item $good, $empty -ErrorAction SilentlyContinue
