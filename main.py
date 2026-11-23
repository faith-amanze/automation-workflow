import os
from dotenv import load_dotenv
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel

load_dotenv()

API_KEY = os.getenv("API_KEY", "change-me-secret")
USE_GROQ = os.getenv("USE_GROQ", "false").lower() == "true"
GROQ_MODEL = os.getenv("GROQ_MODEL", "openai/gpt-oss-120b")

app = FastAPI(title="Summarise API")

# Idempotency store: event_id -> saved result.
# In-memory only, so it resets when the server restarts.
processed = {}


class Note(BaseModel):
    event_id: str
    student_email: str
    topic: str
    lesson_note: str
    difficulty: str = "beginner"


def make_summary(note: Note) -> str:
    """Fake summary by default. Real Groq summary when USE_GROQ=true."""
    if not USE_GROQ:
        return f"[FAKE] Summary of {note.topic}: {note.lesson_note[:80]}..."

    from groq import Groq

    client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    prompt = (
        f"Summarise this lesson note on '{note.topic}' for a {note.difficulty} "
        f"student. Use 3 to 5 short bullet points.\n\n{note.lesson_note}"
    )
    resp = client.chat.completions.create(
        model=GROQ_MODEL,
        messages=[{"role": "user", "content": prompt}],
    )
    return resp.choices[0].message.content


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/summarise")
def summarise(note: Note, x_api_key: str = Header(None)):
    # 1. Security: secret header
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Bad or missing API key")

    # 2. Validation
    if not note.lesson_note.strip():
        raise HTTPException(status_code=400, detail="lesson_note is empty")

    # 3. Idempotency: same event_id returns the saved result
    if note.event_id in processed:
        return processed[note.event_id]

    # 4. Do the work
    summary = make_summary(note)
    result = {"event_id": note.event_id, "summary": summary}
    processed[note.event_id] = result
    return result
