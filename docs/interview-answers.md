# Interview Answers

## 1. Why this stack?
n8n let me wire the trigger, API call, and email visually and test each node on its own. FastAPI gave me a small, validated endpoint with automatic error handling. Groq is fast and has a free tier, so I could test real summaries cheaply. The stack fits a small automation well, and I can swap the AI provider without changing the workflow.

## 2. How does authentication work?
The `/summarise` endpoint requires an `x-api-key` header. The backend compares it with `API_KEY` from `.env` and returns 401 if it's wrong or missing. `.env` is in `.gitignore`. A weakness I know about: I typed the key into the n8n HTTP node, and the better approach is an n8n Header Auth credential. The webhook itself is not authenticated yet.

## 3. How is data stored?
There is no database. The backend keeps processed `event_id` values and summaries in an in-memory dictionary for idempotency, so it resets on restart. The lesson note isn't stored permanently. For production I'd use a database or Redis.

## 4. How are errors handled?
The backend returns clear codes: 401 for a bad key, 400 for an empty note, 422 for invalid JSON. A repeated `event_id` returns the saved result without a new AI call. In n8n, a failed node stops the run and shows the error, which is how I found the SMTP problems. What's missing: retries and failure alerts, so those are on my list.

## 5. What would you improve next?
First, move the API key into an n8n credential. Second, widen the tests: I have six pytest tests running in GitHub Actions, but they only cover the API in fake-summary mode, so I would add a mocked Groq test and an end-to-end check of the n8n workflow. Third, replace the in-memory store with a database and stop duplicate emails inside n8n. Then deploy it so others can try it without local setup.

## Bonus: "Did you use AI to build this?"
Yes. I built it solo with an AI coding assistant for writing and debugging. I designed the flow, ran every test, diagnosed the port issue with `Test-NetConnection` myself, and I can walk through each part of the code.