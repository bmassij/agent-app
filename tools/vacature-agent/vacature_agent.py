#!/usr/bin/env python3
"""Vacature-agent: zoeken → inbox → goed/niet → sollicitatie.

  python vacature_agent.py search
  python vacature_agent.py inbox
  python vacature_agent.py goed JOBID
  python vacature_agent.py niet JOBID
  python vacature_agent.py watch   # elke 3 uur opnieuw zoeken
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from apply import load_contact, try_notify, try_send, write_letter  # noqa: E402
from score import KEEP, score_job  # noqa: E402
from sources import collect  # noqa: E402
from store import (  # noqa: E402
    DIGEST,
    ensure_data,
    pending_jobs,
    set_status,
    upsert_pending,
    write_digest,
)


def load_profile() -> dict:
    return json.loads((ROOT / "profile.json").read_text(encoding="utf-8"))


def cmd_search() -> int:
    profile = load_profile()
    raw = collect()
    kept = 0
    skipped = 0
    new_ids: list[str] = []
    seen_keep: set[str] = set()
    for job in raw:
        result = score_job(job, profile)
        job["score"] = result["score"]
        job["reasons"] = result["reasons"]
        if result["decision"] != KEEP:
            skipped += 1
            continue
        seen_keep.add(job["id"])
        if upsert_pending(job):
            kept += 1
            new_ids.append(job["id"])
        else:
            skipped += 1
    # Inbox schoonhouden: oude matches die nu onder de lat vallen, eruit.
    for job in list(pending_jobs()):
        if job["id"] in seen_keep:
            continue
        result = score_job(job, profile)
        if result["decision"] != KEEP:
            set_status(job["id"], "filtered")
            skipped += 1
    write_digest()
    pending = pending_jobs()
    print(f"Gezien: {len(raw)} · nieuw in inbox: {kept} · gefilterd/al gezien: {skipped}")
    print(f"Open ter beoordeling: {len(pending)}")
    print(f"Lees: {DIGEST}")
    for job in sorted(pending, key=lambda j: int(j.get("score") or 0), reverse=True):
        tag = "NIEUW" if job["id"] in new_ids else "open"
        print(f"  [{job['id']}] {job.get('score')} {tag}  {job.get('title')}  ({job.get('company')})")
        print(f"           {job.get('url')}")
    note = try_notify(pending, new_ids, load_contact())
    if note:
        print(note)
    return 0


def cmd_inbox() -> int:
    write_digest()
    pending = pending_jobs()
    if not pending:
        print("Inbox leeg. Run: python vacature_agent.py search")
        return 0
    print(DIGEST.read_text(encoding="utf-8"))
    return 0


def cmd_niet(job_id: str) -> int:
    job = set_status(job_id, "rejected")
    if not job:
        print(f"Onbekend id: {job_id}")
        return 1
    print(f"Afgewezen: {job.get('title')}")
    return 0


def cmd_goed(job_id: str) -> int:
    job = set_status(job_id, "approved")
    if not job:
        print(f"Onbekend id: {job_id}")
        return 1
    profile = load_profile()
    contact = load_contact()
    letter = write_letter(job, profile, contact)
    status = try_send(letter, job, contact)
    print(f"GOED: {job.get('title')}")
    print(f"Brief: {letter}")
    print(status)
    print(f"Solliciteren via: {job.get('url')}")
    return 0


def cmd_watch(hours: float) -> int:
    print(f"Watch elke {hours} uur. Ctrl+C om te stoppen.")
    while True:
        cmd_search()
        time.sleep(max(hours, 0.25) * 3600)


def main() -> int:
    ensure_data()
    parser = argparse.ArgumentParser(description="Vacature-agent Bart Massij")
    parser.add_argument(
        "command",
        choices=["search", "inbox", "goed", "niet", "watch"],
    )
    parser.add_argument("job_id", nargs="?")
    parser.add_argument("--hours", type=float, default=3.0)
    args = parser.parse_args()
    if args.command == "search":
        return cmd_search()
    if args.command == "inbox":
        return cmd_inbox()
    if args.command == "watch":
        return cmd_watch(args.hours)
    if not args.job_id:
        print("Geef een job id: python vacature_agent.py goed abc123")
        return 1
    if args.command == "goed":
        return cmd_goed(args.job_id)
    return cmd_niet(args.job_id)


if __name__ == "__main__":
    raise SystemExit(main())
