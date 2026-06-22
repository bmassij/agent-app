# Sprint 2 Quality Audit Report
# Cursor Mobile Commander

**Date:** 2026-06-22  
**Auditor role:** Independent quality review (read-only)  
**Scope:** Sprint 2 — Auth + Database  
**References reviewed:** `MASTER_BUILD_PLAN.md`, `docs/AGENT_GUIDE.md`, `SPRINT1_COMPLETION_REPORT.md`, `SPRINT2_COMPLETION_REPORT.md`, `docs/SECURITY.md`, `docs/ARCHITECTURE.md`, `docs/FOLDER_STRUCTURE.md`  
**Codebase revision audited:** `master` @ `573eca8` (Sprint 2 commits)

---

## Executive Summary

Sprint 2 delivers the intended functional scope: Drift persistence, secure storage for secrets, Cursor API key onboarding with `/v1/me` validation, GitHub OAuth PKCE, biometric gating, and a navigable onboarding flow. Architecture boundaries are **mostly** respected in the auth feature module, and forbidden changes (OAuth callback URI, migration immutability, `allowBackup`, cert pinning) were not violated.

The sprint is **acceptable to proceed to Sprint 3 planning**, but **not production-ready on iOS** and **below project test-coverage standards** for new screens and providers. Several security and layering gaps should be addressed in Sprint 3's first work items before shipping auth-related builds to physical devices or TestFlight.

| Area | Rating | Summary |
|---|---|---|
| Architecture compliance | **Good with gaps** | Auth module structure is sound; onboarding bypasses repositories |
| Security compliance | **Partial** | Secrets handling is correct; OAuth hardening and platform privacy strings missing |
| OAuth implementation | **Functional, incomplete** | PKCE is correct; `state` and error paths are weak |
| Secure storage | **Good** | Correct abstraction; tests deviate from mocking policy |
| Drift schema | **Good foundation** | 10 tables present; no FKs, limited migration tests |
| Test coverage | **Below target** | 34 tests pass; missing widget/provider tests for most new UI |
| Technical debt | **Moderate** | HTTP/OAuth in app layer; duplicate future package work |
| Sprint 3 risks | **Elevated** | Package extraction, session validation, iOS permissions |

---

## Audit Methodology

1. Cross-checked Sprint 2 deliverables against `MASTER_BUILD_PLAN.md` Sprint 2 definition and Section 9 Definition of Done.
2. Reviewed auth, onboarding, database, storage, and platform integration source files.
3. Mapped findings to `docs/AGENT_GUIDE.md`, `docs/SECURITY.md`, and layer-model rules.
4. Inventoried `apps/mobile/test/` against MASTER_BUILD_PLAN Section 11 coverage requirements.
5. **Did not** re-run `melos run test`, `melos run lint`, or `melos run build-check` in this audit environment; findings note where verification is outstanding.

---

## 1. Architecture Compliance

### Strengths

- **Auth feature module** follows the prescribed `data/` / `domain/` / `presentation/` layout with `auth_module.dart` barrel export.
- **Domain layer** (`auth_model.dart`, `auth_failure.dart`, `auth_repository.dart`) is pure Dart — no Flutter imports.
- **Repository pattern** for Cursor key validation uses `Either<AuthFailure, T>` as required.
- **Secrets not in SQLite** — `UserSettings` stores opaque `cursorKeyRef` / `githubTokenRef` defaults (`'secure'`), not key material.
- **Routes** use `Routes.*` constants; `authRedirect()` is extracted and unit-tested.
- **No backend server** introduced; direct HTTPS to Cursor and GitHub APIs preserved.
- **Package scaffolds** remain untouched (correct for Sprint 2 scope).

### Findings

#### HIGH — Onboarding screens bypass the repository layer

`pin_repo_screen.dart` writes directly to `AppDatabase` via `appDatabaseFutureProvider`. `connect_github_screen.dart` and `first_agent_screen.dart` call `GithubAuthService` and `AuthRepository` from widgets with local `setState` business logic.

**Rule violated:** MASTER_BUILD_PLAN Section 2 — UI layer should have zero business logic; AGENT_GUIDE — never call HTTP/DB from widgets.

**Impact:** Sprint 5 `projects` feature will duplicate pin logic; harder to test onboarding flows in isolation.

---

#### MEDIUM — `GithubAuthService` lives in the app, not `github_api` package

OAuth and token exchange are implemented in `features/auth/data/github_auth_service.dart`. `FOLDER_STRUCTURE.md` and package model assign GitHub REST/OAuth to `packages/github_api/`.

**Impact:** Sprint 3 must migrate carefully to avoid dual implementations and broken deep-link wiring.

---

#### MEDIUM — `AuthRemoteSource` duplicates future `cursor_api_core` HTTP client

Inline Dio setup in the app violates the long-term package boundary. Acknowledged in Sprint 2 handoff notes; still architectural debt.

---

#### MEDIUM — Multiple `FutureProvider`s for refreshable state

`authRepositoryProvider`, `githubConnectedProvider`, `pinnedProjectCountProvider`, and `biometricEnabledProvider` use `FutureProvider`.

**Rule violated:** MASTER_BUILD_PLAN — *"Never use `FutureProvider` for data that needs `refresh()`."*

`ref.invalidate()` is used as a workaround (`githubConnectedProvider`, `pinnedProjectCountProvider`). Functional but inconsistent with `AsyncNotifierProvider` guidance.

---

#### MEDIUM — Dual `MaterialApp` roots in `CommanderApp`

Loading, biometric gate, and router each mount a separate `MaterialApp`. Works for Sprint 2 but complicates deep navigation, theme extensions, and overlay consistency.

---

#### LOW — `onboarding_module.dart` and onboarding `data/` / `domain/` layers missing

`docs/FOLDER_STRUCTURE.md` expects `onboarding_module.dart` and empty `data/` / `domain/` folders. Only `presentation/` exists.

---

#### LOW — `StatefulWidget` usage beyond animation controllers

`KeySetupScreen`, `BiometricScreen`, and `ConnectGithubScreen` use `ConsumerStatefulWidget` for controllers and local loading state. Acceptable for `TextEditingController`, but `BiometricScreen` / `ConnectGithubScreen` loading/error state belongs in providers per AGENT_GUIDE.

---

## 2. Security Compliance

### Strengths

- **API keys and GitHub tokens** stored only via `SecureStorageService` / `flutter_secure_storage` with `encryptedSharedPreferences` on Android.
- **Android `allowBackup="false"`** and `fullBackupContent="false"` — compliant with `docs/SECURITY.md`.
- **HTTPS-only API base URL** (`https://api.cursor.com/v1`) and GitHub token exchange over HTTPS.
- **OAuth callback URI** unchanged at `cursormc://oauth/callback` (forbidden-change rule respected).
- **Key validation before persist** — `saveAndValidateCursorKey` calls `validateCursorKey` before `writeKey` (implementation is *stricter* than the ordering described in `docs/SECURITY.md`).
- **No secrets in logs** from intentional logging paths (only generic debug messages in OAuth flow).
- **Certificate pinning** not modified (Sprint 6 scope; correctly untouched).

### Findings

#### CRITICAL — Missing iOS privacy usage descriptions

`ios/Runner/Info.plist` has `CFBundleURLTypes` for `cursormc` but **no**:

- `NSFaceIDUsageDescription` (required for `local_auth` / Face ID)
- `NSCameraUsageDescription` (required for `mobile_scanner` QR flow)

**Impact:** Biometric and QR features will fail or cause App Store rejection on iOS. Must be fixed before any iOS device testing or TestFlight.

---

#### HIGH — Session authentication is presence-only, not validity

`authSessionProvider` / `AuthSessionNotifier` calls `hasCursorKey()` only. Revoked, expired, or mistyped keys that remain in secure storage grant full app access until the user manually re-enters settings (not yet implemented).

**Impact:** Violates the spirit of Sprint 2's `/v1/me` validation goal for *ongoing* sessions. Sprint 1 risk ("auth guard checks storage only") is only partially resolved.

---

#### HIGH — GitHub OAuth missing `state` parameter

`GithubAuthService.buildAuthorizeUrl` sends PKCE `code_challenge` but no OAuth `state` value.

**Impact:** CSRF / authorization injection risk on custom URL scheme callbacks. Industry best practice for mobile OAuth; should be added before treating GitHub connection as production-grade.

---

#### MEDIUM — OAuth callback errors silently discarded

`CommanderApp._handleDeepLink` catches all exceptions from `handleOAuthCallback` with an empty catch block. GitHub `?error=` query responses are not explicitly handled.

**Impact:** User may complete browser auth but return to an app that shows no token and no actionable error.

---

#### MEDIUM — Security documentation ahead of implementation

`docs/SECURITY.md` specifies:

- Biometrics enabled **by default** on first launch — implementation defaults to **opt-in** (`biometricEnabled` false).
- **5-minute idle re-lock** — not implemented; unlock state is session-only in `biometricUnlockedProvider`.
- **FLAG_SECURE** / app-switcher blur — not implemented.
- **Certificate pinning** — not present (Sprint 6).

**Impact:** Doc/code drift may mislead auditors and Sprint 6 agents.

---

#### MEDIUM — `AppLogger` claims redaction but does not redact

Comment says *"Redacts known secret key names"* but `error()` prints raw `error` objects (e.g. full `DioException` text). Debug-only via `assert`, but violates MASTER_BUILD_PLAN *"Never log API keys, tokens"* intent if exceptions ever contain response bodies.

---

#### LOW — QR key transfer exposes raw key in URL

`tools/generate_key_qr.dart` and `cursormc://auth?key=...` embed the key in a URL. Documented accepted risk in `docs/SECURITY.md`. Consider one-time transfer tokens in a future sprint.

---

#### LOW — `github_refresh_token` storage key defined but unused

`SecureStorageKeys.githubRefreshToken` has no read/write path. GitHub OAuth App tokens may not issue refresh tokens; dead constant risks confusion in Sprint 3.

---

## 3. OAuth Implementation Review

### What works

| Check | Status |
|---|---|
| PKCE `S256` challenge | ✅ Correct (`sha256` + base64url) |
| Verifier length / randomness | ✅ 64-byte secure random |
| Verifier stored in secure storage | ✅ `oauth_code_verifier` |
| Verifier deleted after exchange | ✅ |
| Redirect URI matches platform config | ✅ `cursormc://oauth/callback` |
| No client secret on device | ✅ |
| Scopes match SECURITY.md | ✅ `repo read:org` |
| Token exchange `Accept: application/json` | ✅ |
| Deep link scheme Android + iOS | ✅ `cursormc` / host `oauth` |

### Gaps

| Gap | Severity |
|---|---|
| No `state` parameter | **High** |
| No explicit `error` / `error_description` handling in callback | **Medium** |
| `ConnectGithubScreen` `_loading` not cleared after successful browser launch | **Medium** (UI stuck on spinner until error or reconnect) |
| OAuth logic not in `github_api` package | **Medium** (Sprint 3 migration risk) |
| No integration test for token exchange (mock Dio) | **Medium** |
| "Skip for now" allows onboarding without GitHub | **Low** (acceptable for Sprint 2; document product decision) |

---

## 4. Secure Storage Implementation Review

### Strengths

- Abstract `SecureStorageService` interface preserved from Sprint 1 (forbidden key-name change avoided).
- `FlutterSecureStorageService` uses `AndroidOptions(encryptedSharedPreferences: true)`.
- Key names centralized in `SecureStorageKeys`.
- Repository is the primary read/write path for Cursor keys and biometric flags.

### Findings

#### MEDIUM — Tests use custom in-memory maps, not `flutter_secure_storage` test patterns

MASTER_BUILD_PLAN Section 11: *"Never mock `flutter_secure_storage` — use the in-memory implementation it provides."*

Tests implement `_InMemorySecureStorage` manually. Works for unit tests but diverges from project mocking policy and may miss platform-specific secure-storage edge cases.

---

#### LOW — No secure-storage integration test on a real device/emulator

All storage tests are in-memory fakes. Acceptable for CI; recommend one manual smoke test before release.

---

## 5. Drift Schema Quality Review

### Strengths

- **All 10 planned tables** exist with migration `0001_initial` (schema version 1).
- **Generated code committed** (`app_database.g.dart`).
- **`getOrCreateSettings()`** ensures singleton settings row.
- **`AppDatabase.inMemory()`** for tests — aligns with mocking policy.
- **No secret columns** — only opaque refs in `user_settings`.
- **Migration file not edited post-merge** — forbidden-change rule respected.

### Findings

#### MEDIUM — No foreign-key relationships between related tables

`RunRecords.agentId`, `ChatMessages.runId`, and `PinnedProjects` have no Drift foreign-key constraints. Orphan rows are possible if Sprint 4 delete/sync logic is incorrect.

---

#### MEDIUM — No migration test

AGENT_GUIDE requires a migration test when adding tables. `test/core/database/app_database_test.dart` covers CRUD on 3 tables only; no `onUpgrade` path test from version 0→1.

---

#### LOW — Six of ten tables have zero test coverage

Only `user_settings`, `pinned_projects`, `agent_sessions`, and `chat_messages` are exercised in tests. `run_records`, `tool_call_logs`, `usage_records`, `github_cache`, `diff_cache`, `queued_prompts` are schema-only.

---

#### LOW — `github_cache` / `diff_cache` store unbounded JSON text

No size limits or TTL enforcement at the schema layer (may be application-level in later sprints). Monitor for storage growth.

---

## 6. Test Coverage Review

### Current state

| Metric | Sprint 1 | Sprint 2 | Target (MASTER_BUILD_PLAN §11) |
|---|---|---|---|
| `apps/mobile` tests | 17 | **34** | All green ✅ |
| New auth/data tests | — | 4 files | 80% data layer |
| New screen widget tests | 1 (welcome) | **0** for Sprint 2 screens | 1 per screen |
| Provider tests | partial | **0** for `keySetupProvider`, `OnboardingNotifier` | Required |
| Domain `fromJson` tests | — | **0** for `CursorMeModel` | Required |
| Migration tests | N/A | **0** | Required per AGENT_GUIDE |
| Package tests | 4 placeholders | unchanged | Sprint 3 |

### Findings

#### HIGH — Missing widget tests for Sprint 2 screens

No tests for:

- `key_setup_screen.dart`
- `biometric_screen.dart`
- `connect_cursor_screen.dart`
- `connect_github_screen.dart`
- `pin_repo_screen.dart`
- `first_agent_screen.dart`

**Rule violated:** AGENT_GUIDE Step 10 / MASTER_BUILD_PLAN §11 — *"one widget test per screen"*.

---

#### HIGH — Missing provider tests for new auth/onboarding notifiers

`KeySetupNotifier`, `AuthSessionNotifier`, `OnboardingNotifier`, and `BiometricUnlockedNotifier` have no dedicated provider tests (state transitions loading → success/error).

---

#### MEDIUM — `auth_repository_impl_test` does not cover `authenticateWithBiometric` or `clearCursorKey`

Biometric auth path untested. `local_auth` should be injected/mocked.

---

#### MEDIUM — `github_auth_service_test` does not cover `handleOAuthCallback` or `_exchangeCode`

PKCE math is tested; end-to-end OAuth callback flow is not.

---

#### MEDIUM — `melos run test` / `melos run lint` not evidenced for full monorepo in Sprint 2 report

Sprint 2 completion report cites `flutter analyze` and `flutter test` in `apps/mobile` only. MASTER_BUILD_PLAN Definition of Done expects monorepo `melos run lint` and `melos run test` (5 packages).

---

#### LOW — `CursorMeModel.fromJson` untested

Null-safe defaults required by MASTER_BUILD_PLAN §4 should have unit tests before Sprint 3 API package mirrors the model.

---

## 7. Technical Debt Inventory

| Item | Introduced | Severity | Recommended resolution |
|---|---|---|---|
| `AuthRemoteSource` in app | Sprint 2 | Medium | Move to `cursor_api_core` in Sprint 3 |
| `GithubAuthService` in app | Sprint 2 | Medium | Move to `github_api` in Sprint 3 |
| Onboarding DB access in widgets | Sprint 2 | High | Add `ProjectRepository` / onboarding use-cases in Sprint 3 or 5 |
| `FutureProvider` for auth/github state | Sprint 2 | Medium | Refactor to `AsyncNotifierProvider` when touching auth |
| Dual `MaterialApp` in `CommanderApp` | Sprint 2 | Medium | Consolidate when adding idle biometric re-lock |
| `connectivity_service.dart` stub | Sprint 2 | Low | Sprint 6 |
| `onboarding_module.dart` missing | Sprint 2 | Low | Add barrel when onboarding grows |
| SECURITY.md features not implemented | Pre-Sprint 2 doc | Medium | Align doc or implement idle lock / FLAG_SECURE |
| No `develop` branch / CI workflows | Sprint 1 | Low | Human ops |
| iOS privacy strings missing | Sprint 2 | **Critical** | Fix before iOS QA |

---

## 8. Future Sprint 3 Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Breaking auth when extracting HTTP to `cursor_api_core` | High | High | Keep `AuthRepository` interface stable; migrate `AuthRemoteSource` first with parity tests |
| Duplicating GitHub OAuth in `github_api` | Medium | High | Single `GithubAuthService` owner; delete app copy after package wiring |
| Invalid API key in storage blocks agent features silently | High | Medium | Add launch-time or first-request `/v1/me` revalidation in Sprint 3 |
| SSE event names differ from docs | High | High | Mandatory raw SSE log before `SseParser` (MASTER_BUILD_PLAN Sprint 3) |
| Drift schema change needed for API models | Medium | Medium | Add `0002_*.dart` migration; never edit `0001_initial.dart` |
| Test coverage debt compounds | High | Medium | Budget Sprint 3 week 1 for missing Sprint 2 widget/provider tests |
| iOS build fails on device | High | High | Add privacy plist strings immediately |
| OAuth `state` CSRF exploited | Low | High | Add `state` before any public beta |
| `github_api` rate limiter not ready when projects feature needs it | Medium | Medium | Implement rate limit parsing in Sprint 3 package |

---

## 9. Findings Summary by Severity

### Critical (1)

| ID | Finding | Location |
|---|---|---|
| C-01 | Missing iOS `NSFaceIDUsageDescription` and `NSCameraUsageDescription` | `ios/Runner/Info.plist` |

### High (4)

| ID | Finding | Location |
|---|---|---|
| H-01 | Session auth checks key presence only, not `/v1/me` validity | `auth_provider.dart` / `authSessionProvider` |
| H-02 | GitHub OAuth missing `state` CSRF parameter | `github_auth_service.dart` |
| H-03 | Missing widget tests for all Sprint 2 onboarding/auth screens | `apps/mobile/test/` |
| H-04 | Onboarding writes to database directly from UI | `pin_repo_screen.dart` |

### Medium (14)

| ID | Finding | Location |
|---|---|---|
| M-01 | OAuth callback errors silently swallowed | `app.dart` `_handleDeepLink` |
| M-02 | `ConnectGithubScreen` loading state stuck after browser opens | `connect_github_screen.dart` |
| M-03 | `GithubAuthService` not in `github_api` package | `features/auth/data/` |
| M-04 | `AuthRemoteSource` duplicates `cursor_api_core` | `features/auth/data/` |
| M-05 | `FutureProvider` used for refreshable auth/github state | `auth_provider.dart`, `onboarding_provider.dart` |
| M-06 | Dual `MaterialApp` roots | `app.dart` |
| M-07 | SECURITY.md claims (idle lock, default biometrics) not implemented | docs vs code |
| M-08 | `AppLogger` does not redact exception details | `app_logger.dart` |
| M-09 | No Drift foreign keys between related tables | `core/database/tables/` |
| M-10 | No migration test | `test/core/database/` |
| M-11 | Missing provider tests for auth/onboarding notifiers | `test/features/auth/` |
| M-12 | `github_auth_service` callback/exchange untested | `test/features/auth/` |
| M-13 | `melos run test/lint` full monorepo not verified in Sprint 2 | process gap |
| M-14 | Biometric enable on finish without proving device can authenticate | `first_agent_screen.dart` |

### Low (8)

| ID | Finding | Location |
|---|---|---|
| L-01 | `onboarding_module.dart` missing | `features/onboarding/` |
| L-02 | Six Drift tables have no tests | `test/core/database/` |
| L-03 | `CursorMeModel.fromJson` untested | `domain/auth_model.dart` |
| L-04 | `github_refresh_token` key unused | `secure_storage_keys.dart` |
| L-05 | QR URL exposes raw API key | `tools/generate_key_qr.dart` |
| L-06 | `StatefulWidget` for non-controller UI state | auth/onboarding screens |
| L-07 | `github_cache` / `diff_cache` unbounded JSON | schema design |
| L-08 | Custom in-memory secure storage in tests vs policy | `test/` |

---

## 10. Recommendations Before Sprint 3 Begins

### Must do (blockers for iOS / security)

1. **Add iOS privacy strings** — `NSFaceIDUsageDescription`, `NSCameraUsageDescription` to `Info.plist` before any iOS device run.
2. **Add OAuth `state` parameter** — generate, persist, validate on callback alongside PKCE verifier.
3. **Surface OAuth callback failures** — propagate `GithubOAuthFailure` to `ConnectGithubScreen` (provider or shared error state); handle GitHub `?error=` responses.
4. **Plan session revalidation** — on cold start or first API call in Sprint 3, call `/v1/me`; clear key and route to onboarding on 401.

### Should do (Sprint 3 week 1)

5. **Add missing widget tests** — at minimum `KeySetupScreen`, `ConnectGithubScreen`, `BiometricScreen` (loading, error, success navigation).
6. **Add provider tests** — `KeySetupNotifier`, `OnboardingNotifier`, `AuthSessionNotifier` state transitions.
7. **Add `CursorMeModel.fromJson` tests** — missing fields, null `userEmail`, malformed `createdAt`.
8. **Add migration test** — verify `onCreate` produces all 10 tables from empty DB.
9. **Extract pin-repo logic** — `ProjectRepository.pinFromUrl()` so Sprint 5 does not duplicate DB access.
10. **Run and record** `melos run lint`, `melos run test`, `melos run build-check` across the monorepo; fix any package-level failures.

### Sprint 3 implementation order (risk reduction)

11. **Implement `cursor_api_core` first** — migrate `AuthRemoteSource` with identical `/v1/me` behavior and existing tests passing.
12. **Implement `github_api` second** — move `GithubAuthService` + token exchange; keep deep-link handler in app as thin delegate.
13. **Log raw SSE** before any `SseParser` code (MASTER_BUILD_PLAN hard requirement).
14. **Refactor `FutureProvider` → `AsyncNotifierProvider`** for `githubConnectedProvider` and `onboardingCompletedProvider` when adding `refresh()` needs.
15. **Align `docs/SECURITY.md`** with Sprint 2 reality (opt-in biometrics) or implement idle re-lock if product requires it.

### Defer (acceptable)

- Certificate pinning, FLAG_SECURE, jailbreak detection — Sprint 6 per roadmap.
- Full GitHub repo browser for pin step — Sprint 5.
- One-time QR transfer tokens — post-v1 enhancement.

---

## 11. Sprint 2 Definition of Done — Auditor Verdict

| Criterion | Verdict | Notes |
|---|---|---|
| Onboarding navigable end-to-end | **Pass** | Router + providers wired |
| API key entry + `/v1/me` validation | **Pass** | On save path |
| GitHub OAuth PKCE | **Pass with gaps** | Missing `state`, error UX |
| App locked behind biometrics | **Pass (opt-in)** | Not default-on per SECURITY.md |
| Drift 10 tables + migration | **Pass** | |
| Tests added / passing | **Pass (mobile)** | Below coverage targets |
| Lint passing | **Pass (mobile)** | Full melos not re-verified |
| Documentation updated | **Pass** | SECURITY.md drift remains |
| No forbidden changes | **Pass** | |
| No architecture change (no backend) | **Pass** | |

**Overall Sprint 2 quality grade: B+**

Functional goals met for a foundation sprint. Security and test rigor need hardening before beta distribution, especially on iOS. Sprint 3 should begin with platform privacy fixes and test debt paydown, then package extraction per `MASTER_BUILD_PLAN.md` Section 8.

---

## 12. Document Control

| Field | Value |
|---|---|
| Report type | Quality audit (read-only) |
| Code modified | None |
| Commits made | None |
| Next artifact | Sprint 3 implementation per `MASTER_BUILD_PLAN.md` |

---

*End of Sprint 2 Audit Report*
