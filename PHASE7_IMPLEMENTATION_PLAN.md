# Phase 7 — Implementation Plan
# Cursor Mobile Commander
# Blueprint for Cursor Background Agents

---

## Instructions for Cursor Agents Reading This Document

You are about to implement Cursor Mobile Commander. This document is your implementation blueprint. Read it completely before writing any code.

**Priority reading order:**
1. PHASE7_IMPLEMENTATION_PLAN.md (this file)
2. docs/AGENT_GUIDE.md
3. docs/ARCHITECTURE.md
4. docs/FOLDER_STRUCTURE.md
5. docs/API_GUIDE.md

**Rules:**
- Implement one sprint at a time
- Do not start Sprint N+1 until Sprint N is merged
- Every sprint produces a PR to `develop`
- All PRs must pass: `melos run lint` + `melos run test`
- Do not generate production code beyond what the current sprint specifies

---

## Implementation Order

```
Sprint 1 → Sprint 2 → Sprint 3 → Sprint 4 → Sprint 5 → Sprint 6
   ↓           ↓           ↓           ↓           ↓           ↓
Foundation  Auth+DB    API Pkgs   Core Chat   GitHub     Polish
```

---

## Sprint 1: Foundation (Week 1, Days 1-3)
**Goal:** Runnable skeleton with navigation and theme. No business logic.

### S1.1 — Monorepo Initialization

Create the following files exactly:

**`melos.yaml`** — as specified in PHASE5_GITHUB_REPO_DESIGN.md

**`analysis_options.yaml`** — as specified in PHASE5_GITHUB_REPO_DESIGN.md

**`.gitignore`** — as specified in PHASE5_GITHUB_REPO_DESIGN.md

**`apps/mobile/pubspec.yaml`:**
```yaml
name: cursor_mobile_commander
description: Manage Cursor Background Agents from your phone
publish_to: none
version: 0.1.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter
  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  # Navigation
  go_router: ^14.2.0
  # Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  # Storage
  flutter_secure_storage: ^9.0.0
  # Biometric
  local_auth: ^2.3.0
  # HTTP
  dio: ^5.4.3
  # Connectivity
  connectivity_plus: ^6.0.3
  # Notifications
  flutter_local_notifications: ^17.2.2
  # Background tasks
  workmanager: ^0.5.2
  # QR
  mobile_scanner: ^5.1.1
  # Voice
  speech_to_text: ^6.6.2
  # Images
  image_picker: ^1.1.2
  # Markdown
  flutter_markdown: ^0.7.3
  # Syntax highlighting
  flutter_highlight: ^0.7.0
  # Sharing
  share_plus: ^9.0.0
  # Internal packages
  cursor_api_core:
    path: ../../packages/cursor_api_core
  cursor_api_agents:
    path: ../../packages/cursor_api_agents
  cursor_api_stream:
    path: ../../packages/cursor_api_stream
  github_api:
    path: ../../packages/github_api

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.10
  drift_dev: ^2.18.0
  riverpod_generator: ^2.4.2
  mocktail: ^1.0.3
  riverpod_lint: ^2.3.10
```

**Deliverable:** `flutter pub get` succeeds. `flutter run` shows empty MaterialApp.

### S1.2 — App Shell

Create in order:

1. `apps/mobile/lib/app/theme.dart` — dark theme only
   - Background: `Color(0xFF0D0D0D)`
   - Card: `Color(0xFF1A1A1A)`
   - Accent: `Color(0xFF00B4D8)`
   - Font: system default (no custom fonts in v1)
   - Text styles: titleLarge, bodyMedium, labelSmall defined

2. `apps/mobile/lib/app/routes.dart` — route path constants
   ```dart
   abstract class Routes {
     static const onboarding = '/onboarding';
     static const connectCursor = '/onboarding/connect-cursor';
     // ... all routes from PHASE2 route tree
   }
   ```

3. `apps/mobile/lib/app/router.dart` — GoRouter instance
   - Auth guard: redirect to `/onboarding` if no cursor key in secure storage
   - Full route tree per PHASE2

4. `apps/mobile/lib/app/app.dart` — MaterialApp.router

5. `apps/mobile/lib/main.dart` — ProviderScope + runApp

6. `apps/mobile/lib/shared/widgets/loading_spinner.dart`
7. `apps/mobile/lib/shared/widgets/error_view.dart`
8. `apps/mobile/lib/shared/widgets/offline_banner.dart`
9. `apps/mobile/lib/shared/constants/colors.dart`
10. `apps/mobile/lib/shared/constants/sizes.dart`

**Deliverable:** App launches. Bottom navigation shows 3 empty tabs. Auth guard redirects to onboarding screen.

### S1.3 — Package Scaffolds

Create minimal scaffolds for all 4 packages. Each package needs only:
- `pubspec.yaml`
- `lib/{package_name}.dart` (empty barrel file with TODO comment)
- `test/{package_name}_test.dart` (placeholder test: `void main() {}`)

This lets melos bootstrap succeed before package implementations are written.

**Packages to scaffold:**
- `packages/cursor_api_core`
- `packages/cursor_api_agents`
- `packages/cursor_api_stream`
- `packages/github_api`

**Deliverable:** `melos bootstrap` succeeds. `melos run lint` passes on all packages (no code yet).

---

## Sprint 2: Auth + Database (Week 1, Days 4-5)
**Goal:** Key setup, biometric lock, GitHub OAuth, Drift database running.

### S2.1 — Drift Database

Create in order:

1. `apps/mobile/lib/core/database/tables/` — one file per table:
   - `user_settings_table.dart`
   - `pinned_projects_table.dart`
   - `agent_sessions_table.dart`
   - `run_records_table.dart`
   - `chat_messages_table.dart`
   - `tool_call_logs_table.dart`
   - `usage_records_table.dart`
   - `github_cache_table.dart`
   - `diff_cache_table.dart`
   - `queued_prompts_table.dart`

   Each table: Drift `@DataClassName` annotation, all columns per PHASE2 schema.

2. `apps/mobile/lib/core/database/app_database.dart` — `@DriftDatabase(tables: [...])`

3. `apps/mobile/lib/core/database/migrations/0001_initial.dart` — migration from version 0 to 1

4. Run `melos run codegen` to generate `.g.dart` files

5. `apps/mobile/lib/core/database/database_provider.dart` — Riverpod `Provider<AppDatabase>`

**Test:** Write `test/core/database/app_database_test.dart` — opens in-memory DB, inserts + reads one record per table.

### S2.2 — Secure Storage + Auth Feature

1. `apps/mobile/lib/core/storage/secure_storage_service.dart`
   - Wraps `flutter_secure_storage`
   - Methods: `writeKey(String key, String value)`, `readKey(String key)`, `deleteKey(String key)`
   - Key constants: `cursorApiKey`, `githubAccessToken`, `githubRefreshToken`

2. `apps/mobile/lib/features/auth/` — full feature module per FOLDER_STRUCTURE.md
   - `auth_repository.dart` — interface: `Future<bool> validateCursorKey(String key)`, `Future<bool> hasCursorKey()`
   - `auth_failure.dart` — sealed: `InvalidKey`, `NetworkError`, `StorageError`
   - `auth_repository_impl.dart` — calls `GET /v1/me` to validate; reads/writes SecureStorageService
   - `auth_provider.dart` — `AsyncNotifierProvider` for auth state
   - `key_setup_screen.dart` — paste field + QR scan button + validate button + error display
   - `biometric_screen.dart` — `local_auth` challenge; error fallback text

3. `apps/mobile/lib/core/network/connectivity_service.dart`
   - Uses `connectivity_plus`
   - Exposes `Stream<bool> isOnline`
   - Riverpod `StreamProvider<bool>` in `core/`

**Test:**
- `test/features/auth/auth_repository_impl_test.dart` — mock HTTP; test valid key, invalid key, network error

### S2.3 — GitHub OAuth

1. `apps/mobile/lib/features/auth/github_auth_service.dart`
   - Generates PKCE verifier + challenge
   - Opens OAuth URL in external browser
   - Handles `cursormc://oauth/callback` deep link
   - Exchanges code for token (POST to github.com)
   - Stores token via SecureStorageService

2. `apps/mobile/lib/features/onboarding/presentation/connect_github_screen.dart`
   - "Connect GitHub" button
   - Auth state indicator (loading, success, error)

3. `apps/mobile/android/app/src/main/AndroidManifest.xml` — deep link intent filter for `cursormc://oauth/callback`

4. `apps/mobile/ios/Runner/Info.plist` — CFBundleURLTypes for `cursormc`

**Test:** Manual test only (OAuth requires browser). Write unit test for PKCE generation.

### S2.4 — Onboarding Flow

1. `apps/mobile/lib/features/onboarding/` — full feature module
   - `welcome_screen.dart` — app purpose explanation; "Get Started" button
   - `connect_cursor_screen.dart` — redirects to `key_setup_screen.dart`
   - `connect_github_screen.dart` — GitHub OAuth trigger
   - `pin_repo_screen.dart` — calls GitHub API to list repos (GitHub API package not ready yet; show placeholder with manual URL entry)
   - `first_agent_screen.dart` — placeholder "You're ready! Create your first agent →"
   - `onboarding_provider.dart` — tracks completed steps; redirects to home when all done

**Deliverable:** Full onboarding flow navigable from start to home.

---

## Sprint 3: API Packages (Week 2, Days 1-2)
**Goal:** All 4 packages implemented and unit-tested. App can call Cursor API.

### S3.1 — cursor_api_core

1. `packages/cursor_api_core/lib/src/errors/cursor_api_error.dart` — sealed class per API_GUIDE.md
2. `packages/cursor_api_core/lib/src/client/cursor_http_client.dart` — Dio wrapper; injects Bearer; handles errors
3. `packages/cursor_api_core/lib/src/config/cursor_api_config.dart` — baseUrl, timeouts
4. `packages/cursor_api_core/lib/cursor_api_core.dart` — exports

**Tests:** All error mappings, auth injection, timeout behavior.

### S3.2 — cursor_api_agents

1. Models: `AgentModel`, `RunModel`, `UsageModel`, `ArtifactModel`, `ModelInfoModel`
   - All fields nullable with defaults (beta API safety)
2. `AgentRepository` interface — all 10 methods per API_GUIDE.md
3. `AgentRepositoryImpl` — implements all methods; maps CursorApiError to AgentFailure
4. `AgentFailure` sealed class

**Tests:** All 10 methods with mocked HTTP responses. Test all error codes.

### S3.3 — cursor_api_stream

This is the highest-risk package. Implement with extra care.

1. `SseEvent` sealed class:
   ```dart
   sealed class SseEvent { const SseEvent(); }
   class AssistantDelta extends SseEvent { final String delta; ... }
   class ThinkingDelta extends SseEvent { final String delta; ... }
   class ToolCallEvent extends SseEvent { final String callId, name, status; ... }
   class StatusEvent extends SseEvent { final String status; ... }
   class ResultEvent extends SseEvent { final String text; ... }
   class DoneEvent extends SseEvent { const DoneEvent(); }
   class ErrorEvent extends SseEvent { final String code, message; ... }
   ```

2. `SseParser` — pure Dart class (no Flutter imports)
   - Input: `Stream<String>` of raw SSE text
   - Output: `Stream<SseEvent>`
   - Handle: multi-line data, empty keep-alive lines, UTF-8 chunks

3. `ReconnectionManager` — state machine: connected/disconnected/reconnecting
   - Exponential backoff: 1s → 2s → 4s → 8s → 16s → max 30s
   - Stop on 410 stream_expired

4. `RunStreamService` — dart:io HttpClient stream; sets Last-Event-ID header; uses SseParser + ReconnectionManager

**Tests (mandatory — this package must have ≥90% coverage):**
- `sse_parser_test.dart`:
  - Parse `assistant` event
  - Parse `tool_call` event with multi-line data
  - Handle empty keep-alive lines
  - Handle partial UTF-8 chunks
  - Parse `done` event
  - Parse `error` event
  - Handle unknown event types gracefully (skip, not crash)
- `reconnection_manager_test.dart`:
  - Verify backoff timing
  - Verify stop on 410

### S3.4 — github_api

1. `GithubApiError` sealed class: `Unauthorized`, `RateLimited(resetAt)`, `NotFound`, `ValidationFailed(message)`, `MergeConflict`, `NotMergeable`, `Unknown`
2. `GithubHttpClient` — Dio; Bearer auth; rate limit header parsing
3. `GithubRateLimiter` — parse X-RateLimit-* headers; throw RateLimited when remaining < 10
4. `GithubRepository` interface — all methods per API_GUIDE.md
5. `GithubRepositoryImpl` — implements all; maps errors

**Tests:** Rate limit handling, all error codes, PR merge error differentiation.

---

## Sprint 4: Core Chat (Week 2, Days 3-5 + Week 3, Days 1-2)
**Goal:** Create agent, stream chat, follow-up, cancel. Full chat UI.

### S4.1 — Agents Feature

1. `apps/mobile/lib/features/agents/` — full feature module
   - Domain: `AgentModel`, `RunModel`, `AgentFailure`, `AgentRepository` (wraps cursor_api_agents)
   - Data: `AgentRepositoryImpl` + local SQLite persistence of AgentSession + RunRecord
   - Providers:
     - `agentListProvider` — `AsyncNotifierProvider`; polls every 30s when screen visible
     - `agentProvider(agentId)` — `AsyncNotifierProvider.family`
     - `activeAgentsCountProvider` — `Provider` derived from agentListProvider
   - Screens: `agent_list_screen.dart`, `agent_detail_screen.dart`
   - Widgets: `agent_status_chip.dart` (maps run status to color + label)

2. `apps/mobile/lib/features/agents/data/agent_local_source.dart`
   - Reads/writes AgentSession + RunRecord to Drift

### S4.2 — Chat Feature

1. `apps/mobile/lib/features/chat/` — full feature module

   **Providers (implement in this order):**
   - `chatMessagesProvider(agentId)` — StreamProvider; reads ChatMessage rows from Drift for agentId; ordered by sequenceIndex
   - `runStreamProvider(runId)` — StreamProvider; wraps RunStreamService; persists each SseEvent to Drift
   - `chatStateProvider(agentId)` — NotifierProvider; tracks: composerText, isSending, currentRunId
   - `agentChatProvider(agentId)` — AsyncNotifierProvider.family; orchestrates create/resume/follow-up/cancel

   **Widgets (implement in this order):**
   - `chat_composer.dart` — TextFormField; send button; mic; attach; disabled when isSending
   - `user_message_bubble.dart` — right-aligned; text content
   - `assistant_message_bubble.dart` — left-aligned; avatar; text with flutter_markdown
   - `tool_call_chip.dart` — expandable; tool name; status dot; args (monospace, collapsed by default); result (collapsed)
   - `milestone_marker.dart` — centered chip: "Branch pushed: fix/auth-bug" / "PR #42 opened" / "Build passed"
   
   **Screens:**
   - `chat_screen.dart` — ListView.builder + composer; loads history from SQLite on open; attaches to stream
   - `new_agent_sheet.dart` — bottom sheet: prompt, template picker, model picker, mode toggle, options
   - `template_picker_sheet.dart` — list of templates; tap to pre-fill composer
   - `model_picker_sheet.dart` — GET /v1/models; dropdown; default from settings
   - `options_sheet.dart` — autoCreatePR toggle, branch selector

2. **SQLite persistence layer for chat:**
   - On each SseEvent from RunStreamService:
     - `AssistantDelta` → upsert ChatMessage (role=assistant, append delta to content)
     - `ThinkingDelta` → upsert ChatMessage (role=thinking, append delta)
     - `ToolCallEvent` → upsert ToolCallLog
     - `ResultEvent` → upsert ChatMessage (role=result, replace content)
     - `DoneEvent` → update RunRecord.status = FINISHED; fetch usage
     - `ErrorEvent` → update RunRecord.status = ERROR; set errorCode + errorMessage

**Tests:**
- `chat_provider_test.dart` — test create agent, stream events, follow-up flow (mock cursor_api_stream)
- `tool_call_chip_test.dart` — widget test: expand/collapse

### S4.3 — Tasks Feature

1. `apps/mobile/lib/features/tasks/` — full feature module
   - `task_list_screen.dart` — runs grouped by status (Running / Completed / Failed)
   - `run_logs_screen.dart` — all ChatMessages + ToolCallLogs for a runId; token usage at bottom
   - `tasks_provider.dart` — reads RunRecord from Drift; maps status to UI bucket

---

## Sprint 5: GitHub Integration (Week 3, Days 3-5 + Week 4)
**Goal:** Full PR review, merge, repo browser.

### S5.1 — Projects Feature

1. `apps/mobile/lib/features/projects/` — full feature module
   - `dashboard_screen.dart` — grid of ProjectCards; pull-to-refresh
   - `project_detail_screen.dart` — agent list + PR list + CI badge + file browser entry
   - `add_project_screen.dart` — search repos (via github_api) + manual URL entry + pin
   - `project_card.dart` — repo name; active agent count; open PRs; last activity

2. `projects_provider.dart`:
   - `pinnedProjectsProvider` — reads PinnedProject from Drift; sorted by sortOrder
   - `projectAgentsProvider(projectId)` — filters agentListProvider by projectId
   - `projectPRsProvider(projectId)` — calls GithubRepository.listPRs; cache 60s

### S5.2 — Review Feature

1. `apps/mobile/lib/features/review/` — full feature module

   **Domain:** `PullRequestModel`, `DiffFileModel`, `ReviewFailure`, `ReviewRepository`
   **Data:** `ReviewRepositoryImpl` — calls github_api; caches diffs in DiffCache table

   **Screens:**
   - `pr_list_screen.dart` — open PRs; agent-created badge (detect from PR title prefix "feat:" / "fix:" + agent-created label)
   - `pr_detail_screen.dart` — title; description; status checks; branch info; approve/merge buttons
   - `diff_viewer_screen.dart` — paginated file list (max 100); per-file unified diff with flutter_highlight; swipe between files
   - `merge_confirm_sheet.dart` — merge method picker; title confirmation; warning if checks failing

   **Widgets:**
   - `pr_card.dart` — title, number, branch, status badge, age
   - `check_status_badge.dart` — green/red/yellow dot + label
   - `diff_file_tile.dart` — filename, +/- counts; tap to expand diff

2. **Merge flow implementation:**
   ```dart
   // In ReviewRepositoryImpl
   Future<Either<ReviewFailure, void>> mergePR({
     required String owner, required String repo,
     required int prNumber, required String mergeMethod,
     required String? commitTitle,
   }) async {
     // 1. PUT /pulls/{n}/merge
     // 2. On 200: DELETE /git/refs/heads/{branch} if deleteBranch setting enabled
     // 3. On 405: return NotMergeableFailure
     // 4. On 409: return MergeConflictFailure
     // 5. On 422: return ValidationFailure(message)
   }
   ```

### S5.3 — GitHub Browser Feature

1. `apps/mobile/lib/features/github/` — full feature module
   - `repo_browser_screen.dart` — non-recursive tree; expand folder on tap; breadcrumb nav
   - `file_viewer_screen.dart` — syntax-highlighted; read-only; copy button; share button
   - `commit_list_screen.dart` — paginated; SHA chip; message; author; date

---

## Sprint 6: Templates, Offline, Security, Polish (Week 5-6)

### S6.1 — Templates Feature

1. `apps/mobile/lib/features/templates/` — full feature module
2. `apps/mobile/lib/features/templates/data/builtin_templates.dart` — 8 templates per PHASE6
3. `template_list_screen.dart` — builtin + custom; search field
4. `template_editor_screen.dart` — name, description, prompt with {variable} highlighting; preview
5. Variable substitution in `TemplatePickerSheet`:
   - Parse `{variable}` tokens from template
   - Show input fields for each variable
   - Populate composer on confirm

### S6.2 — Offline + Background

1. `apps/mobile/lib/core/network/connectivity_service.dart` — already in Sprint 2; expand with provider
2. `apps/mobile/lib/features/notifications/background_poll_service.dart`
   - WorkManager task: `cursormc_poll_agents`
   - Reads active RunRecords from Drift
   - Calls `GET /v1/agents/{id}/runs/{runId}` for each
   - On status change: updates Drift + fires local notification
3. `apps/mobile/lib/features/notifications/local_notification_service.dart`
   - flutter_local_notifications setup
   - Channel: "Agent Updates" (Android)
   - Permission request on first notification
4. `apps/mobile/lib/features/chat/data/queued_prompt_service.dart`
   - Writes to QueuedPrompt table when offline
   - ConnectivityService listener → process queue on reconnect
5. `apps/mobile/lib/shared/widgets/offline_banner.dart` — already created in Sprint 1; wire to ConnectivityService

### S6.3 — Security Hardening

1. `apps/mobile/android/app/src/main/res/xml/network_security_config.xml` — TLS config + cert pins
2. `apps/mobile/android/app/src/main/AndroidManifest.xml` — allowBackup=false, FLAG_SECURE
3. `apps/mobile/ios/Runner/Info.plist` — ATS config
4. Certificate pin hash population — document process for rotating pins
5. `flutter_jailbreak_detection` — add to pubspec; show warning dialog on jailbroken devices

### S6.4 — Settings Feature

1. `apps/mobile/lib/features/settings/` — full feature module
   - `settings_screen.dart` — sections: Account, GitHub, App, Security
   - `key_manage_screen.dart` — show masked key; rotate key button; disconnect button
   - Settings options: poll interval (30s / 60s / 120s / manual), auto-lock timeout, "delete branch after merge" toggle

### S6.5 — CI/CD Setup

1. `.github/workflows/lint.yml` — per PHASE5
2. `.github/workflows/test.yml` — per PHASE5
3. `.github/workflows/build-android.yml` — per PHASE5
4. `.github/workflows/build-ios.yml` — per PHASE5

### S6.6 — Final Documentation Pass

1. Verify all docs in `docs/` are accurate to implemented code
2. Update `docs/FOLDER_STRUCTURE.md` if any paths changed during implementation
3. Write `tools/generate_key_qr.dart` — QR code generator script
4. Update `docs/README.md` with real screenshots (placeholder descriptions)

---

## Critical Implementation Notes

### SSE Implementation Warning
The `cursor_api_stream` package is the highest-risk component. If the SSE event schema in the live Cursor v1 API differs from what is documented in API_GUIDE.md, the entire chat feature breaks. Before implementing `SseParser`, make ONE real API call with a simple agent and log the raw SSE response. Adjust event type names accordingly. Document any differences in a comment at the top of `sse_event.dart`.

### Drift Codegen Warning
After any change to a Drift table definition, you MUST run `melos run codegen`. Never commit table changes without regenerated `.g.dart` files. The CI build will fail.

### Race Condition in Chat
When a user sends a follow-up and the previous run just became terminal at the same moment, a 409 can arrive before the UI has updated. The `agentChatProvider` must handle 409 by refreshing the agent state once before showing an error to the user.

### GitHub Rate Limit on Startup
`GET /v1/repositories` has a 1 req/min limit. On PinRepoScreen, always check `GithubCache` first. Only call the API if cache is expired AND the user explicitly requested a refresh. Show the cached list immediately.

---

## Definition of Done (Per Sprint)

A sprint is done when:
- [ ] All specified files exist at specified paths
- [ ] `melos run lint` passes with 0 warnings
- [ ] `melos run test` passes (all tests green)
- [ ] `melos run build-check` succeeds (Android debug build)
- [ ] PR opened to `develop` with filled PR template
- [ ] Human reviewer has approved

---

## Not In Scope for v1.0

The following will NOT be implemented by the agents building v1.0:

- Push notifications via FCM (no backend)
- Multi-account support
- Tablet layout
- Image attach to prompts (defer to v1.2)
- Voice input (defer to v1.2)
- Full-text search (defer to v1.2)
- iOS App Store submission (TestFlight only in v1.0)
- Any custom AI inference layer

---

## Final Deliverable

After Sprint 6 is merged and approved:

**v1.0.0-alpha** — A working Flutter app that:
1. ✅ Authenticates with Cursor API via API key
2. ✅ Connects GitHub via OAuth PKCE
3. ✅ Lists and pins repositories
4. ✅ Creates Cursor Background Agents
5. ✅ Streams agent output in real time
6. ✅ Sends follow-up prompts
7. ✅ Cancels running agents
8. ✅ Shows token usage
9. ✅ Lists and reviews PRs with diff viewer
10. ✅ Approves and merges PRs
11. ✅ Uses 8 built-in command templates
12. ✅ Reads past conversations offline
13. ✅ Queues prompts when offline
14. ✅ Sends local notifications when agents complete
15. ✅ Protects API keys with biometric auth

This is the complete blueprint. Begin with Sprint 1.
