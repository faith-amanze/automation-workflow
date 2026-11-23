# Final Release Checklist

Legend: [x] done and evidenced, [ ] not done or needs checking before submission.

## Deployment / local setup
- [x] Local setup documented step by step in the README
- [x] `.env.example` provided
- [x] `n8n-workflow.json` included for import
- [ ] Not deployed. The project runs locally only (stated honestly in the README)
- [ ] Fresh-clone test: clone the repo into a new folder and follow the README exactly

## Core features
- [x] Webhook receives the five fields (report test 1)
- [x] `/summarise` returns a summary (test 2)
- [x] n8n calls the API (test 3) and sends the email (test 4)
- [x] Full workflow with the real Groq summary produced an email (test 6)
- [x] Fake-summary mode works for plumbing tests

## Security
- [x] `/summarise` requires `x-api-key` (401 when wrong or missing)
- [x] `.env` is in `.gitignore` and is not tracked
- [x] Groq key stays in `.env`, Gmail app password stays in an n8n credential
- [x] Real `API_KEY` value not found in any committed file or in git history
- [x] No `gsk_` Groq key in any file or in git history
- [ ] Known weakness: the key is typed into the n8n HTTP node, not stored as a credential

## Quality
- [x] Input validation (400 on an empty note)
- [x] Clear error messages (400, 401, 422)
- [x] Idempotency by `event_id`
- [x] 12 real errors documented with causes and fixes
- [ ] Known limitation: in-memory idempotency store resets on restart
- [ ] Known limitation: n8n can still send a duplicate email

## Tests
- [x] Scripted request tests in `test_requests.ps1` (200, 400, 401, idempotency)
- [x] Each workflow part tested separately, then end to end
- [ ] No automated pytest suite yet
- [ ] No CI (GitHub Actions) yet

## Documentation
- [x] README with problem, solution, features, stack, setup, env vars, test command, API example
- [x] All docs in `docs/` written (review, architecture, case study, demo, interview, LinkedIn)
- [x] `GROQ_MODEL` default set to `openai/gpt-oss-120b` in `main.py` and `.env.example`
- [ ] Confirm the screenshots in `docs/images/` display on GitHub

## Portfolio readiness
- [x] Repo shows files on GitHub (verified with `git ls-remote`)
- [ ] Repo description and topics set
- [ ] LinkedIn post published
- [ ] Demo rehearsed end to end at least twice
- [ ] Optional: add a LICENSE file