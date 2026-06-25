---
title: M3 Completion Report — Provider Abstraction (Execution Layer)
status: IMPLEMENTATION
owner: Lead Platform Architect
last_reviewed: 2026-06-25
depends_on:
  - architecture/AIVANCE_CORE_MIGRATION_PLAN.md
  - architecture/AIVANCE_ARCHITECTURE.md
  - FEATURE_STATUS.md
---

# M3 Completion Report — Provider Abstraction (Execution Layer)

**Fase:** M3 (Aivance Core Migration Plan §4)  
**Datum:** 2026-06-25  
**Status:** ✅ Afgerond

---

## 1. Samenvatting

Migratiefase M3 introduceert de **Provider Engine abstractielaag**: businesslogica hangt af van `ExecutionProvider`, niet rechtstreeks van Cursor-packages. **Cursor blijft de enige actieve provider** via `CursorExecutionProvider`. Geen nieuwe eindgebruikersfunctionaliteit; gedrag ongewijzigd.

---

## 2. Nieuwe architectuur

```
┌─────────────────────────────────────────────────────────┐
│  Presentation (mobile / desktop)                       │
│  Riverpod: executionProviderProvider, ProviderRegistry │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  Domain / Data                                           │
│  AgentRepositoryImpl, ChatRepositoryImpl                 │
│  → ExecutionProvider (niet cursor_api_* direct)          │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  aivance_orchestrator                                    │
│  AgentCommandOrchestrator → ExecutionProvider            │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  ProviderRegistry (default: cursor)                      │
│  CursorExecutionProvider                                 │
│    → cursor_api_agents + cursor_api_stream (adapter)     │
└─────────────────────────────────────────────────────────┘
```

### Nieuwe packages

| Package | Rol |
|---------|-----|
| `aivance_capabilities` | Execution capability identifiers (`execution.chat`, …) |
| `aivance_provider_contract` | `ExecutionProvider`, DTO's, `ProviderRegistry` |
| `cursor_execution_provider` | `CursorExecutionProvider` — Cursor adapter |

---

## 3. Provider contract

`ExecutionProvider` (`aivance_provider_contract`) definieert:

| Methode | Doel |
|---------|------|
| `getCapabilities()` | Ondersteunde execution capabilities |
| `executeTask()` | Nieuwe taak/agent sessie starten |
| `continueTask()` | Follow-up op bestaande sessie |
| `cancelTask()` | Run annuleren |
| `streamTask()` | Real-time voortgang (SSE → `TaskStreamEvent`) |
| `uploadImages()` | Image attachments valideren/normaliseren |
| `uploadFiles()` | File attachments (Cursor: unsupported) |
| `downloadArtifacts()` | Artifacts + download URLs |
| `listTasks()` / `getTask()` / `getRun()` / `getUsage()` | Query helpers (backward compat) |
| `listModels()` / `listRepositories()` | UI-ondersteuning new-agent flow |

Alle methoden zijn gedocumenteerd in de interface source.

---

## 4. Provider registry & DI

- `ProviderRegistry` registreert providers op `id`, exposeert `defaultProvider`.
- Mobile: `providerRegistryProvider` + `executionProviderProvider` in `agents_provider.dart`.
- Bij bootstrap wordt **alleen** `CursorExecutionProvider` geregistreerd (`id: cursor`, default).
- Legacy facade: `executionRepositoryProvider` → `executionProviderProvider` (`@Deprecated`).

Auth (`cursor_api_core` / workspace connection) blijft een aparte concern — geen execution dispatch.

---

## 5. Dependency wijzigingen

| Component | Vóór M3 | Na M3 |
|-----------|---------|-------|
| `AgentRepositoryImpl` | `api.AgentRepository` | `ExecutionProvider` |
| `ChatRepositoryImpl` | `RunStreamService` + `api.AgentRepository` | `ExecutionProvider` |
| `AgentCommandOrchestrator` | `AgentRepository` | `ExecutionProvider` |
| `ConversationManager` | `listAgents` | `listTasks` |
| `PromptBuilder` | `CreateAgentRequest` | `ExecuteTaskRequest` |
| `chat_provider` / persister | `SseEvent` | `TaskStreamEvent` |
| `new_agent_sheet` | `RepositoryModel` | `RepoUrlUtils` |
| Desktop `CursorSession` | Direct API + orchestrator | `CursorExecutionProvider` |

**UI-laag:** geen directe `cursor_api_stream` / `cursor_api_agents` imports meer in presentation (behalve domain re-exports voor legacy DTO's in data layer).

**Orchestrator package:** geen `cursor_api_agents` dependency meer.

---

## 6. Capability model

`aivance_capabilities` definieert **execution** capabilities (geen business/Presence):

- `chat`, `streaming`, `images`, `files`, `artifacts`, `followUps`, `repositories`, `planning`, `backgroundTasks`

`CursorExecutionProvider.getCapabilities()` retourneert alle behalve `files` (expliciet unsupported).

---

## 7. Tests

| Package | Tests | Status |
|---------|-------|--------|
| `aivance_capabilities` | 2 | ✅ |
| `aivance_provider_contract` | 4 | ✅ |
| `cursor_execution_provider` | 5 | ✅ |
| `aivance_orchestrator` | 5 (incl. follow-up via `continueTask`) | ✅ |
| `cursor_mobile_commander` | 66 | ✅ |
| **Totaal workspace** | **175+** | ✅ |

---

## 8. Validatie

| Commando | Resultaat |
|----------|-----------|
| `melos bootstrap` | ✅ 10 packages |
| `melos run format-check` | ✅ |
| `melos run lint` | ✅ |
| `melos run test` | ✅ |
| `melos run build-check` (Android) | ✅ |
| `melos run build-desktop` (Windows) | ✅ |

---

## 9. Resterende technische schuld

| Item | Fase |
|------|------|
| Domain layer re-exporteert nog `CreateAgentResult`, `RunModel` (Cursor DTO's) | M4 |
| `CursorExecutionProvider` duplicate instantie in desktop session constructor | Cleanup |
| `uploadFiles` unsupported op Cursor — documenteert beperking | M3+ provider |
| Capability Router / `presence.content.blog` routing | M3 plan-deferred → Presence prep |
| ADR-008 formeel in `docs/adr/` | Documentatie follow-up |
| Auth blijft `cursor_api_core`-gebonden | Platform auth M4+ |

---

## 10. Voorbereiding M4 (Project Registry)

1. **`aivance_project` package** — Registry models los van Cursor DTO's.
2. **Orchestrator context** — lees registry snapshot i.p.v. alleen `repoUrl` string.
3. **Domain DTO migratie** — vervang `CreateAgentResult`/`RunModel` re-exports door app-owned types.
4. **ProviderRegistry** — klaar voor tweede provider; geen code change tot M5+ engine routing.
5. **Drift v2** — `pinned_projects` → registry schema (M4 scope).

---

## 11. Bewust niet gedaan (M4+)

- Claude / GPT / Gemini providers
- MCP, Presence, Project DNA, backend API
- `ExecutionProvider` multi-provider routing
- Business capabilities (`presence.*`)
- Package rename `cursor_mobile_commander`

---

*M3 afgerond 2026-06-25. Geen M4-werkzaamheden uitgevoerd.*
