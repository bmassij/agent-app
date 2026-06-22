# Development Guide
# Cursor Mobile Commander

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Flutter | 3.22+ | https://flutter.dev/docs/get-started/install |
| Dart | 3.4+ | (included with Flutter) |
| melos | 3.x | `dart pub global activate melos` |
| Android Studio / Xcode | Latest | For emulators |
| Node.js | 20+ | For tools/generate_key_qr script |

---

## First-Time Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-org/cursor-mobile-commander.git
cd cursor-mobile-commander

# 2. Install all packages across the monorepo
melos bootstrap

# 3. Generate Drift database code
melos run codegen

# 4. Verify everything builds
melos run build-check

# 5. Run all tests
melos run test
```

---

## melos Commands

| Command | What it does |
|---|---|
| `melos bootstrap` | `pub get` across all packages |
| `melos run test` | Run all tests across all packages |
| `melos run lint` | Run `dart analyze` across all packages |
| `melos run format` | Run `dart format` across all packages |
| `melos run codegen` | Run `build_runner` for Drift + Riverpod codegen |
| `melos run build-check` | `flutter build apk --debug` (quick build verify) |

---

## Running the App

```bash
cd apps/mobile

# Android emulator or device
flutter run

# iOS simulator
flutter run -d iPhone

# Specific device
flutter devices
flutter run -d <device-id>
```

---

## Environment Configuration

There is no `.env` file. All secrets are entered by the user at runtime and stored in OS keychain.

For development, use your own Cursor API key and a personal GitHub account.

```bash
# Generate QR code for easy key transfer to device
cd tools
dart run generate_key_qr.dart --key=YOUR_CURSOR_API_KEY
# Scan the printed QR code in the app
```

---

## Project Structure

```
cursor_mobile_commander/
├── apps/
│   └── mobile/
│       ├── lib/
│       │   ├── main.dart          ← entry point
│       │   ├── app/               ← theme, router, DI
│       │   │   ├── theme.dart
│       │   │   ├── router.dart
│       │   │   └── routes.dart
│       │   ├── core/              ← app-wide utilities
│       │   │   ├── database/      ← Drift database
│       │   │   ├── network/       ← connectivity service
│       │   │   ├── logging/       ← AppLogger
│       │   │   └── extensions/    ← Dart extensions
│       │   ├── features/          ← vertical feature modules
│       │   └── shared/            ← shared widgets, constants
│       ├── android/
│       ├── ios/
│       └── test/
├── packages/
│   ├── cursor_api_core/
│   ├── cursor_api_agents/
│   ├── cursor_api_stream/
│   └── github_api/
├── docs/
├── tools/
└── melos.yaml
```

---

## Coding Conventions

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) strictly
- `dart format` is enforced in CI — no style discussions
- Max line length: 100 characters

### Import Order

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:riverpod/riverpod.dart';

// 4. Internal packages
import 'package:cursor_api_agents/cursor_api_agents.dart';

// 5. App-local
import '../../../core/database/app_database.dart';
```

### Widget Rules

- Use `ConsumerWidget` for widgets that read providers
- Use `StatelessWidget` for pure presentational widgets
- Never use `StatefulWidget` unless managing animation controllers or focus nodes
- Never call `ref.read` inside `build` — use `ref.watch`

### Error Handling

- All repository methods return `Either<Failure, Success>` (using `dartz` or `fpdart`)
- Never throw exceptions from repository layer — map to typed failures
- UI always handles the `Left` (failure) case

### Async Patterns

```dart
// Correct: watch async data
final asyncValue = ref.watch(agentListProvider);
return asyncValue.when(
  data: (agents) => AgentList(agents: agents),
  loading: () => const LoadingSpinner(),
  error: (err, _) => ErrorView(failure: err as AgentFailure),
);
```

---

## Testing

### Running Tests

```bash
# All tests
melos run test

# Single package
cd packages/cursor_api_stream && flutter test

# Single file
cd apps/mobile && flutter test test/features/chat/chat_provider_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Structure

```
packages/{package_name}/
└── test/
    ├── src/
    │   └── {module}_test.dart
    └── helpers/
        └── mock_http_client.dart

apps/mobile/
└── test/
    └── features/
        └── {feature}/
            ├── domain/{model}_test.dart
            ├── data/{repository_impl}_test.dart
            └── presentation/{provider}_test.dart
```

### Mocking Policy

- Use `mocktail` for mocking (not `mockito`)
- Never mock `flutter_secure_storage` in unit tests — use the in-memory implementation
- Never mock the Drift database — use an in-memory SQLite database

---

## Branching Strategy

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full branching and PR strategy.

Short version:
- `main` — production; protected; requires PR
- `develop` — integration branch; requires PR
- `feat/{ticket-id}-{short-description}` — feature branches
- `fix/{ticket-id}-{short-description}` — bug fix branches
- `chore/{description}` — maintenance

---

## Common Issues

**`melos run codegen` fails with "build_runner not found"**
→ Run `melos bootstrap` first

**iOS build fails with "No signing certificate"**
→ Open `apps/mobile/ios` in Xcode; configure signing with your Apple account

**`flutter_secure_storage` returns null on emulator**
→ On Android emulator, secure storage requires API 23+. Use API 26+ emulator.

**SSE stream disconnects immediately on device**
→ Check network security config — strict TLS may block connections on older OS versions during development. Use debug build without pinning.
