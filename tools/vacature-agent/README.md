# Vacature-agent (Bart Massij)

Zoekt vacatures/ZZP die bij het profiel passen, **filtert ruis** (te ver kantoor, stage, te laag tarief), legt matches in een inbox. Jij zegt **goed** of **niet**. Bij goed schrijft de agent de sollicitatie en verstuurt die als SMTP + `apply_email` klaarstaan.

Er gaat **nooit** een mail de deur uit zonder `goed`.

Deze cloud-VM draait niet 24/7. Op jouw machine: `watch --hours 3`. In Cursor: agent opnieuw `search` laten doen.

## Gebruik

```bash
cd tools/vacature-agent
python3 vacature_agent.py search    # zoeken + filteren
python3 vacature_agent.py inbox     # openstaande matches
python3 vacature_agent.py goed abc123
python3 vacature_agent.py niet abc123
python3 vacature_agent.py watch --hours 3   # blijft zoeken
```

Kopieer `contact.example.json` naar `contact.json` (staat niet in git) voor naam/mail/SMTP. Met SMTP mailt `search` nieuwe matches naar `notify_email`, en `goed` de sollicitatie naar `apply_email` van de vacature.

## Wat eruit wordt gefilterd

- Kantoor Randstad/Gent zonder 100% remote / remote-first
- Losse "remote-opties" telt **niet** als fully remote
- Stage, unpaid, equity-only
- Uurtarief onder €55
- Score te laag (geen stack, geen thuiswerk, te ver)

## Wat erin mag

- Remote / remote-first / hybride + thuiswerken
- Binnen ~60 min van Roermond (Venlo, Elsloo, Panningen, Heerlen, Dongen, Maastricht, Eindhoven, …)
- Websites, WordPress, PHP, HTML/CSS, front-end, Next.js, TypeScript — AI-rol is een plus, geen eis
- AI Engineer / ComfyUI / n8n als het toevallig past

## Cursor-agent (jij keurt goed)

1. Run `python3 tools/vacature-agent/vacature_agent.py search`
2. Toon alleen de inbox (niet de afgewezen ruis)
3. Wacht tot Bart **goed <id>** of **niet <id>** zegt
4. Bij goed: `python3 tools/vacature-agent/vacature_agent.py goed <id>` — brief klaar, mail als SMTP gezet is

Niet solliciteren zonder expliciet **goed**.
