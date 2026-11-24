# Demo Script (about 4 minutes)

**Before you start:** FastAPI running on 8002 with `USE_GROQ=true`, n8n open with the workflow imported, inbox open in another tab, a fresh `event_id` ready, webhook.json prepared.

## 1. Opening (0:00 to 0:20)
"Hi, I'm Faith. This is my lesson note summary automation. It takes a lesson note, summarises it with AI, and emails the summary to a student."

## 2. Problem (0:20 to 0:50)
"Lesson notes are long. Students want a quick review version, and writing summaries by hand for every lesson is slow. I wanted that to happen automatically."

## 3. Main features (0:50 to 2:00)
- Click **Execute workflow** in n8n, then run the curl command with a new `event_id`.
- Show the three nodes turning green.
- Open the inbox: "Your summary: Photosynthesis" with the Groq bullets.
- Say: "The endpoint is protected by an API key, validates input, and uses the event ID so a retry doesn't call the AI twice."

## 4. Technical architecture (2:00 to 3:00)
Show the diagram in `docs/architecture.md`.
"Webhook, then an HTTP Request to my FastAPI endpoint, which calls Groq, then n8n sends the email over SMTP. Webhook data arrives under `body`, and I build the JSON with `JSON.stringify` so quotes in a note can't break it."

## 5. Test and proof (3:00 to 3:40)
Run `python -m pytest -v`, then show the green check in the GitHub Actions tab.
"Success returns 200, an empty note returns 400, a wrong key returns 401, and a repeated event returns the identical saved summary." Mention honestly: "These are six pytest tests in fake-summary mode, and GitHub Actions runs them on every push. The Groq call and the n8n steps I tested by hand."

## 6. Closing (3:40 to 4:10)
"The hardest part was email: IPv6 errors, then a blocked SMTP port. I built this solo with an AI coding assistant and tested each part separately. It runs locally today. Next I'll add deployment and more test coverage. Thank you."

## If something fails live
Show the screenshots in `docs/images/` and the report's test tables. Say what you'd check first: the backend `/health`, then the API key, then the SMTP port.