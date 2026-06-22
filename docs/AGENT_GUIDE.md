# Agent Guide
# Cursor Mobile Commander
# FOR: Cursor Background Agents maintaining this project

---

## READ THIS FIRST

You are a Cursor Background Agent. This guide tells you exactly how to work in this codebase without breaking things. Follow these rules strictly. When in doubt, do less and ask in your PR description.

---

## Project Structure (Quick Reference)

```
apps/mobile/lib/
  app/           ← theme, router, DI setup — rarely touch this
  core/          ← shared utilities, error base classes, extensions
  features/      ← ALL new features go here (one folder per feature)
  shared/        ← shared widgets used by more than one feature

packages/
  cursor_api_core/    ← HTTP client and error types
  cursor_api_agents/  ← Agent + Run operations
  cursor_api_stream/  ← SSE streaming
  github_api/         ← GitHub REST
```

---

## How to Add a New Feature

Follow these steps exactly, in this order.

**Step 1: Create the feature folder**
```
apps/mobile/lib/features/{feature_name}/
├── data/
├── domain/
├── presentation/
│   └── widgets/
└── {feature_name}_module.dart
```

**Step 2: Write the domain model**
```dart
// domain/{feature_name}_model.dart
// Use freezed or plain immutable class
// All fields final, no nulls unless the API genuinely returns null
@immutable
class FeatureModel {
  const FeatureModel({required this.id, required this.name});
  final String id;
  final String name;
}
```

**Step 3: Write the domain failure**
```dart
// domain/{feature_name}_failure.dart
sealed class FeatureFailure {
  const FeatureFailure();
}
class FeatureNotFound extends FeatureFailure { const FeatureNotFound(); }
class FeatureUnauthorized extends FeatureFailure { const FeatureUnauthorized(); }
```

**Step 4: Write the repository interface**
```dart
// domain/{feature_name}_repository.dart
abstract interface class FeatureRepository {
  Future<Either<FeatureFailure, FeatureModel>> getFeature(String id);
}
```

**Step 5: Write the repository implementation**
```dart
// data/{feature_name}_repository_impl.dart
// Call the remote source; map CursorApiError to FeatureFailure
```

**Step 6: Write the Riverpod provider**
```dart
// presentation/{feature_name}_provider.dart
// Use AsyncNotifierProvider for server data
// Use NotifierProvider for UI state
```

**Step 7: Write the screen**
```dart
// presentation/{feature_name}_screen.dart
// ConsumerWidget only — no StatefulWidget unless strictly needed
// Zero business logic in the widget
```

**Step 8: Export from barrel file**
```dart
// {feature_name}_module.dart
export 'domain/{feature_name}_model.dart';
export 'domain/{feature_name}_repository.dart';
export 'presentation/{feature_name}_screen.dart';
export 'presentation/{feature_name}_provider.dart';
```

**Step 9: Add route to router.dart**
```dart
// apps/mobile/lib/app/router.dart
// Add route under correct parent
// Add route path constant to routes.dart
```

**Step 10: Write tests**
```
test/features/{feature_name}/
├── domain/{feature_name}_model_test.dart
├── data/{feature_name}_repository_impl_test.dart
└── presentation/{feature_name}_provider_test.dart
```

---

## How to Add a New API Endpoint

**For Cursor API:**
1. Add method to `AgentRepository` interface in `packages/cursor_api_agents/lib/src/agent_repository.dart`
2. Implement in `AgentRepositoryImpl`
3. Add response model in `packages/cursor_api_agents/lib/src/models/`
4. Add error mapping in `AgentRepositoryImpl`
5. Write unit test with mocked HTTP response

**For GitHub API:**
1. Add method to `GithubRepository` interface
2. Implement in `GithubRepositoryImpl`
3. Ensure rate limit headers are parsed (already handled by `GithubHttpClient`)
4. Write unit test

---

## How to Add a New Drift Table

1. Add table class to `apps/mobile/lib/core/database/tables/`
2. Add table to `AppDatabase` class: `@DriftDatabase(tables: [... YourNewTable])`
3. Run: `melos run codegen`
4. Create migration file: `apps/mobile/lib/core/database/migrations/000X_add_{table}.dart`
5. Register migration in `AppDatabase.migration`
6. Write migration test

---

## How to Add a New Screen

1. Create `{screen_name}_screen.dart` in the appropriate feature's `presentation/` folder
2. Use `ConsumerWidget` (not `StatefulWidget`)
3. Add route in `router.dart`
4. Add route path constant in `routes.dart`
5. Widget test required

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Files | snake_case | `agent_chat_screen.dart` |
| Classes | PascalCase | `AgentChatScreen` |
| Variables | camelCase | `agentId` |
| Constants | camelCase (k prefix optional) | `defaultPollInterval` |
| Route paths | kebab-case strings | `/agents/:agentId/chat` |
| Providers | camelCase + "Provider" suffix | `agentChatProvider` |
| Repositories | PascalCase + "Repository" suffix | `AgentRepository` |
| Models | PascalCase + "Model" suffix | `AgentModel` |
| Failures | PascalCase + "Failure" suffix | `AgentBusyFailure` |
| Test files | same name + `_test.dart` | `agent_chat_screen_test.dart` |

---

## What NOT to Do

- **Never** put business logic in a widget. Move it to a provider or use case.
- **Never** call HTTP from a widget or provider directly. Use the repository.
- **Never** store a Cursor API key in SQLite, logs, print statements, or analytics.
- **Never** use `dynamic` — use typed models.
- **Never** use `BuildContext` across async gaps without checking `mounted`.
- **Never** add a new package without documenting why in the PR description.
- **Never** modify a Drift migration after it has been merged to main.
- **Never** add a `print()` statement — use the `AppLogger` in `core/`.
- **Never** skip writing tests for a new feature.
- **Never** add a route without a corresponding route path constant.

---

## Testing Requirements

Every PR must include:
- Unit tests for all new domain models and repository implementations
- Widget test for any new screen
- Provider test for any new Riverpod provider

Run all tests before submitting:
```bash
melos run test
```

Expected: all tests pass, no lint warnings.

---

## PR Description Template

Your PR description must include:

```
## What this PR does
[One paragraph description]

## Files changed
[List the key files and why]

## API calls made
[List any new Cursor or GitHub API calls]

## Tests added
[List test files added]

## Known limitations
[Any known issues or follow-up needed]

## Schema changes
[Any Drift schema changes and migration files]
```

---

## Asking for Help

If you are unsure about a design decision, leave a comment in the PR description:
```
// AGENT_QUESTION: [your question here]
```
A human reviewer will answer before merging.

---

## Emergency Stop

If you detect that a task requires:
- Deleting a Drift table
- Changing auth/key storage logic
- Modifying certificate pinning config
- Changing merge workflow in GithubRepository

→ Stop, do not implement. Leave a PR comment: `// AGENT_ESCALATE: [reason]`
