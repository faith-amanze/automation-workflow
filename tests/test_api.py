import os

os.environ["API_KEY"] = "test-key"
os.environ["USE_GROQ"] = "false"

from fastapi.testclient import TestClient
from main import app

client = TestClient(app)
HEADERS = {"x-api-key": "test-key"}


def body(event_id, note="Plants turn light into sugar."):
    return {
        "event_id": event_id,
        "student_email": "student@example.com",
        "topic": "Photosynthesis",
        "lesson_note": note,
        "difficulty": "beginner",
    }


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_happy_path_returns_summary():
    r = client.post("/summarise", json=body("t-1"), headers=HEADERS)
    assert r.status_code == 200
    assert r.json()["event_id"] == "t-1"
    assert r.json()["summary"]

def test_empty_note_returns_400():
    r = client.post("/summarise", json=body("t-2", note=""), headers=HEADERS)
    assert r.status_code == 400
    assert r.json()["detail"] == "lesson_note is empty"


def test_wrong_key_returns_401():
    r = client.post("/summarise", json=body("t-3"), headers={"x-api-key": "wrong"})
    assert r.status_code == 401


def test_missing_key_returns_401():
    r = client.post("/summarise", json=body("t-4"))
    assert r.status_code == 401


def test_repeated_event_id_returns_same_response():
    first = client.post("/summarise", json=body("t-5"), headers=HEADERS)
    second = client.post("/summarise", json=body("t-5"), headers=HEADERS)
    assert first.status_code == second.status_code == 200
    assert first.json() == second.json()