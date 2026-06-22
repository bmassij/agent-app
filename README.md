# Cursor Mobile Commander

Native Flutter mobile client for managing Cursor Background Cloud Agents from your phone.

## Quick Start

```bash
# Prerequisites: Flutter 3.22+, melos 3.x
dart pub global activate melos

git clone https://github.com/bmassij/agent-app.git
cd agent-app
melos bootstrap

# Generate Android/iOS platform folders (first time only)
cd apps/mobile
flutter create . --org com.cursormobilecommander --project-name cursor_mobile_commander
cd ../..

melos run lint
melos run test
cd apps/mobile && flutter run
```

## Documentation

| Document | Purpose |
|---|---|
| [MASTER_BUILD_PLAN.md](MASTER_BUILD_PLAN.md) | Single source of truth for agents |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design |
| [docs/AGENT_GUIDE.md](docs/AGENT_GUIDE.md) | How to add features |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Sprint progress |
| [docs/IMPLEMENTATION_NOTES.md](docs/IMPLEMENTATION_NOTES.md) | Sprint handoff notes |

## Sprint Status

**Sprint 1 (Foundation):** Complete — app shell, navigation, theme, package scaffolds.

**Sprint 2 (Auth + Database):** Complete — Drift DB, API key setup, biometrics, GitHub OAuth PKCE, onboarding wired.

**Sprint 3 (API Packages):** Next — Cursor/GitHub API client packages.
