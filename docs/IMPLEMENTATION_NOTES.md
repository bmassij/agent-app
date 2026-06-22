# Sprint 2 — Implementation Notes

**Status:** Complete  
**Date:** 2026-06-22  
**Scope:** Auth + Database — Drift, secure storage, onboarding, biometrics, GitHub OAuth PKCE

---

## What Was Built

### Drift Database (`core/database/`)
- 10 tables per PHASE7: `user_settings`, `pinned_projects`, `agent_sessions`, `run_records`, `chat_messages`, `tool_call_logs`, `usage_records`, `github_cache`, `diff_cache`, `queued_prompts`
- `AppDatabase` with `open()`, `inMemory()`, `getOrCreateSettings()`
- Migration `migrations/0001_initial.dart` (schema version 1)
- `database_provider.dart` — `appDatabaseFutureProvider`
- Codegen: `app_database.g.dart` (run `melos run codegen` after table changes)

### Auth Feature (`features/auth/`)
- Domain: `CursorMeModel`, sealed `AuthFailure`, `AuthRepository` interface
- Data: `AuthRemoteSource` (`GET /v1/me`), `AuthRepositoryImpl`, `GithubAuthService` (PKCE)
- Presentation: `auth_provider.dart`, `key_setup_screen.dart`, `biometric_screen.dart`, `qr_scanner_widget.dart`
- Secure storage keys: `cursor_api_key`, `github_access_token`, `oauth_code_verifier`

### Onboarding (`features/onboarding/`)
- `onboarding_provider.dart` — completion flag in `user_settings`, GitHub/pin/biometric step providers
- Wired screens: connect Cursor (manual + QR), connect GitHub, pin repo URL, biometric opt-in
- Router `authRedirect()` — unauthenticated → onboarding; authenticated incomplete → connect Cursor; completed → home

### App Integration
- `main.dart` — opens DB, overrides `appDatabaseFutureProvider`
- `app.dart` — biometric unlock gate, `app_links` OAuth callback handler
- Deep links: Android `cursormc://oauth`, iOS URL scheme `cursormc`
- `tools/generate_key_qr.dart` — desktop helper for `cursormc://auth?key=...` QR payloads

### Tests Added (17 new → 34 total in `apps/mobile`)
- `test/core/database/app_database_test.dart`
- `test/features/auth/auth_repository_impl_test.dart`
- `test/features/auth/github_auth_service_test.dart`
- `test/features/auth/qr_scanner_widget_test.dart`
- Updated router/auth session tests for onboarding + DB providers

---

## How to Run

```bash
cd cursor-mobile-commander
melos bootstrap
melos run codegen   # if *.g.dart missing

cd apps/mobile
flutter run --dart-define=GITHUB_CLIENT_ID=your_oauth_app_id

# Tests + lint
flutter analyze
flutter test
```

---

## Auth Guard Behavior (Sprint 2)

1. No API key → `/onboarding` (welcome)
2. API key stored → validate presence via secure storage (`authSessionProvider`)
3. Key setup validates with live `GET /v1/me` before persisting
4. Onboarding incomplete → redirect to `/onboarding/connect-cursor`
5. Biometric enabled → `BiometricScreen` gate on cold start until unlock
6. GitHub OAuth → external browser, callback via `cursormc://oauth/callback`

---

## Known Gaps (By Design — Sprint 3+)

| Item | Sprint |
|---|---|
| Cursor/GitHub API client packages | Sprint 3 |
| Chat streaming | Sprint 4 |
| Real repo browser / GitHub API for pin | Sprint 5 |
| Connectivity service (real offline detection) | Sprint 6 |

---

## Verification (2026-06-22)

```
flutter analyze (apps/mobile)   ✅ 0 issues
flutter test (apps/mobile)      ✅ 34 tests
```

---

## Handoff Notes for Sprint 3

1. Run `melos bootstrap && melos run codegen` before starting.
2. Move `AuthRemoteSource` logic into `packages/cursor_api_core` — do not duplicate HTTP client setup.
3. `AuthRepositoryImpl` and onboarding screens are ready; agents/projects will consume `AppDatabase` tables.
4. GitHub token is in secure storage; `github_api` package should read via injected storage abstraction.
5. Before `SseParser`: make one real Cursor API call and log raw SSE (per MASTER_BUILD_PLAN).
6. Do not modify migration `0001_initial.dart` after merge — add `0002_*.dart` for schema changes.

---

## Sprint 1 Notes

See prior sections in git history / `SPRINT1_COMPLETION_REPORT.md` for foundation details.
