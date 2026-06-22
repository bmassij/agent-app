# Phase 2 — Improved Architecture
# Cursor Mobile Commander
# Author: CTO / Principal Architect
# Date: 2026-06-22

---

## Design Principles

1. **No backend** — all intelligence stays in Cursor Cloud; the app is a thin client
2. **Agent-first** — every module must be understandable and modifiable by a Cursor Agent reading only that module
3. **One concern per layer** — data, domain, and UI never mix
4. **Explicit over implicit** — no magic, no reflection, no code generation that Agents cannot read
5. **Fail gracefully** — every API call has a defined error path; the app never shows a raw exception

---

## 1. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                           │
│                  (Android first, iOS-ready)                     │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │  UI      │  │ Domain   │  │  Data    │  │  Platform     │  │
│  │  Layer   │  │  Layer   │  │  Layer   │  │  Layer        │  │
│  │          │  │          │  │          │  │               │  │
│  │ Screens  │  │ Notifiers│  │ Repos    │  │ Background    │  │
│  │ Widgets  │  │ UseCases │  │ Sources  │  │ Poll Service  │  │
│  │ Providers│  │ Models   │  │ Cache    │  │ Local Notif   │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬───────┘  │
│       └─────────────┴─────────────┴────────────────┘           │
│                          Riverpod                               │
└───────────────────────┬─────────────────────────────────────────┘
                        │ HTTPS / SSE
          ┌─────────────┴──────────────┐
          │                            │
   ┌──────▼──────┐            ┌────────▼────────┐
   │  Cursor     │            │   GitHub        │
   │  api.cursor.│            │   api.github.   │
   │  com/v1     │            │   com           │
   │             │            │                 │
   │  Agents     │            │  Repos / PRs    │
   │  Runs / SSE │            │  Files / CI     │
   │  Usage      │            │  OAuth          │
   └──────┬──────┘            └────────┬────────┘
          │                            │
   ┌──────▼──────────────────────────▼─┐
   │         Cursor Cloud VMs          │
   │  (clones repo, edits, pushes PR)  │
   └────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Rules |
|---|---|---|
| UI | Render state, handle gestures | Reads providers only. Zero business logic. |
| Domain | Business rules, error classification, use cases | No Flutter imports. Pure Dart. Testable in isolation. |
| Data | HTTP calls, SSE, SQLite read/write | Implements repository interfaces defined in Domain. |
| Platform | Background polling, local notifications, biometric | OS-specific. Abstracted behind interfaces. |

---

## 2. Data Architecture

### 2.1 Storage Strategy

| Data Type | Storage | TTL / Retention |
|---|---|---|
| API keys (Cursor + GitHub) | `flutter_secure_storage` (Keychain / Keystore) | Until user removes |
| App settings | `flutter_secure_storage` (non-sensitive fields: `SharedPreferences`) | Permanent |
| Agent sessions + run records | Drift SQLite | Keep all |
| Chat messages (SSE events) | Drift SQLite | 90 days or 10,000 per agent |
| Tool call logs | Drift SQLite | 30 days |
| Token usage | Drift SQLite | Keep all |
| GitHub repository list | Drift SQLite (`github_cache`) | 24h TTL |
| PR diffs (raw patch) | Drift SQLite (`diff_cache`) | 7 days or 100 PR max |
| PR file trees | In-memory (per session) | Session only |

### 2.2 Database Schema (Drift)

```dart
// ALL tables have explicit schemaVersion in migration log
// Never store secrets in SQLite

// --- Settings ---
class UserSettings: id, cursorKeyRef(String), githubTokenRef(String),
  biometricEnabled(bool), defaultModelId(String?), 
  pollIntervalSeconds(int=30), updatedAt(DateTime)

// --- Projects ---
class PinnedProject: id(String PK), repoUrl(String), owner(String),
  name(String), defaultBranch(String), sortOrder(int), 
  lastSyncedAt(DateTime?)

// --- Agents ---
class AgentSession: agentId(String PK), projectId(String FK),
  name(String), status(String), latestRunId(String?),
  createdAt(DateTime), updatedAt(DateTime),
  tags(String) // JSON array, local only

// --- Runs ---
class RunRecord: runId(String PK), agentId(String FK),
  status(String), resultText(String?), durationMs(int?),
  prUrl(String?), branch(String?), errorCode(String?),
  errorMessage(String?), createdAt(DateTime), completedAt(DateTime?)

// --- Messages ---
class ChatMessage: id(String PK), runId(String FK),
  role(String), content(String), eventType(String),
  sequenceIndex(int), timestamp(DateTime)

// --- Tool Calls ---
class ToolCallLog: callId(String PK), runId(String FK),
  toolName(String), status(String), argsJson(String),
  resultJson(String?), startedAt(DateTime), completedAt(DateTime?)

// --- Usage ---
class UsageRecord: runId(String PK), inputTokens(int),
  outputTokens(int), totalTokens(int), recordedAt(DateTime)

// --- GitHub Cache ---
class GithubCache: cacheKey(String PK), jsonPayload(String),
  createdAt(DateTime), expiresAt(DateTime)

// --- Diff Cache ---
class DiffCache: prKey(String PK), patchText(String),
  fileCount(int), createdAt(DateTime), expiresAt(DateTime)

// --- Prompt Queue (offline) ---
class QueuedPrompt: id(String PK), agentId(String?),
  repoUrl(String), promptText(String), options(String), // JSON
  createdAt(DateTime), status(String) // pending | sent | failed
```

### 2.3 Migration Strategy

- Drift schema migrations are numbered and committed in `db/migrations/`
- Each migration is a pure SQL file: `0001_initial.sql`, `0002_add_tags.sql`
- On app upgrade, Drift runs pending migrations in order
- **No destructive migrations** — add columns with defaults, never drop

---

## 3. Module Architecture

### 3.1 Package Structure

```
cursor_mobile_commander/
├── packages/
│   ├── cursor_api_core/        # Auth header, HTTP client, error types
│   ├── cursor_api_agents/      # Agent + Run CRUD (uses core)
│   ├── cursor_api_stream/      # SSE parser, reconnector, event types
│   └── github_api/             # GitHub REST, OAuth, rate limiter
├── apps/
│   └── mobile/
│       └── lib/
│           ├── core/           # App-level DI, errors, extensions
│           ├── features/       # One folder per vertical feature
│           └── shared/         # Shared widgets, theme, constants
```

### 3.2 Feature Module Structure

Every feature follows the same internal structure. **No exceptions.** This is the primary rule that allows Cursor Agents to navigate the codebase without reading the whole project.

```
features/{feature_name}/
├── data/
│   ├── {feature}_repository_impl.dart   # Implements domain interface
│   └── {feature}_remote_source.dart     # Raw API calls only
├── domain/
│   ├── {feature}_repository.dart        # Abstract interface
│   ├── {feature}_model.dart             # Immutable domain model
│   └── {feature}_failure.dart           # Typed error sealed class
├── presentation/
│   ├── {feature}_screen.dart            # Screen widget
│   ├── {feature}_provider.dart          # Riverpod providers
│   └── widgets/                         # Screen-local widgets
└── {feature}_module.dart                # Public exports (barrel file)
```

### 3.3 Feature Inventory

| Feature | Screens | Key Dependencies |
|---|---|---|
| `auth` | KeySetupScreen, BiometricScreen | `flutter_secure_storage`, `local_auth`, `cursor_api_core` |
| `onboarding` | WelcomeScreen, ConnectCursorScreen, ConnectGitHubScreen, PinRepoScreen, FirstAgentScreen | `auth`, `projects` |
| `projects` | DashboardScreen, ProjectDetailScreen, AddProjectScreen | `cursor_api_agents`, `github_api` |
| `agents` | AgentListScreen, AgentDetailScreen | `cursor_api_agents` |
| `chat` | ChatScreen, TemplatePickerSheet, ModelPickerSheet, OptionsSheet | `cursor_api_agents`, `cursor_api_stream` |
| `tasks` | TaskListScreen, TaskDetailScreen, RunLogsScreen | `cursor_api_agents` |
| `review` | PRListScreen, PRDetailScreen, DiffViewerScreen, MergeConfirmSheet | `github_api` |
| `github` | RepoBrowserScreen, FileViewerScreen, CommitListScreen | `github_api` |
| `templates` | TemplateListScreen, TemplateEditorScreen | local Drift |
| `settings` | SettingsScreen, KeyManageScreen, PollIntervalScreen | `auth`, `core` |
| `notifications` | (no screen — service only) | `flutter_local_notifications`, `workmanager` |

### 3.4 Riverpod Provider Architecture (Mandatory Rules)

| Use Case | Provider Type | Example |
|---|---|---|
| Async server data (one-time) | `AsyncNotifierProvider` | `agentListProvider` |
| Streaming server data | `StreamProvider` | `runStreamProvider(runId)` |
| UI-only state | `NotifierProvider` | `chatComposerProvider` |
| Simple derived state | `Provider` | `activeAgentsCountProvider` |
| Scoped per-instance state | `NotifierProvider.family` | `agentChatProvider(agentId)` |

**Rule:** Never use `StateProvider` for server state. Never use `FutureProvider` for data that needs `refresh()`. Never put HTTP calls in a `Provider` (not async-safe).

### 3.5 go_router Route Tree

```
/ (root)
├── /onboarding           → OnboardingScreen
│   ├── /connect-cursor   → ConnectCursorScreen
│   ├── /connect-github   → ConnectGitHubScreen
│   ├── /pin-repo         → PinRepoScreen
│   └── /first-agent      → FirstAgentScreen
├── /home                 → HomeScreen (shell with bottom nav)
│   ├── /projects         → DashboardScreen
│   │   └── /:projectId   → ProjectDetailScreen
│   ├── /agents           → AgentListScreen
│   │   ├── /new          → NewAgentSheet (modal)
│   │   └── /:agentId     → AgentDetailScreen
│   │       └── /chat     → ChatScreen
│   │           └── /run/:runId/logs → RunLogsScreen
│   └── /settings         → SettingsScreen
│       ├── /keys         → KeyManageScreen
│       └── /templates    → TemplateListScreen
│           └── /edit/:id → TemplateEditorScreen
├── /review/:owner/:repo/pulls/:prNumber → PRDetailScreen
└── /github/:owner/:repo  → RepoBrowserScreen
    └── /file/*path       → FileViewerScreen
```

---

## 4. Security Architecture

### 4.1 Key Storage

```
Cursor API Key:
  Storage: flutter_secure_storage → Android Keystore / iOS Keychain
  Key: "cursor_api_key"
  Access: Read once on session start; inject into HTTP client; do not cache in Dart String beyond injection point
  Rotation: User-initiated; old key deleted before new key written

GitHub Access Token:
  Storage: flutter_secure_storage
  Key: "github_access_token"
  Refresh Token Key: "github_refresh_token"
  Auto-refresh: 50 minutes after issue (GitHub tokens expire at 60min for Apps; PATs don't expire by default but we handle gracefully)
```

### 4.2 Transport Security

- **TLS 1.3 minimum** enforced via network security config (Android) and App Transport Security (iOS)
- **Certificate pinning**: Pin `api.cursor.com` and `api.github.com` public key hashes in `network_security_config.xml` and `Info.plist`
- **No HTTP allowed** — no `http://` URLs in any environment (including dev; use ngrok for local testing)

### 4.3 Authentication Flow

```
App Launch:
  1. Check flutter_secure_storage for cursor_api_key
  2. If absent → route to /onboarding
  3. If present + biometric enabled → local_auth challenge
  4. If biometric passes (or disabled) → load app
  5. Background: validate key with GET /v1/me on first foreground

QR Key Transfer:
  Desktop helper: generates UUID one-time token (e.g., using Python uuid4)
  Encodes: cursormc://auth?token={uuid}&key={api_key}  ← v1 (acceptable for single user)
  Future v2: token only in QR; mobile polls localhost:9999/claim/{token}

GitHub OAuth (PKCE):
  1. Generate code_verifier (random 64-char string)
  2. Compute code_challenge = base64url(sha256(code_verifier))
  3. Open: https://github.com/login/oauth/authorize?client_id=...&code_challenge=...&code_challenge_method=S256&redirect_uri=cursormc://oauth/callback&scope=repo+read:org
  4. Receive redirect: cursormc://oauth/callback?code={code}
  5. Exchange: POST https://github.com/login/oauth/access_token with code + code_verifier
  6. Store token in secure storage
```

### 4.4 Input Security

- All user-entered prompts are **stripped of null bytes** before transmission
- No client-side validation beyond length check (max 4096 chars per prompt)
- Prompt injection risk: documented accepted risk (user is the attacker's own agent)

### 4.5 Android Hardening

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
android:allowBackup="false"
android:fullBackupContent="false"

<!-- network_security_config.xml -->
<pin-set expiration="2027-01-01">
  <pin digest="SHA-256">...</pin>  <!-- api.cursor.com -->
  <pin digest="SHA-256">...</pin>  <!-- api.github.com -->
</pin-set>
```

### 4.6 Session Security

- Auto-lock after 5 minutes idle (configurable, minimum 1 minute)
- Screen content hidden when app goes to background (FLAG_SECURE on Android, blurring on iOS)
- Session does not persist across device restarts without biometric re-auth

---

## 5. GitHub Integration Strategy

### 5.1 Integration Model

**Choice: GitHub OAuth App with PKCE**

Rationale: No backend server available. GitHub App requires backend for installation token exchange. OAuth App with PKCE is secure, mobile-native, and sufficient for single-user access.

**Migration path to GitHub App:** When a backend (BFF) is added in a future phase, the `github_api` package's auth module is replaced without touching any feature code. The `GithubAuthRepository` interface remains unchanged.

### 5.2 Scopes

```
repo          → Read/write repos, branches, PRs, issues
read:org      → Read organization membership (for org repos)
```

**Removed from original design:** `workflow` — not needed for reading CI status (covered by `repo`).

### 5.3 Rate Limit Management

```dart
// github_api/src/rate_limiter.dart
class GithubRateLimiter {
  // Parse X-RateLimit-Remaining and X-RateLimit-Reset headers
  // Maintain per-resource counters
  // Throw RateLimitFailure with resetAt when remaining < 10
  // UI: show "GitHub API limit reached, resets at {time}"
}
```

Rate limit headers are parsed on every response. No secondary polling starts if remaining < 50.

### 5.4 GitHub API Operations by Feature

| Feature | Endpoint | Notes |
|---|---|---|
| Repo list | GET /user/repos | paginated, cache 24h |
| Branch list | GET /repos/{o}/{r}/branches | cache 5min |
| PR list | GET /repos/{o}/{r}/pulls?state=open | cache 60s |
| PR diff | GET /repos/{o}/{r}/pulls/{n}/files | cache 7d in DiffCache |
| PR review | POST /repos/{o}/{r}/pulls/{n}/reviews | no cache |
| Merge PR | PUT /repos/{o}/{r}/pulls/{n}/merge | no cache; confirm dialog |
| Delete branch | DELETE /repos/{o}/{r}/git/refs/heads/{branch} | after merge |
| CI status | GET /repos/{o}/{r}/commits/{sha}/check-runs | cache 60s |
| File tree | GET /repos/{o}/{r}/git/trees/{sha} | non-recursive; lazy load |
| File content | GET /repos/{o}/{r}/contents/{path} | cache 5min |
| Commit list | GET /repos/{o}/{r}/commits | paginated, cache 5min |

### 5.5 PR Merge Workflow

```
1. User opens PRDetailScreen
2. App fetches: PR metadata + status checks + branch protection rules
3. If checks failing → show warning, disable merge button
4. If branch protection requires reviews → show "X of Y reviews needed"
5. User taps Merge → MergeConfirmSheet (shows: title, SHA, merge method)
6. Confirm → PUT /pulls/{n}/merge
7. On success → DELETE /git/refs/heads/{branch} (if "delete branch after merge" enabled)
8. Navigate back to PR list; refresh with 3s delay (GitHub eventual consistency)
```

---

## 6. Cursor API Integration Strategy

### 6.1 Client Package Split

```
packages/cursor_api_core/
  - CursorHttpClient (dio-based, injects Bearer token)
  - CursorApiError sealed class (AuthError, RateLimitError, NotFoundError, AgentBusyError, StreamExpiredError, UnknownError)
  - CursorApiConfig (baseUrl, timeouts)

packages/cursor_api_agents/
  - AgentRepository (interface)
  - AgentRepositoryImpl
  - Operations: listAgents(), getAgent(), createAgent(), listRuns(), getRun(), createRun(), cancelRun(), getUsage(), getArtifacts(), listModels(), listRepositories()
  - Models: AgentModel, RunModel, UsageModel, ArtifactModel, ModelInfo

packages/cursor_api_stream/
  - RunStreamService
  - SseEvent sealed class (AssistantDelta, ThinkingDelta, ToolCallEvent, StatusEvent, ResultEvent, DoneEvent, ErrorEvent)
  - SseParser (pure Dart, fully unit-tested)
  - ReconnectionManager (Last-Event-ID, exponential backoff: 1s→2s→4s→8s→max30s)
```

### 6.2 Agent Lifecycle State Machine

```
         ┌─────────────────────────────────────┐
         │            IDLE                     │
         │   (agent exists, no active run)     │
         └──────────────┬──────────────────────┘
                        │ createRun()
                        ▼
         ┌─────────────────────────────────────┐
         │           CREATING                  │
         │   (POST /v1/agents or /runs)         │
         └──────────────┬──────────────────────┘
                        │ run.status = RUNNING
                        ▼
         ┌─────────────────────────────────────┐     cancelRun()
         │           STREAMING                 │─────────────────►┐
         │   (SSE active; events flowing)      │                  │
         └──────────────┬──────────────────────┘                  │
                        │ SSE disconnect                          │
                        ▼                                         │
         ┌─────────────────────────────────────┐                  │
         │           POLLING                   │                  │
         │   (GET /run every 10s; reconnect SSE│                  │
         │    with Last-Event-ID when possible) │                  │
         └──────────────┬──────────────────────┘                  │
                        │ status = FINISHED                       │
                        ▼                                         │
         ┌─────────────────────────────────────┐    ◄────────────┘
         │           COMPLETED                 │   status = CANCELLED
         │   (fetch /usage; show result)       │
         └─────────────────────────────────────┘
                        │ or
                        ▼
         ┌─────────────────────────────────────┐
         │           FAILED                    │
         │   (status = ERROR / EXPIRED)        │
         │   (classify error; show action)     │
         └─────────────────────────────────────┘
```

### 6.3 Error Classification

```dart
sealed class CursorRunFailure {
  // User-facing message + action
  case AgentBusy(retryAfterSeconds: int)         // 409: wait + retry
  case StreamExpired(lastEventId: String)         // 410: reconnect
  case RateLimited(resetAt: DateTime)            // 429: show reset time
  case AuthInvalid()                             // 401: go to key settings
  case AgentNotFound()                           // 404: agent deleted
  case ContextTooLarge()                         // 413: repo too big
  case UnknownError(statusCode: int, body: String)
}
```

### 6.4 Polling Policy

| App State | Screen | Polling Behavior |
|---|---|---|
| Foreground | ChatScreen (active run) | SSE primary; poll /run every 10s as fallback |
| Foreground | AgentListScreen | Poll /agents every 30s |
| Foreground | DashboardScreen | Poll /agents every 30s |
| Background | Any | WorkManager: poll active runs every 120s; local notification on completion |
| Background | Any | Poll /agents every 300s (5min) for dashboard badge count |
| Offline | Any | Show cached state; queue prompts; retry on connectivity restored |

---

## 7. Offline Strategy

### 7.1 Offline Detection

```dart
// core/network/connectivity_service.dart
// Uses connectivity_plus; provides Stream<bool> isOnline
// All providers watch isOnline; switch to cache mode when false
```

### 7.2 Offline Behaviors by Feature

| Feature | Offline Behavior |
|---|---|
| Project Dashboard | Show cached project cards, agent counts, last-known status |
| Agent List | Show cached agents with "last seen" timestamps |
| Chat (read) | Show full cached conversation (SSE events from SQLite) |
| Chat (send) | Queue prompt in QueuedPrompt table; show "Will send when online" banner |
| PR List | Show cached PR list; disable merge/review actions |
| File Browser | Show cached file tree if previously loaded; else "No cached data" |
| Settings | Fully available offline |

### 7.3 Prompt Queue Processing

```
ConnectivityService detects: offline → online
→ QueuedPromptService reads all status='pending' from QueuedPrompt table
→ For each queued prompt:
    → If agentId present: POST /v1/agents/{id}/runs
    → If no agentId: POST /v1/agents (create new)
    → On success: update status='sent', navigate to chat if foreground
    → On failure: status='failed', notify user
→ Process sequentially (avoid 409 agent_busy)
```

---

## 8. Agent Lifecycle Design

### 8.1 Agent Session Model

A **Cursor Agent Session** (`AgentSession`) maps 1:1 to a Cursor Cloud Agent (`agentId`). It persists across app sessions.

- One agent per GitHub repository per "task context" (user decides when to create new vs resume)
- Agent can have many `RunRecord` entries (each user prompt = one run)
- The agent's full "conversation" is the concatenation of all `ChatMessage` rows across all runs

### 8.2 Agent Creation Flow

```
User taps "New Agent" on ProjectDashboard:
1. Show NewAgentSheet: prompt input, template picker, model picker, mode toggle, options (autoCreatePR, branch)
2. User fills prompt; taps Send
3. POST /v1/agents { repos: [repoUrl], messages: [{ role: user, content: prompt }], model, mode, options }
4. Receive: { agentId, runId, status: CREATING }
5. Save AgentSession + RunRecord to SQLite
6. Navigate to ChatScreen(agentId: agentId)
7. Open SSE stream on runId
8. Render events as they arrive
```

### 8.3 Agent Resume Flow

```
User opens existing AgentSession from AgentList:
1. Load ChatScreen(agentId: agentId)
2. Read all ChatMessage rows from SQLite → render history immediately
3. GET /v1/agents/{id} → update AgentSession.status
4. If latestRunId.status ∈ {RUNNING, CREATING} → attempt SSE reconnect with Last-Event-ID
5. If all runs terminal → show "Continue" button in composer
6. User types follow-up; taps Send:
   POST /v1/agents/{id}/runs { messages: [{ role: user, content: prompt }] }
7. Receive new runId → open SSE stream → append to chat
```

### 8.4 Background Agent Monitoring

```
Platform: WorkManager (Android) / BGTaskScheduler (iOS)
Trigger: Every 120 seconds when app is backgrounded and there are active runs

Background task:
1. Read all RunRecords with status ∈ {CREATING, RUNNING} from SQLite
2. For each: GET /v1/agents/{id}/runs/{runId}
3. If status changed to FINISHED/ERROR/CANCELLED:
   a. Update RunRecord in SQLite
   b. Fetch usage if available
   c. Schedule local notification: "Agent '{name}' finished — tap to review"
4. If status unchanged: no action
5. Task completes (WorkManager reschedules)
```

### 8.5 Agent Naming Convention

Agents are named automatically on creation: `{repo-name}/{branch}/{date}` (e.g., `spanishtuinen/feat-seo/2026-06-22`). Users can rename locally (stored in `AgentSession.name`, not synced to Cursor API).

---

## Architecture Decision Records

### ADR-001: No Backend Server
**Decision:** Build as a pure mobile client with no backend proxy.
**Rationale:** Reduces operational complexity; no server cost; Cursor API supports direct client access; no backend = no backend security surface.
**Trade-off:** No push notifications (mitigated by background polling); GitHub OAuth App instead of GitHub App (mitigated by clear migration path).

### ADR-002: Riverpod over Bloc
**Decision:** Use Riverpod for all state management.
**Rationale:** Less boilerplate; compile-time safe; easier for Cursor Agents to generate correct provider code from patterns.
**Trade-off:** Less opinionated than Bloc; mitigated by mandatory provider type rules in AGENT_GUIDE.

### ADR-003: Split cursor_api Package
**Decision:** Split into `cursor_api_core`, `cursor_api_agents`, `cursor_api_stream`.
**Rationale:** SSE is the highest-risk component. Isolating it means a broken SSE reconnector doesn't cause rebuild of the entire API client.

### ADR-004: Drift over Hive / Isar
**Decision:** Use Drift (SQLite) for offline storage.
**Rationale:** Drift supports typed migrations, complex queries, and reactive streams. Agents can write SQL migrations without understanding Dart internals. Hive/Isar require Dart-specific mental model.

### ADR-005: melos Is Mandatory
**Decision:** melos.yaml is a required project file.
**Rationale:** Without melos, running tests across packages requires manual directory navigation. Agents will run commands in the wrong directories. melos `run test` runs all package tests from root.
