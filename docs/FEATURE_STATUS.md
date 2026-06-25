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
| Flutter/Dart monorepo (Melos) | ✅ | 10 packages (incl. provider contract + capabilities) |
| Workspace connection (secure storage) | ✅ | QR + manual paste; `GET /v1/me` validation |
| GitHub OAuth PKCE | ✅ | Deep link `cursormc://oauth` |
| Biometric unlock | ✅ | Opt-in at onboarding |
| Onboarding flow | ✅ | Rebranded M1 copy |
| Worker list + sync | ✅ | UI: "Workers"; internal `agentId` preserved |
| Task chat + SSE streaming | ✅ | UI: worker/task terminology |
| Follow-up prompts | ✅ | Orchestrator enrichment (M2 O1) |
| Cancel run | ✅ | |
| Pin projects | ✅ | |
| Orchestrator on create | ✅ | `aivance_orchestrator` via `ExecutionProvider` |
| Provider abstraction (M3) | ✅ | `ExecutionProvider` + `CursorExecutionProvider` |
| Execution capabilities model | ✅ | `aivance_capabilities` |
| Provider registry | ✅ | `ProviderRegistry` — Cursor only |
| Offline prompt queue | ✅ | `queued_prompts` + `QueuedPromptService` |
| Connectivity detection | ✅ | `connectivity_plus` via `ConnectivityService` |
| CI/CD | ✅ | `.github/workflows/ci.yml` (M2) |
| Background notifications | ✅ | v1: local notifications + WorkManager register |
| Secure storage dual-key | ✅ | `provider_cursor_token` / `integration_github_token` |
| Provider facades | ✅ | `@Deprecated` aliases in `aivance_providers.dart` |
| Feature flags | ✅ | `feature_flags.dart` |
| Settings + OTA updates | ✅ | Partial; cleartext dev OTA |

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

## Planned (M4+)

| Item | Phase |
|------|-------|
| App package rename `cursor_mobile_commander` | M4+ |
| Project Registry (`aivance_project`) | M4 |
| Project DNA wizard | M5 |
| Multi-provider routing | M5+ |
| Presence™ module | M6 |

---

*Updated during M3 migration (2026-06-25).*
