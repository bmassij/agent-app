# Phase 5 — GitHub Repository Design
# Cursor Mobile Commander

---

## Repository Name

```
cursor-mobile-commander
```

GitHub URL: `https://github.com/{owner}/cursor-mobile-commander`

---

## Monorepo Structure

The repository is a **Dart/Flutter monorepo** managed by melos. All packages and the app live in a single repository for:
- Atomic commits across app + packages
- Single CI pipeline
- Easier Cursor Agent context window (one repo = full picture)
- Simpler dependency management

---

## Complete Folder Structure

See [FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) for full details.

Top-level:
```
cursor-mobile-commander/
├── apps/mobile/           ← Flutter app
├── packages/              ← Shared Dart packages
├── docs/                  ← All documentation
├── tools/                 ← Dev utilities
├── .github/               ← CI/CD workflows
├── melos.yaml
├── analysis_options.yaml
└── .gitignore
```

---

## Package Naming Conventions

| Package | pub.dev name (internal) | Purpose |
|---|---|---|
| `packages/cursor_api_core` | `cursor_api_core` | HTTP, auth, errors |
| `packages/cursor_api_agents` | `cursor_api_agents` | Agent CRUD |
| `packages/cursor_api_stream` | `cursor_api_stream` | SSE streaming |
| `packages/github_api` | `github_api` | GitHub REST |

All packages are private (not published to pub.dev). Referenced via `path:` in pubspec.yaml.

---

## melos.yaml Configuration

```yaml
name: cursor_mobile_commander

packages:
  - apps/mobile
  - packages/**

scripts:
  test:
    run: melos exec -- flutter test
    description: Run tests in all packages

  lint:
    run: melos exec -- dart analyze
    description: Lint all packages

  format:
    run: melos exec -- dart format .
    description: Format all packages

  format-check:
    run: melos exec -- dart format --output=none --set-exit-if-changed .
    description: Check formatting (CI)

  codegen:
    run: melos exec --depends-on=build_runner -- flutter pub run build_runner build --delete-conflicting-outputs
    description: Run code generation

  build-check:
    run: |
      cd apps/mobile
      flutter build apk --debug
    description: Verify Android debug build

  clean:
    run: melos exec -- flutter clean
    description: Clean all packages
```

---

## analysis_options.yaml (Root)

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    missing_return: error
    dead_code: warning
    unused_import: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls
    - avoid_print
    - prefer_final_locals
    - prefer_const_constructors
    - prefer_const_declarations
    - require_trailing_commas
    - sort_pub_dependencies
    - use_super_parameters
    - always_use_package_imports
```

---

## .gitignore

```gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
*.iml
build/
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# Dart
.pub/
pubspec.lock    ← tracked for app; ignored for packages

# Android signing
*.jks
*.keystore
key.properties

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Runner/GeneratedPluginRegistrant.*

# Secrets — NEVER commit these
.env
*.env
cursor_api_key.txt

# Generated files (not ignored — commit generated code)
# *.g.dart → committed
# *.freezed.dart → committed

# IDE
.idea/
.vscode/settings.json
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
```

---

## Naming Conventions

### Dart Files
- All lowercase snake_case: `agent_chat_screen.dart`
- Never PascalCase filenames
- Never abbreviations: `authentication_repository.dart` not `auth_repo.dart`
  - Exception: `auth` is an accepted short form for authentication module

### Dart Classes
- PascalCase: `AgentChatScreen`, `RunStreamService`
- Suffixes are mandatory (see AGENT_GUIDE.md):
  - Screens: `*Screen`
  - Repositories: `*Repository`, `*RepositoryImpl`
  - Models: `*Model`
  - Failures: `*Failure`
  - Providers: `*Provider` (the variable, not the class)
  - Services: `*Service`

### Branch Names
- Feature: `feat/{ticket-id}-{kebab-description}`
- Fix: `fix/{ticket-id}-{kebab-description}`
- Chore: `chore/{kebab-description}`
- Release: `release/{semver}`
- Hotfix: `hotfix/{semver}`

### Commit Messages
Format: `{type}({scope}): {description in imperative mood}`
- `feat(chat): add tool call chip widget`
- `fix(sse): resume stream with Last-Event-ID after 410`
- `chore(deps): upgrade riverpod to 2.5.0`

### PR Titles
Same format as commit messages. PR title becomes the squash commit message.

### Tag Names
- `v{semver}` — release tags (e.g., `v1.0.0`, `v1.2.3`)
- `v{semver}-rc.{n}` — release candidates

---

## GitHub Branch Protection Rules

### `main`
- Require PR before merging
- Require 1 approving review (human)
- Dismiss stale reviews on new push
- Require status checks: `lint`, `test`, `build-android`
- No direct pushes (including admins)
- Require linear history (squash merges only)

### `develop`
- Require PR before merging
- Require 1 approving review
- Require status checks: `lint`, `test`
- Allow squash merges

---

## GitHub Actions Workflows

### `.github/workflows/lint.yml`
```yaml
name: Lint
on: [pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.22.x' }
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run lint
      - run: melos run format-check
```

### `.github/workflows/test.yml`
```yaml
name: Test
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.22.x' }
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run codegen
      - run: melos run test
      - uses: codecov/codecov-action@v4
```

### `.github/workflows/build-android.yml`
```yaml
name: Build Android
on: [pull_request, push]
  branches: [main, develop]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run codegen
      - run: cd apps/mobile && flutter build apk --release
        env:
          KEY_STORE_PASSWORD: ${{ secrets.KEY_STORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PATH: ${{ secrets.KEY_PATH }}
```

### `.github/workflows/build-ios.yml`
```yaml
name: Build iOS
on: [push]
  branches: [main]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: dart pub global activate melos
      - run: melos bootstrap
      - run: melos run codegen
      - run: cd apps/mobile && flutter build ipa --release
```

---

## GitHub Repository Settings

### General
- Default branch: `develop`
- Allow squash merges: ✅ (only merge method allowed)
- Allow merge commits: ❌
- Allow rebase merges: ❌
- Automatically delete head branches: ✅

### Secrets (GitHub Actions)
```
KEY_STORE_PASSWORD   ← Android keystore password
KEY_PASSWORD         ← Android key password
KEY_ALIAS            ← Android key alias
KEY_PATH             ← Android keystore file path
CODECOV_TOKEN        ← Codecov upload token
```

### Labels
```
agent-created        ← PR created by Cursor Agent
needs-human-review   ← Requires human reviewer
size: small          ← <100 lines changed
size: medium         ← 100-500 lines changed
size: large          ← >500 lines changed
security             ← Security-sensitive change
breaking             ← Breaking API change
```

---

## Cursor Agent Working Rules in This Repository

1. Always branch from `develop`, not `main`
2. Always PR to `develop`, not `main`
3. Always run `melos run lint && melos run test` before opening a PR
4. Never force-push any branch that already has a PR
5. Never commit `*.keystore`, `.env`, or `key.properties`
6. Follow the commit message format — CI will eventually enforce this
7. Use labels: always add `agent-created` + `needs-human-review` + appropriate size label

---

## Release Checklist

Before merging a release PR to `main`:
- [ ] Version bumped in `apps/mobile/pubspec.yaml`
- [ ] ROADMAP.md updated with release notes
- [ ] All CI checks green
- [ ] Human reviewed and approved
- [ ] Certificate pinning expiration checked (> 30 days remaining)
- [ ] `flutter build apk --release` succeeds locally
- [ ] `flutter build ipa --release` succeeds on macOS
