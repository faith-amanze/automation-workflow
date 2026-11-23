# Repo Cleanup Checklist

## 1. Confirm the push worked
- [x] `git ls-remote` shows `refs/heads/main`
- [ ] Open the repo in a private window and confirm files show
- [ ] Confirm `docs/images/*.png` display in the README

## 2. Name, description, topics
- [ ] Name: `automation-workflow` is acceptable
- [ ] Description: "n8n workflow that sends lesson notes to a FastAPI + Groq summariser and emails the summary to students"
- [ ] Topics: `n8n`, `fastapi`, `groq`, `automation`, `webhook`, `python`, `llm`

## 3. Secrets scan (including history)
- [x] `.env` is NOT in the repo; `.env.example` is
- [x] `.gitignore` contains `.env`
- [x] No real `API_KEY` value in any file or in git history
- [x] No `gsk_` Groq key in any file or in git history

## 4. Files
- [ ] Add the new docs and the updated `README.md`
- [x] `GROQ_MODEL` default set to `openai/gpt-oss-120b`

## 5. Final check
- [ ] Fresh clone in a new folder, follow the README, and confirm it works
- [ ] Rehearse the demo twice