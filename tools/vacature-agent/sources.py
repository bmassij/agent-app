"""Bronnen: RSS + HTML. Weinig bronnen, geen LinkedIn-scrape."""

from __future__ import annotations

import hashlib
import json
import re
import ssl
import urllib.request
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from typing import Any
from urllib.parse import quote_plus

USER_AGENT = (
    "Mozilla/5.0 (compatible; VacatureAgent/1.0; +https://github.com/bmassij/agent-app)"
)
CTX = ssl.create_default_context()


def _get(url: str, timeout: int = 25) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
        return resp.read().decode("utf-8", errors="replace")


def _id(url: str) -> str:
    return hashlib.sha1(url.encode("utf-8")).hexdigest()[:10]


def _strip(html: str) -> str:
    text = re.sub(r"<[^>]+>", " ", html)
    return re.sub(r"\s+", " ", text).strip()


def indeed_rss(query: str, location: str) -> list[dict[str, Any]]:
    url = (
        "https://nl.indeed.com/rss"
        f"?q={quote_plus(query)}&l={quote_plus(location)}"
    )
    try:
        raw = _get(url)
    except Exception:
        return []
    jobs: list[dict[str, Any]] = []
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        return []
    for item in root.findall(".//item"):
        title = (item.findtext("title") or "").strip()
        link = (item.findtext("link") or "").strip()
        desc = _strip(item.findtext("description") or "")
        if not link:
            continue
        jobs.append(
            {
                "id": _id(link),
                "title": title,
                "company": "",
                "location": location,
                "work_mode": desc[:240],
                "summary": desc[:800],
                "url": link,
                "source": "indeed",
            }
        )
    return jobs


def freelancer_ai() -> list[dict[str, Any]]:
    url = "https://freelancer.nl/opdrachten/ai"
    try:
        html = _get(url)
    except Exception:
        return []
    jobs: list[dict[str, Any]] = []
    # Cards: heading + snippet. Freelancer markup changes; keep regex loose.
    blocks = re.findall(
        r"<h[23][^>]*>(.*?)</h[23]>(.{0,1200}?)"
        r"(?:Geplaatst|Remote|Amsterdam|Utrecht|Limburg|In overleg|€)",
        html,
        flags=re.I | re.S,
    )
    if not blocks:
        titles = re.findall(r"<h3[^>]*>(.*?)</h3>", html, flags=re.I | re.S)
        for title_html in titles[:30]:
            title = _strip(title_html)
            if len(title) < 8:
                continue
            fake = f"{url}#{title}"
            jobs.append(
                {
                    "id": _id(fake),
                    "title": title,
                    "company": "Freelancer.nl",
                    "location": "Nederland",
                    "work_mode": "freelance",
                    "summary": title,
                    "url": url,
                    "source": "freelancer.nl",
                }
            )
        return jobs

    for title_html, rest in blocks[:30]:
        title = _strip(title_html)
        snippet = _strip(rest)
        if len(title) < 8:
            continue
        loc = "Remote" if re.search(r"remote", snippet + title, re.I) else "Nederland"
        jobs.append(
            {
                "id": _id(url + title),
                "title": title,
                "company": "Freelancer.nl",
                "location": loc,
                "work_mode": snippet[:200],
                "summary": snippet[:800],
                "url": url,
                "source": "freelancer.nl",
            }
        )
    return jobs


WATCHLIST = [
    {
        "title": "AI Engineer — Renewers.ai",
        "company": "RSC",
        "location": "Panningen / Deurne / Eindhoven",
        "work_mode": "hybride mogelijk, kantoor Panningen",
        "summary": "SaaS Renewers.ai: AI-recruitment, vacaturecontent, campagnes, kandidaatopvolging.",
        "url": "https://www.rsc.nl/werken-bij/",
        "apply_email": "",
    },
    {
        "title": "Senior Full-Stack AI Engineer",
        "company": "TwoFeetUp",
        "location": "Amersfoort hybride + thuiswerken, loondienst of ZZP",
        "work_mode": "hybride thuiswerken",
        "summary": "Next.js, agents, RAG, Cursor/Claude verplicht. €6800 of ZZP.",
        "url": "https://twofeetup.com/vacatures/senior-ai-engineer",
        "apply_email": "jobs@twofeetup.com",
    },
    {
        "title": "Full Stack Developer",
        "company": "Genips",
        "location": "100% remote",
        "work_mode": "altijd remote",
        "summary": "TypeScript React Next.js, 36u, €3500-4100, thuiswerkvergoeding.",
        "url": "https://genips.nl/vacature-full-stack-developer",
        "apply_email": "",
    },
    {
        "title": "Stack Developer",
        "company": "ten50",
        "location": "Elsloo, remote-first",
        "work_mode": "remote-first",
        "summary": "Next.js/React e-commerce, PHP Laravel pré, remote is de norm.",
        "url": "https://www.nationalevacaturebank.nl/vacature/a1e07171-80e0-41c8-8882-cccdeecd5a96/stack-developer",
        "apply_email": "",
    },
    {
        "title": "AI Engineer Laravel & Python",
        "company": "Follo Agency",
        "location": "Dongen hybride",
        "work_mode": "hybride thuiswerken",
        "summary": "n8n, LLM APIs, Python, €3000-4000. Dongen ~50 min vanaf Roermond.",
        "url": "https://werkenbijfollo.recruitee.com/o/ai-engineer-laravel-python/c/new",
        "apply_email": "",
    },
    {
        "title": "AI Software Engineer",
        "company": "Bonsai Software",
        "location": "Rotterdam hybride, remote-opties",
        "work_mode": "hybride remote",
        "summary": "Python TypeScript Next.js, RAG geen must, vanaf €4000, Claude Code.",
        "url": "https://www.bonsaisoftware.nl/",
        "apply_email": "info@bonsaisoftware.nl",
    },
    {
        "title": "Web Developer",
        "company": "Indicia",
        "location": "Heerlen hybride Brightlands",
        "work_mode": "hybride thuiswerken",
        "summary": "JavaScript TypeScript PHP Drupal, 10% leertijd. Brightlands ~40 min.",
        "url": "https://www.indicia.nl/vacatures",
        "apply_email": "noa.van.ginneken@indicia.nl",
    },
    {
        "title": "Full Stack Developer",
        "company": "GradeMatch",
        "location": "Venlo hybride",
        "work_mode": "hybride thuiswerken",
        "summary": "TypeScript React, voorkeur Venlo ~25 min, €3300-5500.",
        "url": "https://gradematch.nl/",
        "apply_email": "",
    },
    {
        "title": "Fullstack Ontwikkelaar WordPress PHP JS",
        "company": "Aiwos",
        "location": "100% remote Nederland",
        "work_mode": "altijd remote, paar samenwerkdagen per jaar",
        "summary": "WordPress PHP JavaScript HTML CSS, Gravity Forms, n8n. AI in de workflow. €3200-4800. Geen ZZP.",
        "url": "https://aiwos.com/werken-bij/vacature-fullstack-ontwikkelaar-wordpress-php-js/",
        "apply_email": "info@aiwos.com",
    },
    {
        "title": "Full Stack Developer WordPress Laravel",
        "company": "Rock the Web",
        "location": "Heerlen",
        "work_mode": "internetbureau Heerlen, websites en webshops",
        "summary": "WordPress WooCommerce Laravel API automatisering AI-oplossingen. vacature@rocktheweb.nl",
        "url": "https://rocktheweb.nl/vacatures/vacature-full-stack-developer/",
        "apply_email": "vacature@rocktheweb.nl",
    },
    {
        "title": "Allround Digital & Software Developer",
        "company": "Stogger",
        "location": "Helden Peel en Maas",
        "work_mode": "fulltime Helden, websites + automatisering",
        "summary": "WordPress Elementor, interne software, automatisering, Claude/AI, websites. Dichtbij Panningen/Roermond.",
        "url": "https://www.joof.nl/vacature-allround-digital-software-developer-peel-en-maas/",
        "apply_email": "",
    },
    {
        "title": "PHP Developer Noord-Limburg",
        "company": "NGAGE IT",
        "location": "Noord-Limburg hybride",
        "work_mode": "hybride thuiswerken",
        "summary": "PHP Symfony SaaS CMS, €3500-5500. Symfony is harde eis, 4 jaar PHP.",
        "url": "https://www.ngage-it.nl/vacatures/php-developer-noord-limburg/",
        "apply_email": "",
    },
    {
        "title": "Full-stack WordPress Developer",
        "company": "Van Dyck Brown",
        "location": "Eindhoven Strijp-S",
        "work_mode": "kantoor Eindhoven, vast of freelance, AI-workflows",
        "summary": "WordPress PHP HTML CSS JS, Flutter pré. €2750-3750 of freelance. vacatures@vandyckbrown.nl",
        "url": "https://vandyckbrown.nl/werken-bij/full-stack-wordpress-developer/",
        "apply_email": "vacatures@vandyckbrown.nl",
    },
]


def watchlist() -> list[dict[str, Any]]:
    jobs = []
    for item in WATCHLIST:
        job = dict(item)
        job["id"] = _id(job["url"] + job["title"])
        job["source"] = "watchlist"
        jobs.append(job)
    return jobs


def collect() -> list[dict[str, Any]]:
    found: list[dict[str, Any]] = []
    found += watchlist()
    found += freelancer_ai()
    for q, loc in (
        ("AI engineer", "Nederland"),
        ("Next.js developer", "Limburg"),
        ("full stack TypeScript", "Limburg"),
        ("PHP webdeveloper", "Limburg"),
        ("webdeveloper", "Roermond"),
        ("webdeveloper", "Venlo"),
        ("WordPress developer", "Limburg"),
        ("frontend developer", "Limburg"),
        ("PHP webdeveloper remote", "Nederland"),
        ("AI automation n8n", "Nederland"),
    ):
        found += indeed_rss(q, loc)
    # dedup by url
    by_url: dict[str, dict[str, Any]] = {}
    for job in found:
        by_url[job["url"] + job["title"]] = job
    return list(by_url.values())
