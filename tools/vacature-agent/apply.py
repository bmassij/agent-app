"""Sollicitatie schrijven na 'goed'. Versturen alleen met SMTP in contact.json."""

from __future__ import annotations

import json
import smtplib
from email.message import EmailMessage
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "data" / "applications"
CONTACT = ROOT / "contact.json"

# Korte extra alinea per bekende werkgever. Geen overclaims.
_HOOKS = {
    "RSC": (
        "Panningen is een korte rit vanuit Roermond; Deurne en Eindhoven ook. "
        "Hybride: bouwen vanuit huis, overleg op kantoor. "
        "Vacaturecontent die moet kloppen (geen slop) is hetzelfde probleem als "
        "mijn LLM-contentpipeline: genereren → valideren → opslaan."
    ),
    "ten50": (
        "Remote-first past: productief thuis, Elsloo wanneer het team dat wil (~30 min). "
        "PHP, HTML en CSS: opleiding Slim in ICT, front-end én back-end, circa 2019–2020. "
        "Laravel/Symfony is het framework eromheen; conventies leer ik in jullie repo."
    ),
    "Genips": (
        "100% remote vanuit Roermond is een plus. TypeScript, React, Next.js, Git in productie. "
        "NestJS niet dagelijks — Next.js API-routes en REST wel. Nieuwe stukken pak ik in jullie repo op."
    ),
    "Follo Agency": (
        "Kantoorvoorkeur Dongen (~50 min). Groningen/Gent te ver wekelijks. "
        "Laravel is niet mijn dagelijkse framework; PHP wél (Slim in ICT, 2019–2020). "
        "De AI-laag (LLM APIs, n8n) bouw ik meteen."
    ),
    "TwoFeetUp": (
        "Jullie vragen Cursor/Claude als dagelijkse workflow — die staat. "
        "Amersfoort is te ver voor 4 kantoordagen; één kantoordag + thuis is werkbaar. "
        "Loondienst of ZZP: beide."
    ),
    "Bonsai Software": (
        "Dagelijks Rotterdam past niet. Hybride met zwaartepunt thuis en geclusterd kantoor wel. "
        "AI-assisted development is hoe ik lever: Python, TypeScript, Next.js, agents in de editor."
    ),
    "Indicia": (
        "Roermond → Brightlands Heerlen ~40 min. Hybride: kantoor voor pairing, thuis voor bouwen. "
        "PHP, HTML en CSS: Slim in ICT, 2019–2020. Drupal/Vue leer ik in jullie codebase."
    ),
    "GradeMatch": (
        "Voorkeur Venlo (~25 min). Maastricht/Eindhoven hybride ook. "
        "TypeScript/React/Next.js in productie. .NET/Java niet als hoofdtaal; "
        "patterns in jullie services doorgrond ik in dagen, in de repo."
    ),
}


def load_contact() -> dict[str, Any]:
    if CONTACT.exists():
        return json.loads(CONTACT.read_text(encoding="utf-8"))
    example = ROOT / "contact.example.json"
    return json.loads(example.read_text(encoding="utf-8"))


def write_letter(job: dict[str, Any], profile: dict[str, Any], contact: dict[str, Any]) -> Path:
    OUT.mkdir(parents=True, exist_ok=True)
    company = str(job.get("company") or "team")
    hook = _HOOKS.get(company, "")
    if hook:
        hook = hook + "\n\n"
    live = ", ".join(profile.get("live") or [])
    body = f"""Onderwerp: Sollicitatie {job.get("title")} — {contact.get("city")}

Beste {company},

Ik solliciteer naar {job.get("title")}.

Ik woon in Roermond. Remote of hybride met thuiswerken is voor mij essentieel. {job.get("location") or ""}

Ik bouw software waarin AI werk uitvoert, niet alleen tekst. Live: {live}. Daarnaast RAG, vision en agent-orchestration ({profile.get("github")}). Opleiding: {profile.get("education")}.

Ik werk AI-native: Cursor, Claude, Roo Code en LM Studio (lokale LLM's). Geen chat ernaast — agents in de editor, eigen projectregels. Daardoor lever ik sneller, en dichten we stack-gaten in jullie codebase. Ik blijf eigenaar van de code.

{hook}Zelf een dare-kaartspel gebouwd met LLM-contentpipeline (template → model → validatie → opslag): content die moet kloppen, geen ruis.

Waarom deze match: {", ".join(job.get("reasons") or [])}

Direct beschikbaar.

Met vriendelijke groet,
{contact.get("full_name")}
{contact.get("city")} · {contact.get("phone")} · {contact.get("email")}
{profile.get("github")}
"""
    path = OUT / f"{job['id']}.txt"
    path.write_text(body.strip() + "\n", encoding="utf-8")
    return path


def try_send(letter_path: Path, job: dict[str, Any], contact: dict[str, Any]) -> str:
    host = (contact.get("smtp_host") or "").strip()
    to_addr = (job.get("apply_email") or "").strip()
    if not host or not to_addr:
        return (
            "Brief klaar. Niet verstuurd: zet apply_email op de vacature "
            "en SMTP in contact.json, of plak de brief handmatig via de link."
        )
    msg = EmailMessage()
    msg["Subject"] = f"Sollicitatie {job.get('title')}"
    msg["From"] = contact.get("email")
    msg["To"] = to_addr
    msg.set_content(letter_path.read_text(encoding="utf-8"))
    with smtplib.SMTP(host, int(contact.get("smtp_port") or 587)) as smtp:
        smtp.starttls()
        smtp.login(contact.get("smtp_user"), contact.get("smtp_password"))
        smtp.send_message(msg)
    return f"Verstuurd naar {to_addr}"


def try_notify(pending: list[dict[str, Any]], new_ids: list[str], contact: dict[str, Any]) -> str:
    """Mail Bart alleen als er nieuwe matches zijn én SMTP klaarstaat."""
    if not new_ids:
        return ""
    host = (contact.get("smtp_host") or "").strip()
    to_addr = (contact.get("notify_email") or contact.get("email") or "").strip()
    if not host or not to_addr:
        return "Melding: inbox bijgewerkt. Geen mail: SMTP ontbreekt in contact.json."
    lines = ["Nieuwe vacatures ter beoordeling. Antwoord in Cursor: goed ID of niet ID.", ""]
    for job in pending:
        if job.get("id") not in new_ids:
            continue
        lines.append(f"- [{job.get('id')}] {job.get('score')} {job.get('title')} ({job.get('company')})")
        lines.append(f"  {job.get('url')}")
    msg = EmailMessage()
    msg["Subject"] = f"Vacature-agent: {len(new_ids)} nieuwe match(es)"
    msg["From"] = contact.get("email")
    msg["To"] = to_addr
    msg.set_content("\n".join(lines))
    with smtplib.SMTP(host, int(contact.get("smtp_port") or 587)) as smtp:
        smtp.starttls()
        smtp.login(contact.get("smtp_user"), contact.get("smtp_password"))
        smtp.send_message(msg)
    return f"Melding gemaild naar {to_addr}"
