# Case Study: Lesson Note Summary Automation

## Project summary
An automation that turns a lesson note into a short emailed summary. A webhook receives the note, a secured FastAPI backend summarises it with Groq, and n8n emails the result to the student.

## Problem
Lesson notes are long. Students want a quick review version, and writing a summary by hand for every lesson does not scale.

## Target user
Students who receive the summary, and tutors or systems that submit notes.

## Solution
One POST request triggers a three-step pipeline: receive, summarise, deliver. No manual steps in between.

## Features
- Webhook intake with five fields
- Groq summary via a FastAPI endpoint
- Email delivery through n8n SMTP
- API key authentication
- Input validation with clear status codes
- Idempotency by `event_id`
- Fake-summary mode for safe testing

## My role
I built this solo, using an AI coding assistant to help write and debug it. I designed the flow, tested each part separately, worked through the errors, and documented the results. I can explain each part of the system.

## Tech stack
n8n, Python, FastAPI, Uvicorn, Groq (`openai/gpt-oss-120b`), SMTP (Gmail), pytest, GitHub Actions, PowerShell test script.

## Challenges
The hardest was getting email to send. Gmail OAuth needed a Google Cloud project, so I used SMTP with an app password. Then IPv6 caused `ENETUNREACH`, fixed with `--dns-result-order=ipv4first`. Finally port 465 timed out; `Test-NetConnection` showed 587 was open. Other issues included a port clash on 8001 and `localhost` resolving to IPv6 while Uvicorn listened on IPv4. All 12 are documented in the full report.

## Learning outcomes
- Testing each part of a pipeline separately makes failures easy to locate.
- Network settings (IPv6, blocked ports) can break email even when code and credentials are correct.
- Secrets belong in `.env` and credential stores, never in the repo.
- Idempotency matters when webhooks can be retried.
- Honest documentation of limits is part of a finished project.

## Future improvements
- Move the API key into an n8n Header Auth credential
- Use a database or Redis for idempotency, and prevent duplicate emails
- Add a mocked test for the Groq call and an end-to-end test of the n8n workflow
- Deploy the backend and n8n
- Add retries and a nicer email template

## Links
- Repository: https://github.com/faith-amanze/automation-workflow
- Full report: [automation-workflow-report.md](automation-workflow-report.md)