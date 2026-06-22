# Audit Remediation Report
# Cursor Mobile Commander

**Date:** 2026-06-22  
**Scope:** Sprint 2 Quality Audit — Critical and High findings only  
**Reference:** `SPRINT2_AUDIT_REPORT.md`  
**Status:** Complete — ready for Sprint 3 planning (not Sprint 3 implementation)

---

## Executive Summary

All **1 Critical** and **4 High** findings from `SPRINT2_AUDIT_REPORT.md` have been remediated. The mobile app now has iOS privacy strings, cold-start session validation via `/v1/me`, GitHub OAuth `state` CSRF protection, a `ProjectRepository` for pin-repo persistence, and widget tests for all Sprint 2 auth/onboarding screens.

**Verification:** `flutter analyze` — 0 issues · `flutter test` — **50 tests** passing

---

## Findings Resolved

### C-01 — Missing iOS privacy usage descriptions ✅

| Field | Detail |
|---|---|
| **Severity** | Critical |
| **Fix** | Added `NSFaceIDUsageDescription` and `NSCameraUsageDescription` to `ios/Runner/Info.plist` |
| **Tests** | Documented in `docs/DEVELOPMENT_GUIDE.md` (manual iOS device verification) |

---

### H-01 — Session authentication presence-only ✅

| Field | Detail |
|---|---|
| **Severity** | High |
| **Fix** | Added `AuthRepository.validateSession()` — calls `GET /v1/me` with stored key; clears key on 401; allows offline when network fails |
| **Integration** | `AuthSessionNotifier` now calls `validateSession()` instead of `hasCursorKey()` |
| **Tests** | `auth_repository_impl_test.dart` (4 cases), `auth_session_provider_test.dart` (mocked repo) |
| **Docs** | `docs/SECURITY.md`, `docs/DEVELOPMENT_GUIDE.md` updated |

---

### H-02 — GitHub OAuth missing `state` parameter ✅

| Field | Detail |
|---|---|
| **Severity** | High |
| **Fix** | Generate `state` in `startOAuthFlow()`, persist as `oauth_state` in secure storage, include in authorize URL, validate on callback |
| **Additional** | Handle GitHub `?error=` responses; clear pending OAuth keys on failure |
| **Tests** | `github_auth_service_test.dart` — state in URL, mismatch rejection, error rejection, successful exchange |
| **Storage** | New key `SecureStorageKeys.oauthState` (additive — no existing keys changed) |

---

### H-03 — Missing widget tests for Sprint 2 screens ✅

| Field | Detail |
|---|---|
| **Severity** | High |
| **Fix** | Added widget tests for all six Sprint 2 screens |
| **New test files** | |

| Screen | Test file |
|---|---|
| `ConnectCursorScreen` | `test/features/onboarding/connect_cursor_screen_test.dart` |
| `ConnectGithubScreen` | `test/features/onboarding/connect_github_screen_test.dart` |
| `PinRepoScreen` | `test/features/onboarding/pin_repo_screen_test.dart` |
| `FirstAgentScreen` | `test/features/onboarding/first_agent_screen_test.dart` |
| `KeySetupScreen` | `test/features/auth/key_setup_screen_test.dart` |
| `BiometricScreen` | `test/features/auth/biometric_screen_test.dart` |

---

### H-04 — Onboarding bypasses repository layer (pin repo) ✅

| Field | Detail |
|---|---|
| **Severity** | High |
| **Fix** | Extracted `ProjectRepository` / `ProjectRepositoryImpl` with `pinFromUrl()` |
| **Provider** | `pinRepoProvider` in `features/projects/presentation/projects_provider.dart` |
| **UI** | `PinRepoScreen` delegates to `pinRepoProvider` — no direct `AppDatabase` access |
| **Tests** | `test/features/projects/project_repository_impl_test.dart` |

---

## Files Changed

### Platform
- `apps/mobile/ios/Runner/Info.plist`

### Auth
- `lib/features/auth/domain/auth_repository.dart`
- `lib/features/auth/data/auth_repository_impl.dart`
- `lib/features/auth/data/github_auth_service.dart`
- `lib/features/auth/presentation/auth_provider.dart`
- `lib/core/storage/secure_storage_keys.dart`

### Projects (new)
- `lib/features/projects/domain/project_failure.dart`
- `lib/features/projects/domain/project_repository.dart`
- `lib/features/projects/data/project_repository_impl.dart`
- `lib/features/projects/presentation/projects_provider.dart`

### Onboarding
- `lib/features/onboarding/presentation/pin_repo_screen.dart`

### Tests (10 files added/updated)
- `test/app/auth_session_provider_test.dart`
- `test/features/auth/auth_repository_impl_test.dart`
- `test/features/auth/github_auth_service_test.dart`
- `test/features/auth/key_setup_screen_test.dart`
- `test/features/auth/biometric_screen_test.dart`
- `test/features/onboarding/connect_cursor_screen_test.dart`
- `test/features/onboarding/connect_github_screen_test.dart`
- `test/features/onboarding/pin_repo_screen_test.dart`
- `test/features/onboarding/first_agent_screen_test.dart`
- `test/features/projects/project_repository_impl_test.dart`

### Documentation
- `docs/SECURITY.md`
- `docs/DEVELOPMENT_GUIDE.md`
- `AUDIT_REMEDIATION_REPORT.md` (this file)

---

## Verification

| Command | Result |
|---|---|
| `flutter analyze` (apps/mobile) | ✅ 0 issues |
| `flutter test` (apps/mobile) | ✅ 50 tests |

### Test count change

| Stage | Tests |
|---|---|
| Post Sprint 2 | 34 |
| Post remediation | **50** (+16) |

---

## Medium/Low Findings — Not in Scope

Per instructions, only Critical and High findings were remediated. The following remain for future sprints:

| ID | Finding | Planned |
|---|---|---|
| M-01 | OAuth callback errors silently discarded in `app.dart` | Sprint 3 or follow-up |
| M-02 | `ConnectGithubScreen` loading state after browser launch | Sprint 3 or follow-up |
| M-03–M-14 | Architecture debt, migration tests, provider tests, etc. | Sprint 3+ |

---

## Commits

Remediation is committed separately from Sprint 3 work:

1. `62f3d9f` — `fix(ios): add face id and camera privacy usage descriptions`
2. `830fc53` — `fix(auth): validate session on launch and harden oauth state`
3. `37554d2` — `refactor(projects): extract pin repository from onboarding ui`
4. `ecaf39d` — `test(mobile): cover audit remediation for auth and onboarding`
5. `8476e9d` — `docs: audit remediation report and security guide updates`

---

## Sprint 3 Readiness

| Gate | Status |
|---|---|
| All Critical findings resolved | ✅ |
| All High findings resolved | ✅ |
| Tests passing | ✅ |
| Lint clean | ✅ |
| Sprint 3 API packages | **Not started** (per scope) |

Sprint 3 may begin when a human approves. First Sprint 3 tasks remain per `MASTER_BUILD_PLAN.md`: implement `cursor_api_core`, migrate `AuthRemoteSource`, log raw SSE before `SseParser`.

---

*End of Audit Remediation Report*
