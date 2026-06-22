# Roadmap
# Cursor Mobile Commander

---

## Vision

A native mobile app that makes Cursor Background Agents as easy to use as sending a WhatsApp message. Create, monitor, review, and merge — entirely from your phone.

---

## v1.0 — Foundation (Target: 6 weeks from kickoff)

The minimum viable product for a single user managing their own Cursor agents.

**Included:**
- Cursor API key setup (paste + QR scan)
- GitHub OAuth connect
- Pin multiple repositories
- Create new agents with prompt + options
- Real-time chat streaming (SSE)
- Follow-up prompts to existing agents
- Cancel running agents
- Background polling + local notifications on completion
- View token usage per run
- PR list, diff viewer, approve, merge, delete branch
- Repository file browser
- Command templates (8 built-in + custom)
- Conversation history (SQLite persistence)
- Offline read mode + prompt queue
- Dark theme
- Android release (Play Store)

**Not included in v1.0:**
- iOS App Store (TestFlight only)
- Multi-account support
- Tablet / landscape layout
- Team / multi-user support

---

## v1.1 — iOS Production (Target: +2 weeks)

- iOS App Store submission
- iOS-specific biometric (Face ID)
- iOS background fetch for notifications
- iOS app switcher blur

---

## v1.2 — Productivity (Target: +4 weeks)

- Full-text search across conversation history
- Export conversation as Markdown
- Agent tagging / labeling (local)
- Tablet layout (split-pane: projects left, chat right)
- Voice input (speech_to_text)
- Image attach to prompts
- Artifacts viewer (screenshots, logs)

---

## v1.3 — GitHub Power Features (Target: +4 weeks)

- CI/CD status detail view (logs per step)
- Branch comparison view
- Inline comment on PR diff
- Multiple merge method support (squash, rebase, merge)
- Draft PR support
- GitHub Issues list (read + create)

---

## v2.0 — Team Mode (Target: +12 weeks, requires backend)

When a backend is added:
- GitHub App integration (higher rate limits, fine-grained permissions)
- Push notifications via FCM (not polling)
- Multi-user workspace
- Agent assignment (create agent; assign to team member for review)
- Webhook-driven real-time updates
- Usage dashboard (tokens per user, per project, per week)
- Agent audit log (who started what, when, what merged)

---

## Future Ideas (Unscheduled)

- Cursor agent marketplace (community templates)
- Watch app companion (approve PR from watch)
- Desktop menu bar companion (macOS)
- GitLab / Bitbucket support (when Cursor supports alternative VCS)
- Self-hosted Cursor support (enterprise)

---

## Changelog

### Sprint 1 — Foundation (2026-06-22) ✅

**Status:** Complete

- [x] Monorepo scaffold (`melos.yaml`, `analysis_options.yaml`, `.gitignore`)
- [x] Flutter app shell with dark theme
- [x] go_router with full route tree + auth guard
- [x] Bottom navigation (Projects, Agents, Settings)
- [x] Onboarding placeholder flow (5 screens)
- [x] Shared widgets (`LoadingSpinner`, `ErrorView`, `OfflineBanner`)
- [x] Package scaffolds: `cursor_api_core`, `cursor_api_agents`, `cursor_api_stream`, `github_api`
- [x] Unit and widget tests for routing, auth guard, shared widgets
- [x] `flutter run` — requires Flutter SDK; platform folders generated
- [x] `melos run lint` / `melos run test` / `melos run build-check` verified

**Next:** Sprint 3 — API Packages

### Sprint 2 — Auth + Database (2026-06-22) ✅

**Status:** Complete

- [x] Drift database — 10 tables, migration `0001_initial`, `AppDatabase`, codegen
- [x] Secure storage integration — API key, GitHub token, PKCE verifier keys
- [x] Cursor API key onboarding — paste, validate via `GET /v1/me`, QR scan
- [x] Biometric authentication — opt-in during onboarding, app unlock gate
- [x] GitHub OAuth PKCE — browser flow, deep link `cursormc://oauth/callback`
- [x] Onboarding flow wired — connect Cursor → GitHub → pin repo → biometrics → home
- [x] Unit/widget tests — database, auth repository, PKCE, QR parser, router updates
- [x] `flutter analyze` — 0 issues; **50 tests** passing after audit remediation

**Release:** `v0.2.0` (2026-06-22) — includes audit remediation

### Audit Remediation (2026-06-22) ✅

**Status:** Complete — tagged `v0.2.0`

- [x] iOS privacy strings (Face ID, camera)
- [x] Session re-validation via `GET /v1/me` on launch
- [x] GitHub OAuth `state` CSRF parameter
- [x] Widget tests for all Sprint 2 auth/onboarding screens
- [x] `ProjectRepository` for pin-repo persistence
- [x] **50 tests** passing in `apps/mobile`

See `AUDIT_REMEDIATION_REPORT.md` and `SPRINT2_FINAL_HANDOFF.md`.

### Sprint 3 — API Packages ✅

**Goal:** All four API packages implemented with unit tests; app can call Cursor and GitHub APIs.

**Status:** Complete (2026-06-22)

- [x] `cursor_api_core` — HTTP client, errors, `/v1/me`
- [x] `cursor_api_agents` — 11 operations, models, failure mapping
- [x] `cursor_api_stream` — SSE parser, logger, reconnection, run tracker
- [x] `github_api` — REST client, rate limiter, repository
- [x] Mobile auth wired to `cursor_api_core`
- [x] **126 tests** green (`melos run test`)

See `SPRINT3_COMPLETION_REPORT.md`.

**Next:** Sprint 4 — Core Chat

### v1.0.0 (planned)
- Initial release
- See Phase 3 Roadmap for epic breakdown
