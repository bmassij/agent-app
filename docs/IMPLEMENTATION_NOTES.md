# Sprint 1 — Implementation Notes

**Status:** Complete  
**Date:** 2026-06-22  
**Scope:** Foundation — monorepo, app shell, navigation, theme, package scaffolds

---

## What Was Built

### Monorepo (S1.1)
- [`melos.yaml`](../melos.yaml) — bootstrap, lint, test, codegen, build-check scripts
- [`analysis_options.yaml`](../analysis_options.yaml) — shared strict lint rules
- [`.gitignore`](../.gitignore) — Flutter/Dart/secrets exclusions
- [`apps/mobile/pubspec.yaml`](../apps/mobile/pubspec.yaml) — full dependency list per PHASE7

### App Shell (S1.2)
- Dark theme ([`app/theme.dart`](../apps/mobile/lib/app/theme.dart))
- Route constants ([`app/routes.dart`](../apps/mobile/lib/app/routes.dart)) — full PHASE2 route tree
- GoRouter with auth guard ([`app/router.dart`](../apps/mobile/lib/app/router.dart))
- Auth session provider checking `cursor_api_key` in secure storage
- Home shell with 3-tab bottom navigation (Projects, Agents, Settings)
- Onboarding placeholder screens (5 steps)
- Shared widgets: `LoadingSpinner`, `ErrorView`, `OfflineBanner`, `AppBottomNav`
- Shared constants: `AppColors`, `AppSizes`

### Package Scaffolds (S1.3)
- `packages/cursor_api_core` — TODO barrel + placeholder test
- `packages/cursor_api_agents` — TODO barrel + placeholder test
- `packages/cursor_api_stream` — TODO barrel + placeholder test
- `packages/github_api` — TODO barrel + placeholder test

### Tests
- Route constant tests
- `authRedirect` unit tests
- Auth session provider tests (in-memory secure storage)
- Shared widget tests
- Welcome screen widget test
- Router widget tests (onboarding redirect + authenticated home)

---

## How to Run

```bash
cd cursor-mobile-commander
melos bootstrap

# First time only — generate platform folders if missing:
cd apps/mobile
flutter create . --org com.cursormobilecommander --project-name cursor_mobile_commander
cd ../..

melos run lint
melos run test
melos run build-check   # requires Android SDK
flutter run             # from apps/mobile
```

---

## Auth Guard Behavior (Sprint 1)

- Reads `cursor_api_key` from `flutter_secure_storage` (no validation yet)
- Unauthenticated → `/onboarding`
- Authenticated → `/home/projects`
- Sprint 2 adds `GET /v1/me` validation and key setup UI

---

## Known Gaps (By Design — Sprint 2+)

| Item | Sprint |
|---|---|
| API key paste / QR scan UI | Sprint 2 |
| Biometric lock | Sprint 2 |
| GitHub OAuth | Sprint 2 |
| Drift database | Sprint 2 |
| Cursor/GitHub API clients | Sprint 3 |
| Chat streaming | Sprint 4 |

---

## Dependency Resolution (Sprint 1)

PHASE7 dependency versions required minor bumps for Dart 3.12 compatibility:

- `speech_to_text`: ^6.6.2 → ^7.4.0
- `share_plus`: ^9.0.0 → ^12.0.2
- `flutter_secure_storage`: ^9.0.0 → ^9.2.4

Root `pubspec.yaml` added with `melos: ^6.3.2` (Melos 6 uses `melos.yaml`; Melos 7+ requires pub workspaces migration).

---

## Verification (2026-06-22)

```
melos bootstrap   ✅
melos run lint    ✅ (0 issues)
melos run test    ✅ (17 tests)
melos run build-check ✅
```

**Windows note:** Enable Developer Mode for plugin symlink support during `flutter pub get`.

---

## Handoff Notes for Sprint 2

1. Run `melos bootstrap && melos run lint && melos run test` first.
2. `SecureStorageService` is an abstract interface — extend, do not replace.
3. `authRedirect()` in `router.dart` is unit-tested — update tests if guard logic changes.
4. Onboarding screens exist as navigation stubs — wire to real auth flows.
5. If `flutter create` was not run, platform folders may be missing — run before `flutter run`.
