---
title: Feature Status
status: IMPLEMENTATION
owner: CTO / Lead Architect
last_reviewed: 2026-06-25
depends_on:
  - research/ARCHITECTURE_AUDIT.md
  - architecture/AIVANCE_CORE_MIGRATION_PLAN.md
---

# Feature Status

Living document tracking **implemented** vs **planned** features in Aivance Core. Claims require code or test reference per [AIVANCE_DEVELOPMENT_GUIDE.md](development/AIVANCE_DEVELOPMENT_GUIDE.md).

> Baseline audit: [ARCHITECTURE_AUDIT.md](research/ARCHITECTURE_AUDIT.md) (immutable, 2026-06-25).

---

## Core platform

| Feature | Status | Notes |
|---------|--------|-------|
| Flutter/Dart monorepo (Melos) | ✅ | 5 packages + mobile + desktop apps |
| Workspace connection (secure storage) | ✅ | QR + manual paste; `GET /v1/me` validation |
| GitHub OAuth PKCE | ✅ | Deep link `cursormc://oauth` |
| Biometric unlock | ✅ | Opt-in at onboarding |
| Onboarding flow | ✅ | Rebranded M1 copy |
| Worker list + sync | ✅ | UI: "Workers"; internal `agentId` preserved |
| Task chat + SSE streaming | ✅ | UI: worker/task terminology |
| Follow-up prompts | ✅ | Direct API path (orchestrator bypass — M2 fix) |
| Cancel run | ✅ | |
| Pin projects | ✅ | |
| Orchestrator on create | ✅ | `commander_orchestrator` |
| Settings + OTA updates | ✅ | Partial; cleartext dev OTA |
| CI/CD | ❌ | M2 |
| Background notifications | ❌ | Declared deps only; M2 |

---

## UI / navigation (post-M1)

| Surface | User-facing label | Internal route / ID |
|---------|-------------------|---------------------|
| App display name | Aivance | — |
| Bottom nav tab | Workers | `/home/workers` (alias: `/home/agents`) |
| Bottom nav tab | Projects | `/home/projects` |
| Bottom nav tab | Settings | `/home/settings` |
| Connection setup | Workspace connection | `SecureStorageKeys.cursorApiKey` unchanged |

---

## Placeholder routes (not implemented)

| Route | Status |
|-------|--------|
| Project detail | Placeholder |
| Settings → Connections | Placeholder |
| Settings → Templates | Placeholder |
| PR review | Placeholder |
| GitHub file browser | Placeholder |

---

## Planned (M2+)

| Item | Phase |
|------|-------|
| Package rename `commander_orchestrator` → `aivance_orchestrator` | M2 |
| Melos workspace rename → `aivance` | M2 |
| Provider facades (`taskListProvider`, …) | M2 |
| CI/CD pipeline | M2 |
| Orchestrator on follow-up | M2 |
| ExecutionProvider abstraction | M3 |
| Project Registry | M4 |
| Project DNA wizard | M5 |
| Presence™ module | M6 |

---

*Updated during M1 migration (2026-06-25).*
