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
        "mijn LLM-contentpipeline: genereren → valideren → opslaan. "
        "Renewers maakt ook visuals: ComfyUI/image generation heb ik hands-on gedaan "
        "(workflows, prompts, modelkeuze) — naast vision om beelden te lezen."
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
        "De AI-laag (LLM APIs, n8n) bouw ik meteen. "
        "Campagnebeelden: ComfyUI-workflows voor image generation, niet alleen tekst."
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
    "Aiwos": (
        "100% remote vanuit Roermond past. PHP, HTML, CSS: Slim in ICT. "
        "WordPress-themes/plugins leer ik in jullie repo (hooks, CPT's) met Cursor/Claude. "
        "n8n en AI-in-de-workflow is hoe ik al werk. Geen ZZP: loondienst."
    ),
    "Rock the Web": (
        "Heerlen ~40 min. WordPress/PHP-basis is er; Laravel en WooCommerce in jullie codebase, "
        "versneld met Cursor. AI-koppelingen en automatisering bouw ik mee."
    ),
    "Stogger": (
        "Helden is dichtbij Roermond. WordPress/Elementor-websites + automatisering + Claude: "
        "dat is precies hoe ik lever. Geen specialist-op-één-tool, wel bouwen tot het live staat."
    ),
    "NGAGE IT": (
        "Noord-Limburg hybride. PHP heb ik (opleiding + toepassen). Symfony is het framework "
        "eromheen — in jullie CMS-repo, met tests, niet als vijf jaar Symfony op papier."
    ),
    "Van Dyck Brown": (
        "Eindhoven Strijp-S ~55 min, vast of freelance. WordPress/PHP/HTML/CSS, Flutter ken ik "
        "uit Aivance. AI-workflows om sneller te bouwen: Cursor/Claude/Roo. Freelance als het salaris krap is."
    ),
    "Apply Recruitment": (
        "Sollicitatie via https://www.applyrecruitment.com/vacatures/ai-engineer "
        "(ook werk.nl DGR72694329). Consultancy, €4500–€7500, deels thuiswerken.\n\n"
        "De technische helft is hoe ik al werk: AI-tools (Cursor, Claude, Roo Code, LM Studio), "
        "workflows en templates, agents, kwaliteit van output. Python en API’s in toegepaste "
        "projecten. Image generation hands-on met ComfyUI.\n\n"
        "De andere helft — organisatiebrede workshops, managementadvies, later klanten — "
        "doe ik niet als fulltime trainer. Wel: mensen 1-op-1 meenemen in wat werkt, "
        "kennis omzetten naar herbruikbare configs. Groei naar consulting is interessant "
        "als de technische basis eerst staat.\n\n"
        "Opleiding: Slim in ICT, webdeveloper front-end én back-end (HTML, CSS, PHP), "
        "circa 2019–2020. Geen HBO-diploma. Als HBO een harde eis is, hoor ik dat graag meteen."
    ),
}

# Opening over locatie: default remote-eerst, behalve kantoor om de hoek.
_LEADS = {
    "Apply Recruitment": (
        "Ik woon in Roermond (Castorstraat). Weert is ~20 min; ik werkte daar als "
        "Software Engineer bij AT-Automation (mei 2019–dec 2020). Deels thuiswerken "
        "op de vacature past."
    ),
}


def _company_key(company: str, table: dict[str, str]) -> str | None:
    if company in table:
        return company
    lower = company.lower()
    for key in table:
        if key.lower() in lower:
            return key
    return None


def _salutation(job: dict[str, Any], company: str) -> str:
    name = str(job.get("contact_name") or "").strip()
    if name:
        return f"Beste {name.split()[0]},"
    return f"Beste {company},"


def _lead(job: dict[str, Any], company: str) -> str:
    key = _company_key(company, _LEADS)
    if key:
        return _LEADS[key]
    loc = str(job.get("location") or "").strip()
    line = "Ik woon in Roermond. Remote of hybride met thuiswerken is voor mij essentieel."
    return f"{line} {loc}".strip()


def load_contact() -> dict[str, Any]:
    if CONTACT.exists():
        return json.loads(CONTACT.read_text(encoding="utf-8"))
    example = ROOT / "contact.example.json"
    return json.loads(example.read_text(encoding="utf-8"))


def write_letter(job: dict[str, Any], profile: dict[str, Any], contact: dict[str, Any]) -> Path:
    OUT.mkdir(parents=True, exist_ok=True)
    company = str(job.get("company") or "team")
    hook_key = _company_key(company, _HOOKS)
    hook = _HOOKS.get(hook_key, "") if hook_key else ""
    if hook:
        hook = hook + "\n\n"
    live = ", ".join(profile.get("live") or [])
    body = f"""Onderwerp: Sollicitatie {job.get("title")} — {contact.get("city")}

{_salutation(job, company)}

Ik solliciteer naar {job.get("title")}.

{_lead(job, company)}

Ik bouw websites en webapps: PHP, HTML, CSS (Slim in ICT, front-end én back-end, ca. 2019–2020), TypeScript, Next.js. Live: {live}. GitHub: {profile.get("github")}.

AI is hoe ik lever, niet de eis aan de vacature: Cursor, Claude, Roo Code, LM Studio. Stack-gaten (Laravel, WordPress, n8n) dicht ik in jullie repo; ik review en begrijp elke wijziging.

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
