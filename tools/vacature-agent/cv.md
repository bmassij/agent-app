# Curriculum Vitae

**Bart Massij**
AI Software Developer | LLM-integratie, automatisering & productontwikkeling

Roermond, Nederland
06 52669690 · bartmassij@gmail.com
GitHub: [github.com/bmassij](https://github.com/bmassij)
Live werk: [monra-security.nl](https://www.monra-security.nl) · [last-wat-optimizer.vercel.app](https://last-wat-optimizer.vercel.app)

---

## Profiel — waarom deze rol

Ik bouw software waarin AI **werk uitvoert**, niet alleen tekst genereert. De afgelopen jaren heb ik zelfstandig AI-producten ontworpen en live gezet: van LLM-chat met kennisbank en model-fallback tot RAG met embeddings, vision-classificatie, **image generation met ComfyUI**, en een agent-orchestrator die taken naar uitvoerende agents stuurt.

Dat sluit direct aan op **Renewers.ai**: een SaaS waarin AI vacaturecontent maakt, campagnes helpt opzetten, kandidaten opvolgt en recruitmentwerk uit handen neemt. Mijn sterkte is het vertalen van een bedrijfsproces naar een werkend systeem — API’s, data, prompts, fallback en een bruikbare interface.

Ik leer door te bouwen. Geen onderzoekslab, maar productgerichte AI-engineering: promptontwerp, structured output, modelrouting, embeddings/RAG en automatisering in echte toepassingen.

Mijn werkomgeving is AI-native: **Cursor**, **Claude**, **Roo Code** en **LM Studio** (lokale LLM’s). Dat is hoe ik sneller lever en stack-gaten dicht — in de codebase, met mij als eigenaar van de code.

---

## Wat ik kan — eerlijk niveau

| Gebied | Niveau | Waar het in zit |
|---|---|---|
| TypeScript / JavaScript / Next.js | **Productieniveau** | Monra, Spaanse Tuinen, Last War Optimizer |
| PHP, HTML, CSS | **Opleiding + toegepast** | Slim in ICT front- + backend, ca. 2019–2020 |
| LLM-integratie (OpenRouter, OpenAI-compatible API’s) | **Productieniveau** | Chat, vision, modelrotatie, rate-limit fallback |
| Prompt engineering & structured output | **Sterk** | System prompts, JSON-parsing, intent-analyse |
| RAG / embeddings | **Toegepast** | Chroma + sentence-transformers; kennisgestuurde chat |
| Vision / multimodal (beelden lezen) | **Toegepast** | OpenRouter vision-modellen; Florence-2 classificatie |
| Image generation (beelden maken) | **Toegepast / hands-on** | ComfyUI-workflows (Stable Diffusion-pipeline): nodes, prompts, modelkeuze |
| Agent orchestration | **Toegepast** | Context bouwen, intent, dispatch naar execution providers |
| Flutter / Dart | **Sterk** | Aivance: layered architecture, Riverpod, Drift, SSE, OAuth |
| Python | **Werkend / toegepast** | Indexers, embeddings, scrapers, vision-scripts |
| REST API’s, Git/GitHub, Vercel | **Productieniveau** | Alle recente webprojecten |
| AI-coding (Cursor, Claude, Roo Code) | **Dagelijks / productieniveau** | Alle recente projecten; eigen Roo-regels en agent-workflows |
| Lokale LLM’s (LM Studio, GGUF, OpenAI-compatible) | **Toegepast** | Local inference, Roo↔LM Studio-compat, Qwen/embeddings |
| FastAPI, PostgreSQL, Redis, Docker | **Niet als kernclaim** | Komt niet hard terug in de publieke repos; wel bekend van lokale experimenten |

**Geen overclaim:** ik ben geen ML-onderzoeker en train geen eigen foundation models. Ik ontwerp en bouw AI-native software: integratie, orchestration, dataverwerking en product.

---

## Projecten (aantoonbaar)

### Aivance — agent orchestration & mobile client
*Eigen product · Flutter/Dart monorepo · [github.com/bmassij/agent-app](https://github.com/bmassij/agent-app)*

Platform om digitaal werk te delegeren aan AI-agents vanaf mobiel. Geen chatdemo: een client + orchestratielaag boven uitvoerende agents.

- Orchestrator: repo-context scannen, prompt intent analyseren, briefing bouwen, follow-ups hergebruiken, dispatch via `ExecutionProvider`
- Provider-abstractie zodat execution niet hard aan één vendor vastzit
- Realtime agent-output via SSE, reconnect + polling-fallback
- GitHub OAuth (PKCE), REST-integratie, lokale persistentie (Drift/SQLite)
- Offline prompt-queue, biometric unlock, layered architecture (UI → domain → data)
- Melos-monorepo, CI, testdekking op orchestrator en API-lagen

**Relevant voor RSC:** AI die taken uitvoert in een workflow, niet alleen antwoorden geeft.

### Monra — multi-brand SaaS-site met AI-assistent
*Opdracht / productwerk · Next.js, TypeScript · live: [monra-security.nl](https://www.monra-security.nl)*

Vijf merken (Security, Support, Events, België, Groep) in één Next.js-codebase, met een AI-assistent die de bedrijfsprocessen kent.

- OpenRouter-integratie met round-robin over meerdere LLM’s en fallback bij 429/502/503
- Kennisgestuurde system prompts + FAQ-fallback (geen kale chatbot)
- Routing naar de juiste tak (NL / BE / hospitality / events)
- Contactflow, SEO (sitemap, canonicals, JSON-LD), Vercel-deploy
- Architectuurplan voor lokale RAG-assistent (Ollama + embeddings + FastAPI) als volgende stap

**Relevant voor RSC:** merkinhoudelijke AI, content/kennis per doelgroep, live in productie.

### Spaanse Tuinen — contentplatform + RAG + vision
*Opdracht · Next.js + Python*

Migratie van een contentzware site naar Next.js, plus een eigen zoek-/kennislaag.

- Contentpipeline: scrape → normalisatie → JSON → Next.js-pagina’s
- Python-indexer met **Chroma** en lokale embeddings (`sentence-transformers` / MiniLM)
- Filesystem watcher voor herindexeren; zoeken op tekst én embedding
- Beeldclassificatie met **Florence-2** (Hugging Face / Transformers) voor hero-images en categorieën

**Relevant voor RSC:** RAG, classificatie, content op schaal — dezelfde bouwstenen als vacaturecontent en kandidaatscreening.

### Last War Optimizer (ORC) — vision-LLM + knowledge app
*Eigen product · Next.js 15 · live: [last-wat-optimizer.vercel.app](https://last-wat-optimizer.vercel.app)*

Advisor-app die schermafbeeldingen analyseert en gestructureerde data teruggeeft.

- Vision-modellen via OpenRouter (keten + fallback)
- Structured output: modeltekst parsen naar bruikbare inventory/resultaten
- Discord API-feed, interne knowledge base, client-side engines
- Meertalige UI (NL/EN/DE/FR/ES)

**Relevant voor RSC:** vision + structured extraction — vergelijkbaar met het uitlezen van cv’s, screenshots of campagne-assets.

### ComfyUI — image generation (workflows)
*Hands-on · geen publieke repo*

Beelden **maken**, niet alleen lezen. Node-workflows in ComfyUI (Stable Diffusion-pipeline): modelkeuze, prompts, itereren tot bruikbare output. Geen eigen foundation model, geen “ik drukte één keer op Generate”. Wel: een pipeline die je kunt herhalen.

**Relevant voor RSC:** Renewers maakt vacaturevisuals met AI. Dit is die kant: genereren van assets, naast Florence-2/vision om bestaande beelden te classificeren of uitlezen.

### Dare-kaartspel — AI-contentgeneratie + spelproduct
*Eigen product*

Interactief kaart-/dare-spel waarvan de opdrachten niet met de hand zijn verzonnen, maar via een **generatiepipeline** gaan: templates → lokaal/cloud-LLM → validatie tegen schema → kwaliteitscheck → opslag. Eén database, vaste niveaus, geen dubbele of rommelige content.

- Content generation system (niet “ChatGPT openen en plakken”)
- Schema, validatie en duplicate detection vóór iets live mag
- Werkt met lokale modellen (LM Studio) én API-modellen
- Volledig spel gebouwd: regels, niveaus, UI/flow

**Relevant voor RSC:** exact het Renewers-probleem — AI die vacatureteksten/content maakt die **klopt**, niet zomaar tekst spuugt.

### AI-ontwikkelstraat (hoe ik werk)
Niet één tool: een keten.

- **Cursor** — cloud agents, orchestration, dagelijks bouwen
- **Claude** — redeneren, architectuur, lastige refactors
- **Roo Code** — lokale agent in de editor, met eigen projectregels/guardrails (o.a. Spaanse Tuinen)
- **LM Studio** — lokale LLM-inference, OpenAI-compatible API, koppeling vanuit Python/apps
- **ComfyUI** — lokale image-generation workflows (naast LM Studio voor tekstmodellen)
- Compat-laag zodat Roo betrouwbaar tegen lokale modellen praat (geen kapotte tool-calls)

Daarmee dichten we een onbekende stack (PHP, n8n, extra API) in dagen in *jullie* repo — ik review en begrijp elke wijziging.

### Overige eigen / experimentele systemen
*(Uit eerdere bouwperiodes; niet allemaal publiek op GitHub. Alleen noemen als je de architectuur in een gesprek hard kunt maken.)*

- **Inbox-/maildata:** classificatie en opschoning van grote e-mailsets, metadata en clustering
- **Multi-agent experimenten:** gespecialiseerde agents + orchestrator (nieuws, sentiment, risico)
- **Bot-/automatiseringsomgevingen:** Docker-gebaseerde, modulaire bots en API-koppelingen
- **Lokale LLM’s:** LM Studio, GGUF, Qwen, embeddings, tool calling, Roo↔local inference
- **WhatsApp-exportanalyse:** segmentatie en classificatie van gespreksdata — direct relevant voor WhatsApp-opvolging in recruitment

---

## Werkervaring

### Zelfstandig software- & AI-ontwikkelaar
**2021 – heden · Roermond**

Eigen producten en opdrachtwerk: AI-integratie, webapps, contentplatforms, automatisering, vision én image generation (ComfyUI). Van ontwerp tot live deploy (Vercel/GitHub). Werkt documentatiegedreven: architectuur, guardrails en tesbare pipelines vóór featurewerk.

### Software Engineer — AT-Automation B.V.
**mei 2019 – dec 2020 · Weert**

Industriële automatisering. Software met Ignition (Inductive Automation) voor HMI/SCADA. Ignition 8.1 Core Certified. Specificatie naar werkende schermen/koppelingen in een productieteam (~30 min vanaf Roermond).

### ICT-adviseur — Pandhuis / Chimera
**2017 – 2019**

Systeemoplossingen, websites/webshop, AVG-implementatie, klantensysteem, vertalen van bedrijfsbehoefte naar werkbare ICT.

### Eerdere rollen (verkort)
- **UPS** — magazijn / operationele ondersteuning (2014–2015): data-invoer, ordercontrole, aansturen
- **Bibliotheken Maas en Peel** — communicatie (2011–2013): website, campagnes, interne/externe communicatie
- **Neerlands Best Kozijnen / Hof Promotie** — vertegenwoordiging (2008–2011): klantadvies en verkoop

---

## Technische stack (alleen wat ik daadwerkelijk gebruik)

**Talen:** TypeScript, JavaScript, PHP, HTML, CSS, Dart, Python  
**Frontend / apps:** Next.js, React, Flutter, Tailwind  
**AI:** Cursor, Claude, Roo Code, LM Studio, ComfyUI, OpenRouter, lokale GGUF-modellen, prompt design, structured output, embeddings, Chroma, Florence-2, vision-LLMs, image generation, agent dispatch, contentgeneratie-pipelines  
**Data & API:** REST, SSE, GitHub API, OAuth PKCE, SQLite/Drift, JSON-contentpipelines  
**Productie:** Git/GitHub, Vercel, CI-workflows, Melos-monorepo  

---

## Persoonlijke sterktes (kort)

Zelfstandig complete systemen neerzetten. Denken vanuit het proces, daarna de tech. Snel nieuwe modellen en API’s in een werkende flow krijgen. Combinatie van bouwervaring, communicatieachtergrond en praktische AI-toepassing.

---

## Opleiding

**Slim in ICT — Webdeveloper (front-end én back-end)**  
circa 2019 – 2020  
HTML, CSS, PHP

Praktische beroepsopleiding: websites bouwen aan de voorkant (HTML/CSS) en server-side (PHP). Dat is de basis onder later werk in TypeScript/Next.js — en de reden dat PHP-shops (Laravel, WordPress, Drupal) voor mij geen vreemde wereld zijn, ook als een specifiek framework nieuw is.

---

## Links

- GitHub: https://github.com/bmassij
- Monra (live AI-chat): https://www.monra-security.nl
- Last War Optimizer: https://last-wat-optimizer.vercel.app
- LinkedIn: *[invullen]*
