---
title: M2 Completion Report — Core Hardening & Foundation Cleanup
status: IMPLEMENTATION
owner: Lead Software Engineer
last_reviewed: 2026-06-25
depends_on:
  - architecture/AIVANCE_CORE_MIGRATION_PLAN.md
  - FEATURE_STATUS.md
  - security/IMPLEMENTATION_STATUS.md
---

# M2 Completion Report — Core Hardening & Foundation Cleanup

**Fase:** M2 (Aivance Core Migration Plan §4)  
**Datum:** 2026-06-25  
**Status:** ✅ Afgerond

---

## 1. Samenvatting

Migratiefase M2 hardent de Aivance Core-fundering: CI/CD, package/monorepo cleanup, orchestrator follow-up fix, secure-storage dual-key, offline queue, connectivity, notifications, desktop rebrand en technische schuld uit de audit — **zonder** Provider Engine, Project DNA, Presence of backend.

---

## 2. Uitgevoerde werkzaamheden

### 2.1 CI/CD

| Item | Detail |
|------|--------|
| Workflow | `.github/workflows/ci.yml` |
| Triggers | `push` / `pull_request` op `main` en `master` |
| Quality job | `melos bootstrap` → `format-check` → `lint` → `test` |
| Build job | `melos run build-check` (Android debug APK) na quality |

### 2.2 Package & monorepo

| Item | Van | Naar |
|------|-----|------|
| Orchestrator package | `commander_orchestrator` | `aivance_orchestrator` |
| Main export | `commander_orchestrator.dart` | `aivance_orchestrator.dart` |
| Melos workspace | `cursor_mobile_commander` | `aivance` |
| Melos script | — | `build-desktop` toegevoegd |

Imports in `apps/mobile`, `apps/desktop` en `pubspec_overrides.yaml` bijgewerkt.

### 2.3 Orchestrator follow-up (O1)

- Follow-up prompts lopen via `AgentCommandOrchestrator.dispatch` met `existingAgentId` en `repoUrl`.
- `agent_repository_impl.dart`: verbeterde `_repoUrlFromProjectId()`; chat levert `repoUrl`.
- `prompt_builder.dart`: Aivance-context headers.
- **Test:** `packages/aivance_orchestrator/test/follow_up_orchestrator_test.dart` bewijst enriched prompt (`## Context`, repository, user text).

### 2.4 Secure storage dual-key (S1–S2)

- `secure_storage_keys.dart`: `provider_cursor_token`, `integration_github_token`.
- `secure_storage_service.dart`: `readCursorToken` / `writeCursorToken`, `readGithubToken` / `writeGithubToken` (dual read/write).
- Consumers: `auth_repository_impl`, `agents_provider`, `github_auth_service`.

### 2.5 Provider facades (P1)

- `aivance_providers.dart`: `@Deprecated` aliases (`taskListProvider`, `orchestratorProvider`, etc.) voor geleidelijke terminologie-migratie.

### 2.6 Feature flags (C-08)

- `feature_flags.dart`: toggles voor notifications, offline queue, background polling.

### 2.7 Connectivity

- `connectivity_service.dart`: echte `connectivity_plus`-implementatie (vervangt stub).
- `isOnlineProvider` (`StreamProvider<bool>`) voor UI en offline queue.
- `offline_banner.dart`: `ConsumerWidget` met live connectivity; getoond in `home_shell_screen.dart`.

### 2.8 Offline queue (D2)

- `queued_prompt_service.dart`: schrijft naar bestaande Drift-tabel `queued_prompts`.
- `offline_queue_provider.dart`: verwerkt queue bij reconnect.
- `chat_provider.dart`: queue bij offline verzenden; flush via `app.dart` op `isOnlineProvider`.
- **Test:** `apps/mobile/test/features/chat/queued_prompt_service_test.dart`.

### 2.9 Notifications (N1–N3)

- `notification_service.dart`: `flutter_local_notifications` init + task-complete melding.
- `background_task_service.dart`: WorkManager-registratie voor periodieke achtergrondtaak.
- `main.dart`: init notifications + `BackgroundTaskService.register()`.
- `chat_provider.dart`: notificatie op SSE `DoneEvent`.

### 2.10 Desktop rebrand (M-13)

- `apps/desktop`: **Aivance Dev Console** titel en setup-copy.
- Widget test bijgewerkt.

### 2.11 Documentatie & security

- `docs/security/IMPLEMENTATION_STATUS.md` — security reality document.
- `docs/FEATURE_STATUS.md` — bijgewerkt voor M2.

### 2.12 Dependency cleanup

- `speech_to_text` verwijderd (ongebruikt per audit).
- `connectivity_plus`, `workmanager`, `flutter_local_notifications` **geactiveerd** (niet alleen gedeclareerd).

---

## 3. Opgeloste technische schuld (audit / M2)

| ID | Item | Oplossing |
|----|------|-----------|
| O1 | Follow-up bypassed orchestrator | Orchestrator path + test |
| S1–S2 | Legacy secure storage keys | Dual read/write |
| D2 | `queued_prompts` schema-only | `QueuedPromptService` + wire-up |
| C-08 | Geen feature flags | `feature_flags.dart` |
| — | Connectivity stub | `ConnectivityService` + `connectivity_plus` |
| — | Geen CI/CD | GitHub Actions workflow |
| — | `commander_orchestrator` naming | Rename → `aivance_orchestrator` |
| — | Ongebruikte `speech_to_text` | Verwijderd |
| — | Notifications/WorkManager declared only | Geïmplementeerd v1 |
| M-13 | Desktop legacy branding | Aivance Dev Console |

---

## 4. Bewust ongewijzigd (M3+)

| Item | Fase |
|------|------|
| `ExecutionProvider` / provider abstraction | M3 |
| `aivance_capabilities`, `aivance_provider_contract` | M3 |
| Package rename `cursor_mobile_commander` (app) | Later |
| DB filename `cursor_mobile_commander.db` | M4 |
| Tabel-renames (`agent_sessions` → …) | M4–M5 |
| `github_caches`, `diff_caches` activatie | M4 |
| Project DNA / Registry | M4–M5 |
| Presence™ module | M6 |
| Platform API / backend | Post-M6 |
| Certificate pinning, idle re-lock | Backlog |
| OTA HTTPS-only enforcement | Backlog |

---

## 5. Testresultaten

| Commando | Resultaat |
|----------|-----------|
| `melos bootstrap` | ✅ SUCCESS (7 packages) |
| `melos run format-check` | ✅ SUCCESS |
| `melos run lint` | ✅ SUCCESS (alleen `info`-niveau in packages; 0 errors) |
| `melos run test` | ✅ SUCCESS |

### Per package

| Package | Tests |
|---------|-------|
| `aivance_orchestrator` | 5 passed |
| `cursor_api_core` | 27 passed |
| `cursor_api_agents` | 25 passed |
| `cursor_api_stream` | 29 passed |
| `github_api` | 12 passed |
| `cursor_commander_desktop` | 1 passed |
| `cursor_mobile_commander` | 66 passed |
| **Totaal** | **165 passed** |

Nieuwe/gewijzigde tests: `follow_up_orchestrator_test`, `queued_prompt_service_test`, secure-storage mocks in auth/github/router tests, `OfflineBanner` async provider pump, desktop widget test.

---

## 6. CI-resultaten

Workflow `.github/workflows/ci.yml` is lokaal gevalideerd via dezelfde Melos-commando's als de CI-jobs. **GitHub Actions-run op remote:** niet uitgevoerd in deze sessie (workflow toegevoegd; eerste groene run verwacht bij eerste PR/push na merge).

---

## 7. Buildresultaten

| Commando | Resultaat |
|----------|-----------|
| `melos run build-check` (Android debug APK) | ✅ SUCCESS |
| `melos run build-desktop` (Windows debug) | ✅ SUCCESS |

**Opmerking Windows:** `flutter clean` in `apps/mobile` aanbevolen na Android-builds als `dart format .` faalt op stale `build/` paden.

---

## 8. Bekende beperkingen

1. **WorkManager v1** leest DB in achtergrond; geen volledige API-poll in isolate (security doc §Partial).
2. **Background notifications** alleen bij SSE `DoneEvent` in foreground stream; geen push voor externe run-completion zonder actieve stream.
3. **Offline queue** verwerkt prompts FIFO bij reconnect; geen conflict-resolution bij parallelle sessies.
4. **Melos `format`/`format-check`** scant package-root `.` — stale Android `build/` artifacts kunnen op Windows formatter breken; `flutter clean` mitigatie.
5. **Lint `info` items** (trailing commas, sort_pub_dependencies) in packages — pre-existing style; geen errors.
6. **App package name** `cursor_mobile_commander` en DB-bestandsnaam ongewijzigd (bewust M4).
7. **CI desktop build** niet in workflow (alleen Android); desktop lokaal geverifieerd.

---

## 9. Aanbevelingen voor M3

1. **Provider abstraction:** introduceer `aivance_provider_contract` + `CursorExecutionProvider`; route `agent_repository_impl` via interface met feature flag.
2. **Capability package:** `aivance_capabilities` met 3–5 Presence capability IDs; `CapabilityRouter` in orchestrator.
3. **ADR-008** publiceren vóór merge van provider PR.
4. **Verwijder `@Deprecated` facades** pas na consumer-migratie (of behoud 1 release).
5. **Secure storage S3:** plan verwijdering oude keys na 2 releases (M4).
6. **CI uitbreiden:** optioneel `build-desktop` job op `windows-latest`; cache strategy voor Melos.
7. **Background polling:** WorkManager + secure token access pattern herzien wanneer provider interface bestaat.

---

## 10. Rollback

- Package rename: revert commit; herstel `commander_orchestrator` pad in pubspecs.
- Feature flags: zet `enableNotifications`, `enableOfflineQueue`, `enableBackgroundPolling` op `false`.
- Dual-key storage: stop writing new keys; read blijft fallback op legacy keys.

---

*M2 afgerond 2026-06-25. Geen M3-werkzaamheden uitgevoerd.*
