# Security
# Cursor Mobile Commander

---

## API Key Storage

Cursor API keys and GitHub access tokens are stored exclusively in the **OS-native secure enclave**:

- **Android:** Android Keystore System via `flutter_secure_storage`
- **iOS:** iOS Keychain via `flutter_secure_storage`

Keys are **never** stored in:
- SQLite / Drift database
- `SharedPreferences`
- Log files
- Crash reports
- Analytics events
- Git repositories or version control

---

## Key Lifecycle

### Cursor API Key
1. User enters key in KeySetupScreen (paste or QR scan)
2. Key is immediately written to secure storage
3. App validates key with `GET /v1/me` before accepting
4. Key is read once per app session and injected into HTTP client
5. Key is cleared from Dart heap after injection (best-effort — Dart GC limitation)
6. User can rotate key in Settings → Key Management

### GitHub Access Token
1. Retrieved via OAuth 2.0 PKCE flow
2. Written to secure storage after exchange
3. Read only when making GitHub API calls
4. Refresh flow handles expiration silently

---

## Transport Security

### TLS
- Minimum TLS 1.3 enforced
- Configured in `android/app/src/main/res/xml/network_security_config.xml` (Android)
- Enforced via App Transport Security in `ios/Runner/Info.plist` (iOS)

### Certificate Pinning
The app pins the public key hashes of:
- `api.cursor.com`
- `api.github.com`

If a certificate changes (CDN rotation, acquisition), pinning must be updated and a new release pushed. Pinning expiration date is set 6 months ahead; CI will warn when expiration is within 30 days.

Certificate pinning is **disabled in debug builds** to allow local proxy tools during development.

---

## Authentication

### Biometric Lock
- Enabled by default on first launch
- Uses `local_auth` (Face ID / fingerprint / device PIN fallback)
- App locks after configurable idle timeout (default: 5 minutes, minimum: 1 minute)
- Lock state is stored in memory — not on disk

### Screen Security
- Android: `FLAG_SECURE` prevents screenshots and screen recording of app content
- iOS: App content is blurred in the app switcher (background snapshot protection)

---

## GitHub OAuth Scope

The app requests the minimum required scopes:
```
repo        — Read/write repos, PRs, branches, issues
read:org    — Read org membership for org repositories
```

The `workflow` scope is **not requested** — CI status is readable with `repo` scope.

---

## Android Security Configuration

```xml
<!-- AndroidManifest.xml -->
android:allowBackup="false"
android:fullBackupContent="false"
```

This prevents OS backup of app data (including secure storage paths on vulnerable OEM implementations).

---

## Input Handling

- User prompts are stripped of null bytes (`\x00`) before transmission
- Maximum prompt length: 4096 characters
- No server-side prompt filtering (Cursor API handles this)
- Prompt injection risk is an accepted limitation: the user is issuing commands to their own agents

---

## Known Limitations

| Limitation | Severity | Notes |
|---|---|---|
| Dart String API key in memory | Low | Dart GC; cannot zero string memory. Accepted risk. |
| QR code shows raw API key | Medium | QR is displayed briefly; user controls physical security. Future: one-time token QR. |
| Jailbreak/root weakens keychain | Medium | `flutter_jailbreak_detection` shows warning; does not block. |
| No hardware security module (HSM) | Low | Mobile HSM not available without backend. Accepted. |
| GitHub OAuth App (not App) | Low | Lower rate limits; no fine-grained repo permissions. Documented migration path to GitHub App. |

---

## Responsible Disclosure

If you discover a security vulnerability in Cursor Mobile Commander:

1. **Do not** open a public GitHub issue
2. Email: security@[your-domain].com with subject "CMC Security Disclosure"
3. Include: description, reproduction steps, impact assessment, suggested fix (optional)
4. You will receive acknowledgment within 48 hours
5. We aim to patch critical issues within 7 days

---

## Security Review Checklist (for Cursor Agents)

Before submitting any PR that touches auth, storage, or network:

- [ ] No API keys in any string literal, log, or comment
- [ ] No new `http://` URLs (HTTPS only)
- [ ] No new `SharedPreferences` usage for sensitive data
- [ ] No new network call without error + auth failure handling
- [ ] No new `dart:mirrors` or dynamic dispatch that bypasses type safety
- [ ] Certificate pinning config not modified
- [ ] Android `allowBackup` not re-enabled

If any of the above cannot be avoided: add `// AGENT_ESCALATE: security change` to the PR.
