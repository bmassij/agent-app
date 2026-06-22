# Folder Structure
# Cursor Mobile Commander

---

## Root Layout

```
cursor_mobile_commander/
│
├── apps/
│   └── mobile/                    ← Flutter application (Android + iOS)
│
├── packages/
│   ├── cursor_api_core/           ← HTTP client, auth, error types
│   ├── cursor_api_agents/         ← Agent + Run CRUD operations
│   ├── cursor_api_stream/         ← SSE streaming parser
│   └── github_api/                ← GitHub REST + OAuth
│
├── docs/                          ← All project documentation
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── AGENT_GUIDE.md
│   ├── DEVELOPMENT_GUIDE.md
│   ├── API_GUIDE.md
│   ├── FOLDER_STRUCTURE.md        ← this file
│   ├── CONTRIBUTING.md
│   ├── SECURITY.md
│   └── ROADMAP.md
│
├── tools/                         ← Developer utility scripts
│   └── generate_key_qr.dart       ← QR code generator for API key transfer
│
├── .github/
│   └── workflows/
│       ├── lint.yml
│       ├── test.yml
│       ├── build-android.yml
│       └── build-ios.yml
│
├── melos.yaml                     ← Monorepo coordination (MANDATORY)
├── analysis_options.yaml          ← Shared lint rules
└── .gitignore
```

---

## Flutter App: apps/mobile/

```
apps/mobile/
│
├── lib/
│   ├── main.dart                  ← Entry point; ProviderScope; runApp
│   │
│   ├── app/                       ← Application-level setup
│   │   ├── app.dart               ← MaterialApp.router wrapper
│   │   ├── theme.dart             ← ThemeData (dark only)
│   │   ├── router.dart            ← GoRouter instance with auth guard
│   │   └── routes.dart            ← Route path string constants
│   │
│   ├── core/                      ← Cross-cutting utilities
│   │   ├── database/              ← Drift database
│   │   │   ├── app_database.dart  ← @DriftDatabase class
│   │   │   ├── tables/            ← One file per table
│   │   │   └── migrations/        ← One file per migration
│   │   ├── network/
│   │   │   └── connectivity_service.dart
│   │   ├── logging/
│   │   │   └── app_logger.dart
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart
│   │   └── extensions/            ← Dart extension methods
│   │
│   ├── features/                  ← Vertical feature modules
│   │   │
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   ├── auth_model.dart
│   │   │   │   └── auth_failure.dart
│   │   │   ├── presentation/
│   │   │   │   ├── key_setup_screen.dart
│   │   │   │   ├── biometric_screen.dart
│   │   │   │   ├── auth_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       └── qr_scanner_widget.dart
│   │   │   └── auth_module.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── connect_cursor_screen.dart
│   │   │   │   ├── connect_github_screen.dart
│   │   │   │   ├── pin_repo_screen.dart
│   │   │   │   ├── first_agent_screen.dart
│   │   │   │   └── onboarding_provider.dart
│   │   │   └── onboarding_module.dart
│   │   │
│   │   ├── projects/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── pinned_project_model.dart
│   │   │   │   └── project_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── dashboard_screen.dart
│   │   │   │   ├── project_detail_screen.dart
│   │   │   │   ├── add_project_screen.dart
│   │   │   │   ├── projects_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       └── project_card.dart
│   │   │   └── projects_module.dart
│   │   │
│   │   ├── agents/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── agent_model.dart
│   │   │   │   ├── run_model.dart
│   │   │   │   ├── agent_failure.dart
│   │   │   │   └── agent_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── agent_list_screen.dart
│   │   │   │   ├── agent_detail_screen.dart
│   │   │   │   ├── agents_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       └── agent_status_chip.dart
│   │   │   └── agents_module.dart
│   │   │
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── chat_message_model.dart
│   │   │   │   ├── tool_call_model.dart
│   │   │   │   └── chat_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── chat_screen.dart
│   │   │   │   ├── new_agent_sheet.dart
│   │   │   │   ├── template_picker_sheet.dart
│   │   │   │   ├── model_picker_sheet.dart
│   │   │   │   ├── options_sheet.dart
│   │   │   │   ├── chat_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── user_message_bubble.dart
│   │   │   │       ├── assistant_message_bubble.dart
│   │   │   │       ├── tool_call_chip.dart
│   │   │   │       ├── milestone_marker.dart
│   │   │   │       └── chat_composer.dart
│   │   │   └── chat_module.dart
│   │   │
│   │   ├── tasks/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── task_list_screen.dart
│   │   │   │   ├── run_logs_screen.dart
│   │   │   │   ├── tasks_provider.dart
│   │   │   │   └── widgets/
│   │   │   └── tasks_module.dart
│   │   │
│   │   ├── review/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── pull_request_model.dart
│   │   │   │   ├── diff_file_model.dart
│   │   │   │   └── review_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── pr_list_screen.dart
│   │   │   │   ├── pr_detail_screen.dart
│   │   │   │   ├── diff_viewer_screen.dart
│   │   │   │   ├── merge_confirm_sheet.dart
│   │   │   │   ├── review_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── pr_card.dart
│   │   │   │       ├── check_status_badge.dart
│   │   │   │       └── diff_file_tile.dart
│   │   │   └── review_module.dart
│   │   │
│   │   ├── github/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── repo_browser_screen.dart
│   │   │   │   ├── file_viewer_screen.dart
│   │   │   │   ├── commit_list_screen.dart
│   │   │   │   ├── github_provider.dart
│   │   │   │   └── widgets/
│   │   │   └── github_module.dart
│   │   │
│   │   ├── templates/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   │   ├── template_model.dart
│   │   │   │   └── template_repository.dart
│   │   │   ├── presentation/
│   │   │   │   ├── template_list_screen.dart
│   │   │   │   ├── template_editor_screen.dart
│   │   │   │   ├── templates_provider.dart
│   │   │   │   └── widgets/
│   │   │   └── templates_module.dart
│   │   │
│   │   ├── settings/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── key_manage_screen.dart
│   │   │   │   ├── settings_provider.dart
│   │   │   │   └── widgets/
│   │   │   └── settings_module.dart
│   │   │
│   │   └── notifications/         ← No screens; background service only
│   │       ├── background_poll_service.dart
│   │       ├── local_notification_service.dart
│   │       └── notifications_module.dart
│   │
│   └── shared/                    ← Shared UI components
│       ├── widgets/
│       │   ├── loading_spinner.dart
│       │   ├── error_view.dart
│       │   ├── offline_banner.dart
│       │   ├── app_bottom_nav.dart
│       │   └── syntax_highlighter.dart
│       └── constants/
│           ├── colors.dart
│           ├── durations.dart
│           └── sizes.dart
│
├── android/
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── res/xml/network_security_config.xml
│
├── ios/
│   └── Runner/
│       └── Info.plist
│
├── test/
│   ├── features/                  ← Mirror of lib/features/
│   ├── shared/
│   └── helpers/
│       ├── mock_cursor_api.dart
│       ├── mock_github_api.dart
│       └── in_memory_database.dart
│
└── pubspec.yaml
```

---

## Package Layout: packages/{package}/

All packages follow the same internal structure:

```
packages/{package_name}/
├── lib/
│   ├── {package_name}.dart        ← Public barrel export
│   └── src/
│       ├── models/                ← Response models
│       ├── errors/                ← Error types
│       └── {module}/              ← Implementation
├── test/
│   ├── src/
│   └── helpers/
└── pubspec.yaml
```

---

## Naming Rules (enforced in AGENT_GUIDE)

| Pattern | Example |
|---|---|
| `{feature}/domain/{feature}_model.dart` | `agents/domain/agent_model.dart` |
| `{feature}/domain/{feature}_repository.dart` | `agents/domain/agent_repository.dart` |
| `{feature}/domain/{feature}_failure.dart` | `agents/domain/agent_failure.dart` |
| `{feature}/data/{feature}_repository_impl.dart` | `agents/data/agent_repository_impl.dart` |
| `{feature}/presentation/{feature}_screen.dart` | `agents/presentation/agent_list_screen.dart` |
| `{feature}/presentation/{feature}_provider.dart` | `agents/presentation/agents_provider.dart` |
| `{feature}/{feature}_module.dart` | `agents/agents_module.dart` |

**Every feature follows this pattern. No exceptions.**
