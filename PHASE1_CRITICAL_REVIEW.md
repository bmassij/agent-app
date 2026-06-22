# Phase 1 — Critical Architecture Review
# Cursor Mobile Commander
# Reviewed by: CTO / Principal Architect
# Date: 2026-06-22
# Source: Architecture document provided by Bart Massij

---

## Executive Summary

The provided architecture document is **significantly better than average** for a v1 design. The author has done real API research (verified against official Cursor v1 docs), chosen a clean Flutter stack, and correctly identified the key constraints (no webhook in v1, no PC required, no custom AI layer). The risk table at the end shows mature awareness.

However, several **critical gaps, false assumptions, and maintainability risks** remain. This review identifies every issue that must be resolved before a Cursor Background Agent team can safely build and maintain this product.

**Overall Assessment: 7/10 — strong foundation, fixable flaws, proceed to Phase 2 with corrections.**

---

## 1. Missing Features

### 1.1 Push Notification Strategy
The document explicitly accepts "no push notifications" as a design choice. This is **a UX showstopper for the core use case.** If the user closes the app while an agent runs for 8 minutes, they have no way to know it finished. The document offers no fallback. 

**Required addition:** A background polling service (WorkManager on Android, BGTaskScheduler on iOS) that polls run status every 60–120 seconds when the app is backgrounded and triggers a local notification on terminal status. This is native mobile, requires no server, and solves the problem without webhooks.

### 1.2 Agent Error Classification
The risks table mentions "SSE disconnect / 410 stream_expired" but there is no defined error classification system. The app must distinguish between:
- API key invalid
- Agent busy (409)
- Agent not found (404)
- Rate limit (429)
- Stream expired (410)
- GitHub merge conflict
- Branch protection block
- Network offline

Each error class needs a different UX response (retry, user action, silent fallback). This is not designed.

### 1.3 Prompt Queue (Offline Send)
The document mentions "disable send" when offline. This is the wrong UX. Prompts entered offline should be **queued** and automatically sent when connectivity returns. The offline cache (Drift SQLite) is already present — this is a small addition with large UX impact.

### 1.4 Token Budget Warning
Token usage is tracked via `/v1/agents/{id}/usage` but there is no defined threshold or warning. A user burning through their Cursor quota silently is a real risk. A configurable soft-limit warning (e.g., "this agent has used 80% of your estimated monthly budget") is missing.

### 1.5 Agent Naming / Tagging
Agents are identified by `agentId` and `name`. When a user has 20+ agents across 5 repos, the list becomes unmanageable. A tagging/labeling system (local, stored in Drift) for grouping agents is missing.

### 1.6 Share / Export Conversation
Users will want to share agent output (copy to clipboard, export as Markdown, share to Slack/email). This is absent.

### 1.7 Cursor Agent URL Deep Link Verification
The document mentions `agent.url` (cursor.com/agents/...) as a fallback. It is not specified how this URL is opened (in-app browser vs external browser) and whether the user is automatically authenticated. This needs to be explicit.

### 1.8 Multi-Account Support
The document assumes a single Cursor API key and single GitHub account. Users may need to switch between a personal account and a work account. The settings architecture does not support this.

---

## 2. Architectural Flaws

### 2.1 SSE Client — Custom Implementation Risk
The document specifies "Custom SSE client (dart:io HttpClient stream)" for Cursor streaming. This is **the highest implementation risk in the entire project.** SSE reconnection logic, Last-Event-ID handling, UTF-8 chunked streaming, and keepalive parsing are notoriously tricky in Dart.

**Recommendation:** Use the `dart_eventsource` or `layrz_eventsource` package as a base, or write the custom client as a fully isolated `packages/cursor_sse` package with 100% unit test coverage before any feature work touches it. A broken SSE client breaks the entire chat feature.

### 2.2 GitHub API Client Has No Retry / Rate Limit Layer
The `github_api` package is described as a "thin GitHub REST wrapper." This is insufficient. GitHub returns 403 (secondary rate limit) and 422 (validation) alongside the standard 429. A retry layer with exponential backoff + jitter, and a rate limit header parser, must be built into the package — not scattered across features.

### 2.3 Drift Schema Versioning Not Defined
The `GitHubCache` table stores `jsonPayload` as a string blob. When the GitHub API response shape changes (and it will), there is no migration path. **All cache tables must have a `schemaVersion` column and the cache must be invalidated on app update.**

### 2.4 `cursor_api` Package Is a God Package
The cursor_api package is responsible for auth, models, CRUD, SSE, usage, artifacts, and repository listing. As the API evolves, this package will accumulate breaking changes that affect every feature. 

**Recommendation:** Split into:
- `cursor_api_core` — HTTP client, auth header injection, error handling
- `cursor_api_agents` — agent + run CRUD
- `cursor_api_stream` — SSE parser and reconnector
- `cursor_api_github` — /v1/repositories bridge

### 2.5 Riverpod State — No Provider Architecture Specified
The document selects Riverpod but does not specify the provider architecture. Without this, Cursor Agents writing new features will use a mix of `StateProvider`, `FutureProvider`, `AsyncNotifierProvider`, and `StreamProvider` inconsistently. 

**Required decision:** All async server state uses `AsyncNotifierProvider`. All UI state uses `NotifierProvider`. All stream state uses `StreamProvider`. This must be documented in AGENT_GUIDE.

### 2.6 `go_router` Route Definition Missing
No routing tree is specified. Without a centralized route definition, agents will add routes in random locations and create navigation bugs. The full route tree must be defined in Phase 2.

### 2.7 No Dependency Injection Strategy Beyond Riverpod
Riverpod handles UI state DI well but does not replace application-level service location (HTTP clients, DB instances, secure storage). These need singleton providers with clear initialization order at `main.dart`. Not specified.

### 2.8 Background Polling Has No Lifecycle Management
The document says "poll agent list every 30s when screen visible; stop when backgrounded." There is no architecture for this lifecycle. Using `AppLifecycleListener` or `WidgetsBindingObserver` for polling management must be defined in the module architecture, not left to individual features.

---

## 3. Security Risks

### 3.1 QR Code API Key Transfer — Not Cryptographically Safe
The document describes a QR code scheme: `cursormc://auth?key=...`. This transfers the raw Cursor API key via QR. If someone photographs the screen or the QR is displayed in a video call, the key is compromised.

**Mitigation:** The QR payload should be a **one-time token** (e.g., a TOTP or UUID that the desktop helper script burns after one scan). This requires a tiny local HTTP server on desktop (`localhost:9999/claim?token=...`) that the mobile app calls to retrieve the actual key. More secure, only marginally more complex.

### 3.2 `flutter_secure_storage` — Android Backup Risk
By default, Android's Auto Backup (via Google Drive) does NOT back up `flutter_secure_storage` keystore entries. However, certain OEM implementations and older devices may expose this. The security architecture must explicitly disable `android:allowBackup="true"` for the keychain namespace.

### 3.3 API Key in Memory During Session
Between secure storage read and API call, the API key lives in a Dart `String`. In Dart, strings are immutable and GC-managed — you cannot zero out the memory. This is a limitation of the platform but must be documented as an accepted risk.

### 3.4 No Certificate Pinning
The app communicates with `api.cursor.com` and `api.github.com`. Without certificate pinning, a MITM attack (on corporate proxies, hotel WiFi, etc.) can intercept API keys transmitted in the `Authorization` header. Certificate pinning should be implemented for production builds.

### 3.5 GitHub OAuth Scope: `workflow` Is Overpowered
The document requests `repo, read:org, workflow` scopes. The `workflow` scope allows modifying GitHub Actions workflow files. This is broader than needed. Restrict to `workflow:read` if only reading CI status, or remove it entirely and use the Actions read endpoint which is accessible with `repo` scope.

### 3.6 No Jailbreak / Root Detection
The app stores API keys for both Cursor and GitHub in secure storage. On a jailbroken/rooted device, `flutter_secure_storage` provides weaker guarantees. Jailbreak detection (via `safe_device` or `flutter_jailbreak_detection` packages) should be implemented with a user warning (not a hard block, to avoid false positives).

### 3.7 Biometric Auth Bypass via App Reinstall
If the user reinstalls the app, biometric protection resets. On Android, the keystore-backed keys may or may not survive reinstall depending on the device. The expected behavior must be documented and tested.

---

## 4. Scalability Issues

### 4.1 SQLite Is Fine for Single User — Not for Export
SQLite (Drift) is the right choice for a single-user mobile app. However, the `GitHubCache` and `ChatMessage` tables will grow unbounded. There is no TTL eviction strategy defined.

**Required:** Define retention policies:
- `GitHubCache`: 24h TTL, evict on app launch
- `ChatMessage`: keep last 90 days or 10,000 messages per agent; archive older rows
- `ToolCallLog`: keep last 30 days

### 4.2 PR Diff Rendering — No Size Cap
The document uses `diff_match_patch` or `git_diff` for PR diff display. Large PRs (1000+ file changes) will freeze the Flutter UI thread. Diff rendering must be chunked or paginated, with a "showing first 100 files" cap and a link to GitHub for the rest.

### 4.3 Agent List Pagination Not Specified
`GET /v1/agents` will return a growing list. Pagination (cursor-based) must be implemented in the `cursor_api_agents` package from day one. A naive "load all agents" call will degrade as the user accumulates sessions.

### 4.4 `/v1/repositories` Rate Limit (1 req/min)
The document correctly identifies this limit but the mitigation ("cache aggressively") is underspecified.

**Required:** The `GitHubCache` table caches the repository list with a 24h TTL. The refresh button has a 60-second client-side cooldown. On first launch, the user can skip the sync and manually enter a repo URL. All of this must be in the module spec.

---

## 5. UX Issues

### 5.1 ChatGPT Pattern Is Correct — But Agent Lifecycle Is Not a Chat
The ChatGPT-like pattern is excellent for conversation. However, Cursor Agents can run for 10–20 minutes and produce commits, branch pushes, and PRs — not just text. The chat UI needs **milestone markers**: "Agent pushed branch `fix/auth-bug`", "PR #42 opened", "Build passed" — interleaved with chat bubbles. This is not described.

### 5.2 Tool Call Rendering Underspecified
The document mentions "tool calls as monospace expandable chips." Tool calls in Cursor agents include file reads, searches, shell commands, and web fetches. The chip must show: tool name, status (running/done/failed), key args (file path, query), and collapsible output. The visual design of this is critical UX and is underspecified.

### 5.3 Agent Mode vs Plan Mode — User Education Missing
The mode toggle (`agent` vs `plan`) is mentioned but not explained in the UX. Users unfamiliar with the distinction will misuse it. A tooltip or first-use explanation is required.

### 5.4 Onboarding Flow Not Wireframed
The screen map shows `Splash → Onboarding → AuthSetup → Home` but the onboarding steps are not defined. For a developer tool, onboarding is complex:
1. Explain what Cursor Background Agents are
2. Set up Cursor API key
3. Connect GitHub
4. Pin first repository
5. Run first agent (guided)

Each step must be designed or the app will have a terrible first-run experience.

### 5.5 Voice Input Accessibility
`speech_to_text` is listed as a dependency. Voice input for code prompts is valuable but requires careful UX: start/stop button, live transcript, correction flow. This is mentioned but not designed.

### 5.6 No Tablet / Landscape Layout
The document is phone-centric. A tablet with a split-pane layout (projects left, chat right) would dramatically improve usability on iPad / Android tablet. Not mentioned as a future phase.

---

## 6. Future Maintenance Risks (Cursor Agent Maintainability)

### 6.1 AGENT_GUIDE Is Listed But Not Scoped
The document lists `docs/ARCHITECTURE.md` and `docs/SETUP.md` but doesn't define an `AGENT_GUIDE.md`. This is the most important document for autonomous maintenance. It must describe:
- How to add a new feature (which layers to touch, in which order)
- How to add a new API endpoint
- How to add a new Drift table
- How to add a new screen
- Naming conventions (with examples)
- What NOT to do (anti-patterns)

### 6.2 Template System Is Local JSON — Not Extensible
The command templates are stored as local JSON in the app. Cursor Agents cannot add new templates by editing the app — they'd need to submit a PR. Consider whether templates should live in a config file in the GitHub repository (e.g., `.cursor/templates.json`) that the app fetches.

### 6.3 `melos.yaml` Is "Optional"
The document marks melos (monorepo tooling) as "optional." For a monorepo with `apps/mobile`, `packages/cursor_api`, and `packages/github_api`, melos is **mandatory** to coordinate builds, tests, and pub operations. Making it optional will cause agents to run commands in wrong directories.

### 6.4 No Linting / Formatting Config Specified
Without `analysis_options.yaml` with strict lint rules and a `dart format` pre-commit hook, agents will submit code with inconsistent style. This accumulates into unreadable codebases.

### 6.5 Test Strategy Absent
The document has a `test/` folder but no test strategy. Cursor Agents writing features without tests is the primary cause of regressions. Required:
- Unit tests for all package-level logic (≥80% coverage)
- Widget tests for all complex UI components
- Integration tests for auth + onboarding flows
- Golden tests for key screens

### 6.6 CI/CD Not Specified
The development roadmap does not include CI/CD setup. Cursor Agents need a CI pipeline to validate their own PRs. GitHub Actions workflows for lint, test, and build must be defined in Phase 5.

---

## 7. Cursor API Assumptions

### 7.1 v1 API Is Beta — Breaking Changes Are Likely ✅ (Correctly Identified)
The document correctly identifies this risk and recommends versioning the client interface. **Additional required mitigation:** All API response models must use `fromJson` constructors with null-safe defaults on all fields (not `required`), so that new fields added by Cursor don't break parsing.

### 7.2 Assumption: `/v1/agents/{id}/usage` Is Available Per Run
The document says "fetch /usage when run completes." The official docs say "Available per run when recorded" — implying it may not always be present. The UI must handle missing usage data gracefully (show "—" not crash).

### 7.3 Assumption: `run.result` Contains Full Text
For long agent runs, the result may be truncated or split across SSE events. The local persistence strategy (storing every SSE event) is correct — but the display logic must reconstruct the full result from persisted events, not from `run.result` alone.

### 7.4 Assumption: `/v1/models` Returns Model IDs Usable in Agent Creation
The `mode` field in agent creation is documented as `agent | plan`. The model field may have different valid values than what `/v1/models` returns. This must be tested against the live API before the model picker is built.

### 7.5 No Cursor Streaming Events Schema Documented
The SSE event types (`assistant`, `thinking`, `tool_call`, `status`, `result`, `done`) are listed but not sourced from official docs. These event types must be verified against the live API. If the schema differs, the entire chat rendering layer breaks.

---

## 8. GitHub Integration Risks

### 8.1 GitHub OAuth App vs GitHub App — Wrong Choice Made
The document selects **GitHub OAuth App** with PKCE. For a developer tool managing repository PRs and merges, a **GitHub App** is strongly preferred because:
- Higher API rate limits (5,000/hr per installation vs shared OAuth limits)
- Fine-grained repository permissions (can restrict to specific repos)
- Installation-level access (better for team use)

However: GitHub Apps require a backend to store installation tokens — which this architecture avoids. **For the current no-backend constraint, GitHub OAuth App with PKCE is the correct tradeoff**, but this decision must be explicitly documented with a migration path to GitHub App when a backend is added.

### 8.2 PR Merge Without Branch Deletion
The merge workflow (`PUT pulls/{n}/merge`) does not include post-merge branch deletion. This is standard practice and its absence will leave orphaned branches accumulating in repositories.

### 8.3 GitHub Actions Status — Polling Not Defined
The dashboard shows CI status via `GET repos/{o}/{r}/actions/runs`. The polling interval for this is not specified. CI runs can take 30 minutes — polling every 30 seconds is wasteful. **Define: poll CI status every 60s while the PR review screen is open; don't poll on dashboard unless the user explicitly requests.**

### 8.4 File Browser — Large Repositories
`GET /repos/{o}/{r}/git/trees/{sha}?recursive=1` returns the full tree. For large repositories (thousands of files), this response is several MB and can time out. The file browser must use non-recursive tree fetching (depth-first, expand on tap).

### 8.5 GitHub Merge Conflict Detection
The document mentions "Surface GitHub error; link to PR on GitHub" for merge conflicts. This is acceptable for v1 but the error handling must parse the GitHub 405/409 response body to distinguish "merge conflict" from "branch protection failed" from "checks failed."

---

## Summary Scorecard

| Category | Score | Notes |
|---|---|---|
| Missing Features | 6/10 | Background notifications, offline queue, error classification missing |
| Architectural Flaws | 6/10 | God package, no provider architecture, SSE risk |
| Security | 7/10 | QR plaintext key, no cert pinning, scope too broad |
| Scalability | 7/10 | No TTL policy, no pagination spec, diff size cap missing |
| UX | 7/10 | Milestone markers missing, tool call UI underspecified |
| Maintenance | 5/10 | No AGENT_GUIDE scope, no CI/CD, no test strategy, melos optional |
| Cursor API | 7/10 | Good awareness but SSE schema unverified, usage field may be absent |
| GitHub Integration | 7/10 | OAuth App justified, branch cleanup missing, tree fetch risk |

**Composite: 6.5/10**

---

## Critical Blockers Before Phase 2

1. **Verify SSE event schema** against live Cursor v1 API before designing chat renderer
2. **Define Riverpod provider architecture** (naming rules, which provider type for which use case)
3. **Design background polling service** for agent completion notifications
4. **Specify Drift schema migrations and TTL eviction policies**
5. **Make melos mandatory**, not optional
6. **Define AGENT_GUIDE scope** as a first-class deliverable
7. **Specify full route tree** in go_router

---

**→ Proceed to Phase 2: Improved Architecture Design.**
