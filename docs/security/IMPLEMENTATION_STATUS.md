---
title: Security Implementation Status
status: IMPLEMENTATION
owner: Security / CTO
last_reviewed: 2026-06-25
depends_on:
  - development/AIVANCE_DEVELOPMENT_GUIDE.md
  - research/ARCHITECTURE_AUDIT.md
---

# Security Implementation Status

Reality document for Aivance Core client security. **Target policy:** `SECURITY_POLICY.md` (when published). This file reflects code as of M2 (2026-06-25).

---

## Implemented

| Control | Status | Location |
|---------|--------|----------|
| Secrets in `flutter_secure_storage` | ✅ | `secure_storage_service.dart` |
| Dual-key migration (cursor + GitHub) | ✅ M2 | `readCursorToken` / `writeCursorToken` |
| HTTPS for Cursor/GitHub APIs | ✅ | `cursor_api_core`, `github_api` |
| GitHub OAuth PKCE + state | ✅ | `github_auth_service.dart` |
| Android `allowBackup=false` | ✅ | `AndroidManifest.xml` |
| Biometric opt-in unlock | ✅ | `auth_repository_impl.dart` |
| OAuth deep link scheme | ✅ | `cursormc://` (unchanged M2) |

---

## Partial / gaps (audit-aligned)

| Control | Status | Notes |
|---------|--------|-------|
| Certificate pinning | ❌ | Not implemented |
| Idle biometric re-lock | ❌ | M2 backlog → M2+ |
| Input sanitization (prompt length) | ❌ | Planned |
| OTA HTTPS-only | ⚠️ | Cleartext allowed for dev LAN OTA |
| Background isolate API access | ⚠️ | WorkManager reads DB only; no API poll in isolate |
| Jailbreak / root warning | ❌ | M6 |

---

## M2 changes

- **S1–S2:** Dual-read/write for `provider_cursor_token` ↔ `cursor_api_key` and `integration_github_token` ↔ `github_access_token`.
- **C-08:** Feature flags for notifications, offline queue, background polling (`feature_flags.dart`).

---

## Verification

- Auth tests: `apps/mobile/test/features/auth/`
- Secure storage dual-key: covered by `auth_repository_impl_test` + service methods
- CI: `.github/workflows/ci.yml` runs on every PR

---

*Update this file when security behavior changes. Do not claim controls that are not in code.*
