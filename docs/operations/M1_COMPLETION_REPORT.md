---
title: M1 Completion Report — Terminologie & Rebranding
status: IMPLEMENTATION
owner: Lead Software Engineer
last_reviewed: 2026-06-25
depends_on:
  - architecture/AIVANCE_CORE_MIGRATION_PLAN.md
  - FEATURE_STATUS.md
---

# M1 Completion Report — Terminologie & Rebranding

**Fase:** M1 (Aivance Core Migration Plan §4)  
**Datum:** 2026-06-25  
**Status:** ✅ Afgerond

---

## 1. Samenvatting

Migratiefase M1 herpositioneert Cursor Mobile Commander als **Aivance Core** in user-facing UI, platform-metadata, documentatie en dev-tools — zonder architectuur-, package-, database- of API-contractwijzigingen.

---

## 2. Uitgevoerde wijzigingen

### 2.1 Branding & metadata

| Item | Van | Naar |
|------|-----|------|
| App display name | Cursor Mobile Commander | **Aivance** |
| Android `android:label` | cursor_mobile_commander | Aivance |
| iOS `CFBundleDisplayName` | Cursor Mobile Commander | Aivance |
| `MaterialApp.title` | Cursor Mobile Commander | Aivance |
| Mobile `pubspec.yaml` description | Manage Cursor Background Agents… | Aivance Core — delegate digital work… |
| Desktop `pubspec.yaml` description | Cursor Mobile Commander… | Aivance Core — internal prototype |
| Root `README.md` | CMC entry | Aivance Core entry + doc links |

### 2.2 Terminologie (user-facing)

| Oud | Nieuw | Context |
|-----|-------|---------|
| Agent(s) | Worker(s) | List, detail, errors, defaults |
| API key | Access code / connection | Onboarding, key setup, auth errors |
| Connect Cursor | Connect workspace | Onboarding |
| Command Cursor from your phone | Delegate work from your phone | Welcome |
| Cloud Agents | Digital workers | Copy |
| Runs | Tasks / task history | Detail & task list |
| API Keys (placeholder) | Connections | Settings route |

### 2.3 Routing (M1 R1 / M-03)

- Canonical worker tab: `/home/workers` (`Routes.homeWorkers`)
- Legacy alias: `/home/agents` → redirect naar `/home/workers` (+ nested paths)
- Helper aliases: `agentChat()` / `agentDetail()` delegaten naar worker-paden
- Bottom nav label: **Workers** (was Agents)

### 2.4 Documentatie

- `docs/FEATURE_STATUS.md` — living feature status (M-15)
- `README.md` — Aivance Core entry point
- `docs/operations/M1_COMPLETION_REPORT.md` — dit rapport

### 2.5 Dev tools

- `tools/generate_key_qr.dart` — "workspace connection" terminologie
- `tools/update_server.dart` — Aivance branding in CLI output
- `tools/pubspec.yaml` — description update

---

## 3. Bewust ongewijzigd (compatibiliteit)

| Item | Reden |
|------|-------|
| Package name `cursor_mobile_commander` | M2 |
| Melos workspace name | M2 |
| `SecureStorageKeys.cursorApiKey` | M2 dual-key migration |
| DB file `cursor_mobile_commander.db` | M4 |
| Internal types: `AgentSession`, `agentId`, `agentListProvider` | API / M2 facades |
| `cursor_api_*` packages | M3+ |
| Deep link scheme `cursormc://` | Breaking change |
| Desktop UI strings | M-13 (M2) |
| `commander_orchestrator` package name | M2 |

---

## 4. Bestanden aangepast (M1 scope)

### Mobile app — presentation & routing

- `apps/mobile/lib/app/app.dart`
- `apps/mobile/lib/app/routes.dart`
- `apps/mobile/lib/app/router.dart`
- `apps/mobile/lib/shared/widgets/app_bottom_nav.dart`
- `apps/mobile/lib/features/onboarding/presentation/*.dart` (welcome, connect, first-agent, pin, github)
- `apps/mobile/lib/features/auth/presentation/key_setup_screen.dart`
- `apps/mobile/lib/features/auth/data/auth_repository_impl.dart`
- `apps/mobile/lib/features/auth/domain/auth_failure.dart`
- `apps/mobile/lib/features/agents/presentation/agent_list_screen.dart`
- `apps/mobile/lib/features/agents/presentation/agent_detail_screen.dart`
- `apps/mobile/lib/features/agents/data/agent_repository_impl.dart` (default display names only)
- `apps/mobile/lib/features/chat/presentation/chat_provider.dart` (error strings)
- `apps/mobile/lib/features/chat/presentation/new_agent_sheet.dart`
- `apps/mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
- `apps/mobile/lib/features/projects/presentation/dashboard_screen.dart`
- `apps/mobile/lib/features/tasks/presentation/task_list_screen.dart`
- `apps/mobile/lib/shared/constants/colors.dart`

### Platform & metadata

- `apps/mobile/android/app/src/main/AndroidManifest.xml`
- `apps/mobile/ios/Runner/Info.plist`
- `apps/mobile/pubspec.yaml`
- `apps/desktop/pubspec.yaml`

### Tests

- `apps/mobile/test/app/routes_test.dart`
- `apps/mobile/test/app/router_test.dart`
- `apps/mobile/test/app/router_widget_test.dart`
- `apps/mobile/test/features/onboarding/welcome_screen_test.dart`
- `apps/mobile/test/features/onboarding/connect_cursor_screen_test.dart`
- `apps/mobile/test/features/auth/key_setup_screen_test.dart`

### Docs & tools

- `README.md`
- `docs/FEATURE_STATUS.md`
- `tools/generate_key_qr.dart`
- `tools/update_server.dart`
- `tools/pubspec.yaml`

---

## 5. Uitzonderingen

1. **Interne code-identifiers** (`agentId`, `AgentRepository`, file names) ongewijzigd per migratieplan.
2. **Developer-only comments** in providers/data layer kunnen nog "Cursor API key" vermelden — geen user-facing impact.
3. **Desktop app** behoudt legacy copy; rebrand gepland in M2 (M-13).
4. **Historische docs** (`ARCHITECTURE_AUDIT.md`, `CHATGPT_PROJECT_INSTRUCTIONS.md`) niet herschreven — audit is immutable; doc migratie parallel M2.
5. **`melos run lint`** faalt op pre-existing `commander_orchestrator` warning — niet geïntroduceerd door M1. **`apps/mobile` `flutter analyze`**: 0 issues.

---

## 6. Testresultaten

| Commando | Resultaat |
|----------|-----------|
| `melos bootstrap` | ✅ SUCCESS (7 packages) |
| `melos run test` | ✅ SUCCESS (alle packages) |
| `flutter test` (apps/mobile) | ✅ 63/63 passed |
| `flutter analyze` (apps/mobile) | ✅ No issues found |
| `melos run build-check` (Android debug APK) | ✅ SUCCESS |
| `flutter build windows --debug` (desktop) | ✅ SUCCESS |

---

## 7. Buildresultaten

| Target | Artifact |
|--------|----------|
| Android debug | `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk` |
| Windows debug | `apps/desktop/build/windows/x64/runner/Debug/cursor_commander_desktop.exe` |

---

## 8. Definition of Done checklist

- [x] Geen user-visible "Cursor Mobile Commander"
- [x] Geen user-visible "Agent" in primaire flows (list, chat, onboarding)
- [x] `melos run test` groen
- [x] `FEATURE_STATUS.md` aangemaakt
- [ ] Screenshots/design review — **menselijke review aanbevolen** (niet geautomatiseerd)

---

## 9. Bekende aandachtspunten voor M2

| ID | Item |
|----|------|
| H-02 | Melos workspace rename → `aivance` |
| H-01 | `commander_orchestrator` → `aivance_orchestrator` |
| P1 | Provider facades (`taskListProvider`, deprecated aliases) |
| M-04 | Bottom nav restructure Tasks/Workers |
| M-13 | Desktop rebrand → Aivance Dev Console |
| C-01 | CI/CD pipeline |
| C-02 | Orchestrator bypass on follow-up |
| S1–S2 | Secure storage dual-key migration |

---

## 10. Rollback

Revert de M1 commit (strings + routes + metadata). Geen database- of storage-impact. Legacy `/home/agents` redirects vervallen na revert — bookmarks moeten opnieuw naar `/home/workers` of oude paden hersteld.

---

*M1 — zero architecture risk. Klaar voor M2 Core Hardening.*
