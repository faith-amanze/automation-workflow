# LinkedIn Post Draft

I just finished a capstone project: an automation that turns a lesson note into a short summary and emails it to a student.

How it works: an n8n webhook receives the note, a FastAPI backend sends it to Groq for a bullet summary, and n8n emails the result.

What's in it:
- API key protection on the endpoint
- Input validation with clear error codes
- Idempotency, so a retried webhook doesn't trigger a second AI call
- Tests for success, empty input, bad key, and repeats

The hardest part wasn't the AI. It was getting the email to send. I hit IPv6 errors, then a blocked SMTP port, and learned that network settings can break delivery even when your code is right.

I built it solo with an AI coding assistant, and I tested each piece separately. It runs locally for now. Next steps are automated tests, CI, and deployment.

Repo: https://github.com/faith-amanze/automation-workflow

#n8n #FastAPI #Automation #Python #Groq