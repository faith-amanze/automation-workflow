# Lesson Note Summary Automation

An n8n workflow that receives a lesson note through a webhook, sends it to a FastAPI backend that summarises it with Groq, and emails the summary to the student.

![n8n workflow, all nodes green](docs/images/01-workflow-canvas-all-green.png)

Full write-up (field mapping, tests, errors fixed, screenshots): [docs/automation-workflow-report.md](docs/automation-workflow-report.md)

## Project structure

| File | Purpose |
|---|---|
| `main.py` | FastAPI backend: `POST /summarise`, `GET /health` |
| `requirements.txt` | Python dependencies |
| `.env.example` | Template for the backend settings (copy to `.env`) |
| `n8n-workflow.json` | The n8n workflow (import it into n8n) |
| `test_requests.ps1` | Backend tests for PowerShell: success, 400, 401, idempotency |
| `docs/` | Report and screenshots |

## Setup (Windows / PowerShell)

### 1. Backend

```powershell
pip install -r requirements.txt
Copy-Item .env.example .env      # then edit .env
uvicorn main:app --port 8002 --reload
```

Settings in `.env`:

| Variable | Meaning |
|---|---|
| `API_KEY` | Secret the caller must send in the `x-api-key` header. Make up a long random value. |
| `USE_GROQ` | `false` returns a placeholder summary (good for testing the plumbing). `true` calls Groq. |
| `GROQ_API_KEY` | Your Groq key (only needed when `USE_GROQ=true`) |
| `GROQ_MODEL` | Defaults to `llama-3.3-70b-versatile` |

Restart uvicorn after changing `.env`. Check it is up: `curl.exe http://127.0.0.1:8002/health` returns `{"status":"ok"}`.

### 2. n8n

```powershell
npm install -g n8n
$env:NODE_OPTIONS="--dns-result-order=ipv4first"
n8n
```

Open http://localhost:5678, then:

1. **Import** `n8n-workflow.json` (Workflows, menu, Import from file).
2. In **Call /summarise**, set the `x-api-key` header to the same value as `API_KEY` in `.env`.
3. In **Send Summary Email**, create an SMTP credential:
   - Host `smtp.gmail.com`, Port `587`, SSL/TLS **off**
   - User: your Gmail address, Password: a Gmail **app password** (needs 2-Step Verification)
   - Set **From Email** to your Gmail address.

### 3. Run it

In n8n click **Execute workflow**, then within about a minute send a request (use `curl.exe`, not `curl`, in PowerShell):

```powershell
'{"event_id":"evt-100","student_email":"you@example.com","topic":"Photosynthesis","lesson_note":"Plants turn light, water and CO2 into sugar and oxygen.","difficulty":"beginner"}' | Set-Content -Encoding ascii webhook.json

curl.exe -X POST http://localhost:5678/webhook-test/lesson-note -H "Content-Type: application/json" -d "@webhook.json"
```

Use a new `event_id` for every run (see Idempotency). To use the production URL (`/webhook/lesson-note`), publish the workflow first.

## API

`POST /summarise` with header `x-api-key` and a JSON body:

| Field | Example |
|---|---|
| `event_id` | `evt-100` (unique per event) |
| `student_email` | `you@example.com` |
| `topic` | `Photosynthesis` |
| `lesson_note` | text to summarise |
| `difficulty` | `beginner` (optional) |

| Status | Meaning |
|---|---|
| 200 | `{"event_id": "...", "summary": "..."}` |
| 400 | `lesson_note is empty` |
| 401 | `Bad or missing API key` |
| 422 | Body is not valid JSON or fields are missing |

## Tests

With the backend running:

```powershell
.\test_requests.ps1
```

It checks the happy path (200), empty text (400), wrong key (401), and a repeated `event_id` (same response again).

## Security

`/summarise` requires a secret `x-api-key` header. The key lives in `.env` (listed in `.gitignore`, never committed) and is rejected with 401 when wrong or missing. The Groq key stays in `.env` and the Gmail app password stays in n8n credentials.

## Idempotency

Every event has a unique `event_id`. The backend remembers the IDs it has processed and returns the saved result if the same ID arrives again (for example a webhook retry), instead of calling the AI twice. The store is an in-memory dictionary, so it resets when the server restarts; production would use a database or Redis. Note that n8n would still send a second email for a repeated event, because the check lives in the backend.

## Troubleshooting

| Symptom | Fix |
|---|---|
| n8n: "connection refused" for `localhost:8002` | Use `http://127.0.0.1:8002/summarise` (`localhost` may resolve to IPv6) |
| SMTP `ENETUNREACH` on an IPv6 address | Start n8n with `$env:NODE_OPTIONS="--dns-result-order=ipv4first"` |
| SMTP timeout | Port 465 may be blocked; use 587 with SSL/TLS off |
| Only the Webhook node runs | "Listen for test event" runs just the trigger; use **Execute workflow** |
| Email still says `[FAKE]` | Set `USE_GROQ=true`, restart uvicorn, and send a new `event_id` |