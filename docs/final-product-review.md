# Final Product Review

## Problem solved
Lesson notes are long, and students benefit from a short version they can review quickly. Writing those summaries by hand for every lesson is slow for a tutor. This project automates it: one request in, one summary email out.

## Target user
- **Primary:** students who receive the summary by email.
- **Secondary:** tutors or systems that submit lesson notes through the webhook.

## Project journey
1. Planned the flow: webhook, then API, then AI, then email.
2. Built the FastAPI `/summarise` endpoint with a fake summary first, so the plumbing could be tested without AI.
3. Built the n8n workflow and mapped the webhook fields into the API request.
4. Tested each part on its own (trigger, API, API node, email node), then the full workflow.
5. Switched on real Groq summaries (`llama-3.3-70b-versatile` first, later `openai/gpt-oss-120b`).
6. Added security (`x-api-key`), validation (400/401), and idempotency by `event_id`.
7. Wrote tests, documented 12 errors that were fixed, and prepared this package.

## Main features
- Webhook intake of five fields
- Groq-powered summary through FastAPI
- Email delivery through n8n SMTP
- API key authentication
- Input validation and clear error codes
- Idempotency by `event_id`
- Fake-summary mode for safe testing

## Hardest challenge: getting the email to send
The Send Email node failed three times in a row:
1. Gmail OAuth demanded a Google Cloud Client ID and Secret, so I switched to the SMTP node with a Gmail app password.
2. SMTP failed with `ENETUNREACH` on an IPv6 address because my network could not reach IPv6. Starting n8n with `NODE_OPTIONS=--dns-result-order=ipv4first` fixed it.
3. SMTP then timed out. `Test-NetConnection` showed port 465 blocked and 587 open, so I moved to port 587 with SSL/TLS off.

I read each error message, worked through the causes with my coding assistant, and confirmed the port problem myself. Lesson: network settings such as IPv6 and blocked ports can break email delivery even when the code and credentials are correct, so test reachability before blaming the code.

## What I would improve next
1. Move the `x-api-key` into an n8n Header Auth credential instead of typing it into the node.
2. Replace the in-memory idempotency store with a database or Redis, and stop duplicate emails inside n8n.
3. Add a mocked test for the Groq call and an end-to-end test of the n8n workflow.
4. Deploy the backend and n8n so the project can be tried without local setup.
5. Add retries, and a nicer email template.