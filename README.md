# Aivance Core

**Aivance Core** is the technical foundation of the [Aivance](docs/vision/AIVANCE_MASTER_VISION.md) platform — a Flutter/Dart monorepo for delegating digital work from mobile and desktop clients.

Formerly known as *Cursor Mobile Commander*, Core provides workspace connection, task delegation, real-time monitoring, and GitHub integration while keeping execution provider details invisible to end users.

## Quick Start

```bash
# Prerequisites: Flutter 3.22+, melos 3.x
dart pub global activate melos

git clone https://github.com/bmassij/agent-app.git
cd agent-app/cursor-mobile-commander
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
| [AIVANCE_MASTER_VISION.md](docs/vision/AIVANCE_MASTER_VISION.md) | Platform vision and product philosophy |
| [AIVANCE_ARCHITECTURE.md](docs/architecture/AIVANCE_ARCHITECTURE.md) | System design |
| [AIVANCE_DEVELOPMENT_GUIDE.md](docs/development/AIVANCE_DEVELOPMENT_GUIDE.md) | Binding rules for contributors |
| [AIVANCE_CORE_MIGRATION_PLAN.md](docs/architecture/AIVANCE_CORE_MIGRATION_PLAN.md) | CMC → Aivance Core migration phases |
| [ARCHITECTURE_AUDIT.md](docs/ARCHITECTURE_AUDIT.md) | Immutable baseline audit (2026-06-25) |
| [FEATURE_STATUS.md](docs/FEATURE_STATUS.md) | Living feature status vs code |

## Migration Status

| Phase | Status |
|-------|--------|
| **M1** Terminology & branding | Complete |
| M2 Package cleanup & hardening | Planned |
| M3 Provider abstraction | Planned |

See [docs/operations/M1_COMPLETION_REPORT.md](docs/operations/M1_COMPLETION_REPORT.md) for M1 details.

## Sprint Status (legacy)

Core functionality from Sprint 1–4 remains operational: auth, onboarding, workers/tasks, chat SSE, orchestrator dispatch, GitHub OAuth, Drift persistence.
