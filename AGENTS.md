# AGENTS.md

## Cursor Cloud specific instructions

This repo is **Cursor Mobile Commander**, a Flutter mobile app organised as a Melos
monorepo (`apps/mobile` + `packages/*`). See `README.md` / `melos.yaml` for the
standard commands; the notes below capture the cloud-environment specifics.

### Toolchain (already in the VM snapshot)

- Flutter SDK is installed at `~/flutter` (channel `stable`). Melos `6.3.2` is installed
  via `dart pub global activate melos` (the repo pins `melos ^6.3.2`, whose config lives
  in `melos.yaml`; do **not** use Melos 7/8, which moved config into `pubspec.yaml`).
- `~/.bashrc` adds Flutter, the bundled Dart SDK, and the pub-cache bin to `PATH`. In a
  non-login shell, export it first:
  `export PATH="$HOME/flutter/bin:$HOME/flutter/bin/cache/dart-sdk/bin:$HOME/.pub-cache/bin:$PATH"`
- `libsqlite3` is installed system-wide (`libsqlite3-dev`). It is **required** by the
  `drift`/`sqlite3` FFI database tests — without `libsqlite3.so`, the `app_database`
  tests fail with "Failed to load dynamic library 'libsqlite3.so'".

### How to run (from repo root)

- Bootstrap deps: `melos bootstrap` (the update script already does this on VM startup).
- Lint: `melos run lint` (`dart analyze`). Passes — only `info`-level
  `require_trailing_commas` hints remain in some test files.
- Tests: `melos run test` (`flutter test`). All app tests pass (58 in `apps/mobile`).
- Codegen: `melos run codegen` (build_runner for `drift`/`riverpod`). Only the drift
  `apps/mobile/lib/core/database/app_database.g.dart` is committed and is the single
  generated file referenced via `part`, so a fresh checkout lints/tests **without**
  re-running codegen. Run codegen only after editing drift tables or riverpod providers.
  If codegen fails with errors about `.dart_tool/build/entrypoint/build.dart`, the
  build cache is stale — delete `apps/mobile/.dart_tool` and re-run `flutter pub get`.

### Known limitations (pre-existing, not environment issues)

- **Android build (`melos run build-check` / `flutter build apk`) does not work** with
  the committed dependencies. `workmanager 0.5.2` only compiles against the removed
  Flutter v1 Android embedding (fails on Flutter ≥ 3.29), while the Dart code uses
  `DropdownButtonFormField(initialValue:)` which requires Flutter ≥ 3.32. No single
  Flutter version satisfies both, so the APK build needs a dependency/code change first.
- This is a **mobile-only** app: it cannot build for web (`drift`/`sqlite3` use
  `dart:ffi`), and the VM has no `/dev/kvm`, so an Android emulator cannot run here.
  Validate changes with `melos run lint` + `melos run test`.
