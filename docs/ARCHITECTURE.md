# Architecture
# Cursor Mobile Commander

---

## System Overview

Cursor Mobile Commander is a **pure mobile client**. There is no backend server. All agent intelligence lives in Cursor Cloud. The app is a management and communication layer.

```
Flutter App → api.cursor.com/v1  (Cursor Cloud Agents)
Flutter App → api.github.com     (GitHub REST API)
Cursor Cloud → GitHub            (agent clones, commits, pushes PRs)
```

---

## Layer Architecture

The app is divided into four layers. Each layer has a single responsibility and communicates only with the layer directly below it.

```
┌─────────────────────────────────────────┐
│  Presentation (UI)                      │
│  Screens, Widgets, Riverpod Providers   │
│  → reads Domain state                   │
├─────────────────────────────────────────┤
│  Domain                                 │
│  Repository Interfaces, Models, Errors  │
│  → defines contracts; no Flutter        │
├─────────────────────────────────────────┤
│  Data                                   │
│  Repository Implementations             │
│  Remote Sources (HTTP/SSE)              │
│  Local Sources (Drift/SQLite)           │
├─────────────────────────────────────────┤
│  Platform                               │
│  Background Polling (WorkManager)       │
│  Local Notifications                    │
│  Biometric / Secure Storage             │
└─────────────────────────────────────────┘
```

**Rule:** The UI layer never calls HTTP. The Data layer never imports Flutter widgets. The Domain layer never imports packages — it is pure Dart.

---

## Package Architecture

```
cursor_mobile_commander/
├── apps/mobile/           ← Flutter application
├── packages/
│   ├── cursor_api_core/   ← HTTP client, error types, auth injection
│   ├── cursor_api_agents/ ← Agent + Run CRUD
│   ├── cursor_api_stream/ ← SSE parser, reconnector
│   └── github_api/        ← GitHub REST, OAuth, rate limiter
```

Each package is independently testable and has no dependency on the Flutter app.

---

## Feature Module Structure

Every feature follows this exact structure. Cursor Agents must follow this convention.

```
features/{name}/
├── data/
│   ├── {name}_repository_impl.dart
│   └── {name}_remote_source.dart
├── domain/
│   ├── {name}_repository.dart       ← abstract interface
│   ├── {name}_model.dart            ← immutable data class
│   └── {name}_failure.dart          ← sealed error class
├── presentation/
│   ├── {name}_screen.dart
│   ├── {name}_provider.dart
│   └── widgets/
└── {name}_module.dart               ← barrel export
```

---

## State Management

Riverpod is used for all state management. Provider type rules are mandatory:

| Use Case | Provider Type |
|---|---|
| Async server data | `AsyncNotifierProvider` |
| Streaming server data | `StreamProvider` |
| UI-only state | `NotifierProvider` |
| Derived/computed state | `Provider` |
| Per-instance state | `*.family` variant |

Never use `StateProvider` for server data. Never use `FutureProvider` for data that needs `refresh()`.

---

## Navigation

go_router is used for all navigation. The full route tree is defined in `apps/mobile/lib/app/router.dart`. Route paths are defined as constants in `apps/mobile/lib/app/routes.dart`.

Auth guard: any route except `/onboarding/**` redirects to `/onboarding` if no valid API key is found in secure storage.

---

## Data Flow: Agent Chat Session

```
1. User creates new agent
   └─ NewAgentSheet filled
   └─ POST /v1/agents { repos, messages, model, mode }
   └─ AgentSession saved to SQLite
   └─ RunRecord saved to SQLite
   └─ Navigate to ChatScreen

2. ChatScreen opens
   └─ Load ChatMessage history from SQLite (instant)
   └─ Open SSE stream on latest runId
   └─ Render incoming SseEvents as message bubbles
   └─ Persist each event to SQLite

3. SSE disconnects
   └─ ReconnectionManager waits 1s → 2s → 4s → max 30s
   └─ Retry with Last-Event-ID header
   └─ Fallback: poll GET /runs/{runId} every 10s

4. Run completes (status=FINISHED)
   └─ Fetch /usage → save UsageRecord
   └─ Show token count in RunLogsScreen
   └─ Composer re-enables (ready for follow-up)

5. User sends follow-up
   └─ POST /v1/agents/{id}/runs
   └─ New RunRecord saved
   └─ New SSE stream opened
   └─ Messages appended to existing chat view
```

---

## Offline Architecture

When `ConnectivityService.isOnline` is false:
- All screens show cached data from SQLite
- Compose/send is replaced with queued send (QueuedPrompt table)
- Offline banner is shown
- On reconnect: QueuedPromptService processes pending prompts sequentially

---

## Background Agent Monitoring

WorkManager (Android) / BGTaskScheduler (iOS) runs every 120 seconds when the app is backgrounded:
1. Query SQLite for active RunRecords
2. GET /v1/agents/{id}/runs/{runId} for each
3. On status change: update SQLite + fire local notification

---

## Security Architecture

- API keys stored in OS keychain via `flutter_secure_storage`
- Keys never stored in SQLite, logs, or crash reports
- TLS 1.3 minimum; certificate pinning on both APIs
- Biometric auth gate on launch and after idle timeout
- Screen content hidden when app is backgrounded (FLAG_SECURE / blur)

See [SECURITY.md](SECURITY.md) for full details.

---

## Architecture Decision Records

All architecture decisions are documented in `PHASE2_IMPROVED_ARCHITECTURE.md` (ADR section). Key decisions:

- **ADR-001:** No backend server
- **ADR-002:** Riverpod over Bloc
- **ADR-003:** Split cursor_api into 3 packages
- **ADR-004:** Drift over Hive/Isar
- **ADR-005:** melos is mandatory
