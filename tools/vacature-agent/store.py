"""Inbox, seen-ids, beslissingen. Alles lokaal in data/ (niet in git)."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
INBOX = DATA / "inbox.json"
SEEN = DATA / "seen.json"
DECISIONS = DATA / "decisions.json"
DIGEST = DATA / "inbox.md"


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def ensure_data() -> None:
    DATA.mkdir(parents=True, exist_ok=True)
    for path, default in (
        (INBOX, {"jobs": []}),
        (SEEN, {"ids": []}),
        (DECISIONS, {"items": []}),
    ):
        if not path.exists():
            path.write_text(json.dumps(default, indent=2), encoding="utf-8")


def load_json(path: Path) -> dict[str, Any]:
    ensure_data()
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload: dict[str, Any]) -> None:
    ensure_data()
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def seen_ids() -> set[str]:
    return set(load_json(SEEN).get("ids") or [])


def mark_seen(job_id: str) -> None:
    data = load_json(SEEN)
    ids = list(data.get("ids") or [])
    if job_id not in ids:
        ids.append(job_id)
        data["ids"] = ids[-4000:]
        save_json(SEEN, data)


def pending_jobs() -> list[dict[str, Any]]:
    jobs = load_json(INBOX).get("jobs") or []
    return [j for j in jobs if j.get("status") == "pending"]


def upsert_pending(job: dict[str, Any]) -> bool:
    """True als nieuw in inbox."""
    data = load_json(INBOX)
    jobs = data.get("jobs") or []
    for existing in jobs:
        if existing.get("id") == job["id"]:
            if existing.get("status") == "pending":
                existing["score"] = job.get("score")
                existing["reasons"] = job.get("reasons")
                existing["summary"] = job.get("summary")
                existing["work_mode"] = job.get("work_mode")
                existing["location"] = job.get("location")
                save_json(INBOX, data)
                write_digest()
            return False
    job = dict(job)
    job["status"] = "pending"
    job["found_at"] = _now()
    jobs.append(job)
    data["jobs"] = jobs
    save_json(INBOX, data)
    mark_seen(job["id"])
    write_digest()
    return True


def set_status(job_id: str, status: str) -> dict[str, Any] | None:
    data = load_json(INBOX)
    found = None
    for job in data.get("jobs") or []:
        if job.get("id") == job_id:
            job["status"] = status
            job["decided_at"] = _now()
            found = job
            break
    if not found:
        return None
    save_json(INBOX, data)
    decisions = load_json(DECISIONS)
    items = decisions.get("items") or []
    items.append({"id": job_id, "status": status, "at": _now(), "title": found.get("title")})
    decisions["items"] = items
    save_json(DECISIONS, decisions)
    write_digest()
    return found


def write_digest() -> None:
    pending = pending_jobs()
    pending.sort(key=lambda j: int(j.get("score") or 0), reverse=True)
    lines = [
        "# Vacature-inbox",
        "",
        f"Bijgewerkt: {_now()}",
        "",
        "Zeg **goed <id>** of **niet <id>** (CLI: `python vacature_agent.py goed JOBID`).",
        "",
    ]
    if not pending:
        lines.append("Geen openstaande matches. Agent zoekt opnieuw bij `search`.")
    for job in pending:
        lines += [
            f"## `{job.get('id')}` — score {job.get('score')}",
            "",
            f"**{job.get('title')}** — {job.get('company') or 'onbekend'}",
            "",
            f"- Locatie / modus: {job.get('location') or '?'} · {job.get('work_mode') or '?'}",
            f"- Waarom: {', '.join(job.get('reasons') or [])}",
            f"- Link: {job.get('url')}",
            "",
            (job.get("summary") or "")[:500],
            "",
            "---",
            "",
        ]
    DIGEST.write_text("\n".join(lines), encoding="utf-8")
