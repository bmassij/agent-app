"""Strenge matching: weinig ruis, Roermond-eerst, goede voorwaarden."""

from __future__ import annotations

import re
from typing import Any

REJECT = "reject"
KEEP = "keep"

# Alleen écht thuiswerken. "remote-opties" / los "remote" telt niet als 100%.
_REMOTE = re.compile(
    r"\b(100%\s*remote|fully remote|remote-first|remote first|"
    r"altijd remote|volledig remote|thuisbasis)\b",
    re.I,
)
_HYBRID = re.compile(
    r"\b(hybride|hybrid|deels thuis|thuiswerken|thuis werken|"
    r"remote mogelijk|remote-opties|\bremote\b)\b",
    re.I,
)
_AI = re.compile(
    r"\b(ai engineer|ai developer|llm|rag|chatbot|agentic|openrouter|"
    r"cursor|n8n|generative ai|genai|openai|automation|"
    r"comfyui|stable diffusion|image generation|beeldgeneratie|midjourney)\b",
    re.I,
)
_STACK = re.compile(
    r"\b(next\.?js|typescript|react|php|python|flutter|javascript|"
    r"wordpress|laravel|drupal|html|css|webshop|website|"
    r"front-?end|frontend|vercel|woocommerce)\b",
    re.I,
)
_BAD = re.compile(
    r"(unpaid|geen salaris|equity only|founder cto|stageplek|\bstage\b|"
    r"internship|afstudeer|woocommerce.{0,12}€\s*3[0-9]|"
    r"phd|promovendus|databricks|5\+ jaar ervaring als full-stack)",
    re.I,
)
_LOW_RATE = re.compile(r"€\s*([1-4]\d)\s*[–—-]?\s*(?:per\s*)?(?:uur|/u)", re.I)
_PM_LANE = re.compile(
    r"\b(product manager|product lead|product owner|technical product manager)\b",
    re.I,
)
_NATIVE_MOBILE = re.compile(r"\b(kotlin|swiftui|\bswift\b|jetpack compose)\b", re.I)
_CROSS_MOBILE = re.compile(r"\b(flutter|dart|react native)\b", re.I)


def _blob(job: dict[str, Any]) -> str:
    parts = [
        str(job.get("title") or ""),
        str(job.get("company") or ""),
        str(job.get("location") or ""),
        str(job.get("work_mode") or ""),
        str(job.get("summary") or ""),
        str(job.get("url") or ""),
    ]
    return " ".join(parts)


def _place_text(job: dict[str, Any]) -> str:
    """Locatie alleen uit titel/bedrijf/plaats/modus — niet uit de samenvatting.

    Anders scoort 'vanaf Roermond' in een toelichting als kantoor in Roermond.
    """
    return " ".join(
        [
            str(job.get("title") or ""),
            str(job.get("company") or ""),
            str(job.get("location") or ""),
            str(job.get("work_mode") or ""),
        ]
    )


def _has_nearby(text: str, nearby: list[str]) -> str | None:
    lower = text.lower()
    for city in nearby:
        if city.lower() in lower:
            return city
    return None


def score_job(job: dict[str, Any], profile: dict[str, Any]) -> dict[str, Any]:
    text = _blob(job)
    places = _place_text(job)
    reasons: list[str] = []
    points = 0

    if _BAD.search(text):
        return {
            "decision": REJECT,
            "score": 0,
            "reasons": ["afgewezen: stage/unpaid/te zwaar of te goedkoop"],
        }

    rate = _LOW_RATE.search(text)
    if rate and int(rate.group(1)) < int(profile.get("min_freelance_eur") or 55):
        return {
            "decision": REJECT,
            "score": 0,
            "reasons": [f"uurtarief onder €{profile['min_freelance_eur']}"],
        }

    title_raw = str(job.get("title") or "")
    if _PM_LANE.search(title_raw):
        return {
            "decision": REJECT,
            "score": 0,
            "reasons": ["afgewezen: productrol, geen builder/engineer"],
        }
    if _NATIVE_MOBILE.search(text) and not _CROSS_MOBILE.search(text):
        return {
            "decision": REJECT,
            "score": 0,
            "reasons": ["afgewezen: native Kotlin/Swift, geen Flutter"],
        }

    nearby_hit = _has_nearby(places, profile.get("nearby") or [])
    far_hit = _has_nearby(places, profile.get("far_office_reject") or [])
    fully_remote = bool(_REMOTE.search(text))
    hybrid = bool(_HYBRID.search(text))

    if far_hit and not fully_remote and not hybrid and not nearby_hit:
        return {
            "decision": REJECT,
            "score": 0,
            "reasons": ["kantoor te ver vanaf Roermond, geen thuiswerk"],
        }

    if fully_remote:
        points += 30
        reasons.append("remote/thuiswerk")
    elif hybrid:
        points += 18
        reasons.append("hybride")
    elif nearby_hit:
        points += 12
        reasons.append(f"dichtbij: {nearby_hit}")
    else:
        points -= 10
        reasons.append("locatie/thuiswerk onduidelijk")

    if nearby_hit:
        points += 16
        if "dichtbij" not in " ".join(reasons):
            reasons.append(f"regio {nearby_hit}")

    if far_hit and not fully_remote:
        points -= 18
        reasons.append("kantoor ver (alleen oké bij veel thuis)")

    if _AI.search(text):
        points += 20
        reasons.append("AI/automatisering")
    if _STACK.search(text):
        points += 14
        reasons.append("stack-match")

    title = (job.get("title") or "").lower()
    for role in profile.get("roles_want") or []:
        if role.lower() in title:
            points += 8
            reasons.append(f"rol: {role}")
            break

    if points < 40:
        return {
            "decision": REJECT,
            "score": points,
            "reasons": reasons + ["score te laag — zou ruis zijn"],
        }

    return {"decision": KEEP, "score": points, "reasons": reasons}
