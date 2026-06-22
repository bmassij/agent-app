# MASTER BUILD PLAN
# Cursor Mobile Commander
# Version: 1.0
# Last updated: 2026-06-22

---

## ⚠️ MANDATORY READING FOR ALL CURSOR AGENTS

You are a Cursor Background Agent. This file is your **single source of truth**.

**Before writing a single line of code:**
1. Read this entire document
2. Read `docs/AGENT_GUIDE.md`
3. Read `docs/ARCHITECTURE.md`
4. Read `docs/FOLDER_STRUCTURE.md`
5. Read `docs/API_GUIDE.md`

**If anything in your task conflicts with this document: this document wins.**

---

## 1. Project Vision

**What we are building:**
A native Flutter mobile application that allows a user to create, monitor, and communicate with Cursor Background Cloud Agents — entirely from their phone, without a PC running.

**Core user flow:**
```
Phone → Cursor API v1 → Cursor Cloud VM → GitHub Repository
```

**What this app is NOT:**
- Not a local IDE
- Not a custom AI model
- Not a backend server
- Not a replacement for cursor.com/agents

**The app is a thin, secure, offline-capable management client.** All intelligence stays in Cursor Cloud.

---

## 2. Architecture Summary

### Layer Model (strict — no exceptions)

```
UI Layer         → Screens, Widgets, Riverpod Providers
                   Rule: ZERO business logic. Only reads providers.

Domain Layer     → Repository interfaces, Models, Failure types
                   Rule: Pure Dart only. No Flutter imports. No HTTP.

Data Layer       → Repository implementations, Remote sources, Local sources
                   Rule: Implements Domain interfaces. Calls HTTP + SQLite.

Platform Layer   → Background polling, Local notifications, Biometric, Storage
                   Rule: OS-specific. Always abstracted behind interfaces.
```

### Package Model

```
apps/mobile/                  ← Flutter app
packages/cursor_api_core/     ← HTTP client + error types
packages/cursor_api_agents/   ← Agent + Run CRUD
packages/cursor_api_stream/   ← SSE parser + reconnector
packages/github_api/          ← GitHub REST + OAuth
```

### State Management: Riverpod (mandatory rules)

| Data type | Provider type | Example |
|---|---|---|
| Async server data | `AsyncNotifierProvider` | `agentListProvider` |
| Streaming data | `StreamProvider` | `runStreamProvider(runId)` |
| UI state | `NotifierProvider` | `chatComposerProvider` |
| Derived state | `Provider` | `activeAgentsCountProvider` |
| Per-instance | `*.family` | `agentChatProvider(agentId)` |

**Never use `StateProvider` for server data. Never use `FutureProvider` for data that needs `refresh()`.**

### Navigation: go_router

All routes are defined in `apps/mobile/lib/app/router.dart`.
All route path strings are constants in `apps/mobile/lib/app/routes.dart`.
Never hardcode route strings. Always use `Routes.{name}`.

### Database: Drift (SQLite)

All persistent data lives in Drift tables defined in `apps/mobile/lib/core/database/`.
Never use `SharedPreferences` for anything except non-sensitive UI preferences.
Never store secrets in SQLite — use `flutter_secure_storage` only.

---

## 3. Repository Structure

```
cursor-mobile-commander/
│
├── MASTER_BUILD_PLAN.md        ← YOU ARE HERE — read first
├── melos.yaml                  ← monorepo coordinator (mandatory)
├── analysis_options.yaml       ← lint rules (mandatory)
│
├── apps/
│   └── mobile/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app/            ← theme, router, routes
│       │   ├── core/           ← database, network, storage, logging
│       │   ├── features/       ← one folder per vertical feature
│       │   └── shared/         ← shared widgets, constants
│       ├── android/
│       ├── ios/
│       └── test/
│
├── packages/
│   ├── cursor_api_core/
│   ├── cursor_api_agents/
│   ├── cursor_api_stream/
│   └── github_api/
│
├── docs/
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── AGENT_GUIDE.md          ← step-by-step rules for agents
│   ├── DEVELOPMENT_GUIDE.md
│   ├── API_GUIDE.md            ← all API endpoints + error codes
│   ├── FOLDER_STRUCTURE.md     ← exact file locations
│   ├── CONTRIBUTING.md
│   ├── SECURITY.md
│   └── ROADMAP.md
│
├── tools/
│   └── generate_key_qr.dart
│
└── .github/
    └── workflows/
        ├── lint.yml
        ├── test.yml
        ├── build-android.yml
        └── build-ios.yml
```

**Feature module structure (every feature, no exceptions):**

```
features/{name}/
├── data/
│   ├── {name}_repository_impl.dart
│   └── {name}_remote_source.dart
├── domain/
│   ├── {name}_repository.dart    ← abstract interface
│   ├── {name}_model.dart         ← immutable data class
│   └── {name}_failure.dart       ← sealed error class
├── presentation/
│   ├── {name}_screen.dart
│   ├── {name}_provider.dart
│   └── widgets/
└── {name}_module.dart             ← barrel export
```

---

## 4. Coding Standards

### File naming
- Always `snake_case`: `agent_chat_screen.dart` ✅ / `AgentChatScreen.dart` ❌
- Suffix rules: `*Screen`, `*Repository`, `*RepositoryImpl`, `*Model`, `*Failure`, `*Provider`, `*Service`

### Import order (enforce strictly)
```dart
// 1. Dart SDK
import 'dart:async';
// 2. Flutter
import 'package:flutter/material.dart';
// 3. Third-party packages
import 'package:riverpod/riverpod.dart';
// 4. Internal packages
import 'package:cursor_api_agents/cursor_api_agents.dart';
// 5. App-local
import '../../../core/database/app_database.dart';
```

### Widget rules
- Use `ConsumerWidget` for widgets that read providers
- Use `StatelessWidget` for pure presentational widgets
- **Never use `StatefulWidget`** unless managing an `AnimationController` or `FocusNode`
- **Never call `ref.read` inside `build`** — always `ref.watch`
- **Never put business logic in a widget** — move it to a provider

### Error handling
- All repository methods return `Either<Failure, Success>`
- Never throw exceptions from the repository layer
- The UI always handles both `Left` (failure) and `Right` (success)

### Null safety
- All API response models have null-safe defaults on every field (the Cursor v1 API is beta — new fields appear without notice)
- Use `??` defaults, never `!` force-unwrap on API data

### Logging
- Use `AppLogger` from `core/logging/app_logger.dart`
- **Never use `print()`**
- **Never log API keys, tokens, or user prompt content**

### Code generation
- After changing any Drift table: run `melos run codegen`
- After changing any Riverpod `@riverpod` annotation: run `melos run codegen`
- Always commit generated `.g.dart` files alongside the source change

---

## 5. Agent Development Rules

These rules exist so agents can work safely without breaking the codebase.

**Rule A — Read before writing**
Read the existing file before editing it. Read the module's `_module.dart` barrel file to understand what is already exported. Read the router to understand existing navigation.

**Rule B — One feature per PR**
Never combine two features in one PR. If a bug fix requires touching a second feature, open a separate PR.

**Rule C — Smallest possible change**
If a task says "fix bug X", fix only bug X. Do not refactor surrounding code. Do not rename unrelated variables. Do not add features not in scope.

**Rule D — Follow the feature module structure**
When adding a new screen, repository, or model, it goes in the correct feature folder per the structure in Section 3. If you are unsure which feature it belongs to, stop and add `// AGENT_QUESTION: which feature does this belong to?` in the PR description.

**Rule E — Run checks before opening PR**
```bash
melos run lint    # must pass with 0 warnings
melos run test    # must pass with all tests green
```
Never open a PR that fails either check.

**Rule F — Use the correct Riverpod provider type**
See Section 2. Wrong provider types cause subtle bugs that are hard to detect in review.

**Rule G — No new packages without justification**
Every new `pubspec.yaml` dependency requires a comment in the PR description: package name, why it was chosen, what alternatives were considered. Adding packages with network access requires `// AGENT_ESCALATE` (see Section 10).

**Rule H — Never modify migration files**
Drift migration files in `core/database/migrations/` are immutable once merged. If the schema must change, add a NEW migration file. Never edit an existing one.

**Rule I — Escalate security changes**
See Section 10 for the list of forbidden changes that require human review.

**Rule J — Tag your PR**
Every agent-created PR must have labels: `agent-created` + `needs-human-review` + `size: small/medium/large`.

---

## 6. Security Rules

### What you MUST do
- Store all secrets (API keys, tokens) in `flutter_secure_storage` via `SecureStorageService`
- Use `AppLogger` for all logging — it automatically redacts known secret key names
- Use HTTPS for every external URL — never `http://`
- Validate all Cursor API responses before trusting field values

### What you MUST NOT do
- **Never** store an API key in a `String` constant, `.env` file, or any committed file
- **Never** log an API key, GitHub token, or user prompt content
- **Never** store secrets in Drift/SQLite
- **Never** add `android:allowBackup="true"` to AndroidManifest.xml
- **Never** disable TLS verification for any reason, including development
- **Never** commit `*.keystore`, `key.properties`, or any signing credentials
- **Never** open a URL using `http://` — all external calls are HTTPS

### Certificate pinning
Certificate pin hashes are in `android/app/src/main/res/xml/network_security_config.xml` and `ios/Runner/Info.plist`. **Never modify these files** without an `// AGENT_ESCALATE` comment. A wrong pin hash breaks the app for all users.

### Secret detection
Before opening a PR, scan your diff for these patterns:
- `cursor_` followed by a long string
- `ghp_` or `github_pat_`
- Any string longer than 32 chars in a string literal that is not a UI label

If found: **do not open the PR**. Remove the secret and add `// AGENT_ESCALATE: accidental secret exposure` to the PR description.

---

## 7. Git Workflow

### Branch naming
```
feat/{ticket-id}-{kebab-description}     # new feature
fix/{ticket-id}-{kebab-description}      # bug fix
chore/{kebab-description}                # maintenance, deps, docs
release/{semver}                         # release prep
hotfix/{semver}                          # critical production fix
```

### Commit message format
```
{type}({scope}): {imperative description}

Types: feat | fix | chore | docs | test | refactor
Scope: the feature or package name

Examples:
  feat(chat): add milestone markers for PR events
  fix(sse): resume stream with Last-Event-ID on disconnect
  chore(deps): upgrade riverpod to 2.5.1
  test(cursor-api): add coverage for 429 rate limit error
```

### PR target branch
- **Always PR to `develop`** — never directly to `main`
- Exception: hotfix branches PR to both `main` and `develop`

### Merge method
- Squash merge only (configured in GitHub repo settings)
- PR title becomes the squash commit message — write it in the same format as a commit message

### After your PR is merged
- Your feature branch is automatically deleted (configured in GitHub)
- Do not reuse the same branch name for a new task

---

## 8. Sprint Order

Sprints must be completed in order. **Do not start Sprint N+1 until Sprint N is merged to `develop`.**

### Sprint 1 — Foundation
**Goal:** Runnable skeleton with navigation and theme.
**Delivers:** Monorepo, app shell, bottom nav, empty screens, package scaffolds.
**Done when:** `flutter run` shows the app. Auth guard redirects to onboarding.

Key files to create:
- `melos.yaml`, `analysis_options.yaml`, `.gitignore`
- `apps/mobile/pubspec.yaml` (full dependency list per PHASE7)
- `apps/mobile/lib/app/theme.dart`, `router.dart`, `routes.dart`, `app.dart`, `main.dart`
- `apps/mobile/lib/shared/widgets/` — 3 shared widgets
- All 4 package scaffolds (empty, compilable)

### Sprint 2 — Auth + Database
**Goal:** Key setup, biometric lock, GitHub OAuth, Drift database.
**Delivers:** User can enter API key, connect GitHub, app is locked behind biometrics.
**Done when:** Onboarding flow navigable end-to-end.

Key files to create:
- `core/database/` — all 10 tables + migration 0001 + AppDatabase
- `core/storage/secure_storage_service.dart`
- `features/auth/` — full module
- `features/onboarding/` — full module
- GitHub PKCE OAuth flow
- Deep link handlers (Android + iOS)

### Sprint 3 — API Packages
**Goal:** All 4 packages implemented with full unit test coverage.
**Delivers:** App can call Cursor API and GitHub API.
**Done when:** `melos run test` passes with ≥80% coverage on all packages.

Key files to create:
- `packages/cursor_api_core/` — HTTP client, error types
- `packages/cursor_api_agents/` — all 10 operations, all models
- `packages/cursor_api_stream/` — SseParser (≥90% coverage), RunStreamService, ReconnectionManager
- `packages/github_api/` — all operations, rate limiter

⚠️ Before implementing `SseParser`: make one real Cursor API call and log the raw SSE output. Verify event type names match. Document any differences.

### Sprint 4 — Core Chat
**Goal:** Create agent, stream, follow-up, cancel, see history.
**Delivers:** The core value of the app — functional chat with a Cursor agent.
**Done when:** User can create an agent, see streaming output, send follow-up, cancel run.

Key files to create:
- `features/agents/` — full module
- `features/chat/` — full module (chat_screen, composer, all bubble widgets, tool_call_chip, milestone_marker)
- `features/tasks/` — full module
- SQLite persistence of all SSE events
- Background reconnection on SSE disconnect

### Sprint 5 — GitHub Integration
**Goal:** PR review, merge, repo browser, dashboard.
**Delivers:** User can see and merge PRs created by agents.
**Done when:** User can pin a project, see agent-created PRs, view diff, and merge.

Key files to create:
- `features/projects/` — full module
- `features/review/` — full module (pr_list, pr_detail, diff_viewer, merge_confirm)
- `features/github/` — full module (repo_browser, file_viewer, commit_list)

### Sprint 6 — Templates, Offline, Security, Polish
**Goal:** Production-ready app with all remaining features.
**Delivers:** Background notifications, offline queue, templates, settings, CI/CD.
**Done when:** All CI checks pass. Android release build succeeds. TestFlight submitted.

Key files to create:
- `features/templates/` — full module with 8 built-in templates
- `features/notifications/` — WorkManager + local notifications
- `features/settings/` — full module
- `core/network/connectivity_service.dart` + offline queue
- `android/app/src/main/res/xml/network_security_config.xml` — cert pinning
- `.github/workflows/` — all 4 CI workflows

---

## 9. Definition of Done

A task is done when **all** of the following are true:

- [ ] All specified files exist at the correct paths per `docs/FOLDER_STRUCTURE.md`
- [ ] `melos run lint` passes with **zero warnings**
- [ ] `melos run test` passes — **all tests green**
- [ ] `melos run build-check` succeeds (Android debug build compiles)
- [ ] New feature code has unit tests in `test/` mirroring the feature structure
- [ ] New screens have at least one widget test
- [ ] PR is open to `develop` with the PR template filled
- [ ] PR labels: `agent-created` + `needs-human-review` + size label
- [ ] No secrets in any file in the diff
- [ ] Commit messages follow the format in Section 7
- [ ] If Drift tables were changed: codegen was run and `.g.dart` files are committed

---

## 10. Forbidden Changes

The following changes require a human decision. If your task requires any of these, **stop, do not implement**, and add `// AGENT_ESCALATE: {reason}` to your PR description. Wait for human instruction.

| Forbidden Action | Reason |
|---|---|
| Editing an existing Drift migration file | Breaks database for existing users |
| Changing `SecureStorageService` key names | Logs out all users |
| Modifying certificate pinning config | Can break HTTPS for all users |
| Changing OAuth callback URI | Breaks GitHub auth flow |
| Adding a package with network access | Security surface increase |
| Modifying GitHub Actions workflow YAML | CI/CD pipeline change |
| Changing `android:allowBackup` | Security regression |
| Modifying ProGuard / obfuscation rules | May break release build |
| Deleting any `docs/` file | Removes agent guidance |
| Changing the merge workflow in `GithubRepository` | Financial risk (merges production code) |

---

## 11. Testing Requirements

### Coverage targets
| Layer | Minimum coverage |
|---|---|
| `packages/cursor_api_stream` | 90% |
| All other packages | 80% |
| `features/*/domain/` | 80% |
| `features/*/data/` | 80% |
| `features/*/presentation/` | one widget test per screen |

### What to test in each layer

**Domain models:** Test `fromJson` / `toJson` round-trips. Test null-safe defaults (pass JSON with fields missing — model must not crash).

**Repository implementations:** Mock the HTTP client. Test: happy path, 401, 404, 409, 429, 5xx, network timeout. Never let a status code go unhandled.

**Riverpod providers:** Use `ProviderContainer` in tests. Test state transitions (loading → data, loading → error, refresh).

**Widget tests:** Test key interaction: tap button → provider called. Test loading state renders spinner. Test error state renders `ErrorView`. Test offline state renders `OfflineBanner`.

**SSE Parser (special):** Must test: partial chunks arriving in multiple events, keep-alive empty lines, unknown event types (must be skipped not crashed), UTF-8 multi-byte characters split across chunks.

### Test file location
```
test/features/{feature}/
├── domain/{model}_test.dart
├── data/{repository_impl}_test.dart
└── presentation/{provider}_test.dart
```

### Mocking policy
- Use `mocktail` (not `mockito`)
- Mock `cursor_api_agents` package with `MockAgentRepository`
- Mock `github_api` package with `MockGithubRepository`
- Use in-memory Drift database (never mock the database itself)
- Never mock `flutter_secure_storage` — use the in-memory implementation it provides

---

## 12. Merge Requirements

Before a PR can be merged to `develop`:

**Automated (CI must pass):**
- `lint` workflow: `dart analyze` + `dart format --check`
- `test` workflow: all tests pass
- `build-android` workflow: debug APK builds

**Human review (mandatory):**
- One human approval required
- Reviewer checks: folder structure, provider types, no business logic in widgets, no secrets, meaningful tests, no scope creep

**PR must NOT be merged if:**
- Any CI check is red
- Contains `// AGENT_QUESTION:` that has not been answered
- Contains `// AGENT_ESCALATE:` that has not been resolved
- Diff touches any file in Section 10 (Forbidden Changes) without explicit human instruction

---

## 13. Release Requirements

### Version format
`MAJOR.MINOR.PATCH+BUILD` in `apps/mobile/pubspec.yaml`
Example: `1.0.0+1`, `1.0.1+2`, `1.1.0+10`

### Release flow (agents may NOT perform this — human only)
```
1. Human creates: git checkout -b release/1.0.0 develop
2. Human bumps version in pubspec.yaml
3. Human updates docs/ROADMAP.md with release notes
4. Human opens PR: release/1.0.0 → main
5. All CI checks must pass
6. Human merges (Merge Commit — NOT squash for release PRs)
7. Human tags: git tag v1.0.0
8. Human merges main → develop (to sync version bump)
9. CI triggers Play Store / TestFlight upload
```

Agents must **never** merge to `main` or create release tags. These actions are reserved for humans.

---

## 14. Agent Handoff Protocol

When you finish your sprint and your PR is merged, you are done. The next agent will pick up from the next sprint.

**Before completing your work, do the following:**

1. Verify `MASTER_BUILD_PLAN.md` is still accurate. If your sprint changed the folder structure, file names, or API assumptions: open a separate PR that updates this file.

2. If you encountered an important discovery (e.g., the Cursor SSE event schema is different from API_GUIDE.md), update `docs/API_GUIDE.md` and note the change in your PR description.

3. If you added a new package, add it to the dependency table in `docs/DEVELOPMENT_GUIDE.md`.

4. If you found a security issue you could not fix: open a GitHub issue titled `[SECURITY] {description}` and link it from your PR description.

5. Write a one-paragraph summary in your PR description under the heading `## Handoff Notes` describing: what you built, what works, what is known to be incomplete, what the next agent should check first.

**The next agent's first action after reading MASTER_BUILD_PLAN.md:**
- Run `melos bootstrap`
- Run `melos run lint`
- Run `melos run test`
- Read the most recently merged PR's `## Handoff Notes` section

---

## 15. Future Roadmap

The following is planned but **not in scope for the current build sprint**. Agents must not implement these unless explicitly instructed.

### v1.1 — iOS Production
- iOS App Store submission
- iOS-specific biometric (Face ID fine-tuning)
- iOS BGTaskScheduler background fetch

### v1.2 — Productivity
- Full-text search across conversation history (SQLite FTS5)
- Export conversation as Markdown
- Agent tagging / labeling
- Tablet layout (split-pane)
- Voice input (speech_to_text)
- Image attach to prompts
- Artifacts viewer

### v1.3 — GitHub Power Features
- CI/CD log viewer (step-by-step)
- Branch comparison view
- Inline PR diff comments
- GitHub Issues list + create
- Draft PR support

### v2.0 — Team Mode (requires backend)
- GitHub App (replaces OAuth App)
- FCM push notifications (replaces background polling)
- Multi-user workspace
- Webhook-driven real-time updates
- Token usage dashboard
- Agent audit log

### Migration path for future agents
When the backend (BFF) is added in v2.0:
- `github_api/` auth module: swap `GithubOAuthService` for `GithubAppInstallationService` — interface unchanged
- `cursor_api_core/` stays unchanged — BFF proxies the same Cursor API
- Riverpod providers: add `webhookProvider` alongside existing polling providers — don't remove polling (fallback)
- Notifications: add FCM alongside `local_notification_service.dart` — don't remove local (offline fallback)

---

## Quick Reference Card

```
START EVERY SESSION:
  1. Read MASTER_BUILD_PLAN.md (this file)
  2. Read docs/AGENT_GUIDE.md
  3. Run: melos bootstrap && melos run lint && melos run test
  4. Read last merged PR's Handoff Notes
  5. Identify your sprint from Section 8
  6. Branch: git checkout -b feat/{ticket}-{description} develop

BEFORE EVERY PR:
  melos run lint    ← zero warnings
  melos run test    ← all green
  Check diff for secrets
  Check Section 10 for forbidden changes
  Fill PR template
  Add labels: agent-created + needs-human-review + size

IF IN DOUBT:
  Add // AGENT_QUESTION: {question} to PR description
  Do less, not more
  A smaller correct PR beats a larger broken PR

NEVER:
  Push to main
  Skip tests
  Use print()
  Store secrets in SQLite
  Modify migration files
  Force-push a branch with an open PR
```

---

*This document is version-controlled. If you update it, increment the version number at the top and add a change log entry below.*

## Change Log

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-06-22 | Initial version created from Phase 1-7 design |
