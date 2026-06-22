# Phase 3 — Production Roadmap
# Cursor Mobile Commander
# Author: CTO
# Date: 2026-06-22

---

## Complexity Scale
- XS = 1-2 hours
- S  = 2-4 hours
- M  = 4-8 hours (1 day)
- L  = 1-2 days
- XL = 3-5 days

---

## EPIC 1 — Foundation & Infrastructure
**Goal:** Runnable app skeleton with auth, navigation, and data layer
**Order:** First — everything else depends on this

### Feature 1.1 — Monorepo Setup
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Scaffold monorepo | Create folder structure per FOLDER_STRUCTURE.md; init melos.yaml; add .gitignore, .editorconfig | S | None |
| Configure melos | Define scripts: `test`, `lint`, `build`, `pub-get` across all packages | XS | Monorepo scaffold |
| Setup analysis_options | Strict lints: `flutter_lints` + `prefer_final_locals`, `avoid_dynamic_calls`, `always_declare_return_types` | XS | Monorepo scaffold |
| Configure dart format | Add `dart format` as pre-commit hook via `lefthook` | XS | Monorepo scaffold |

### Feature 1.2 — App Shell
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Create Flutter app | `flutter create apps/mobile`; configure app id `com.cursormobilecommander.app` | XS | Monorepo setup |
| Setup go_router | Define full route tree per PHASE2; add auth guard redirect | M | Flutter app |
| Setup Riverpod | Add `ProviderScope` at root; configure `riverpod_lint` | XS | Flutter app |
| Setup theme | Dark theme: #0D0D0D background, #1A1A1A card, #00B4D8 accent, typography scale | M | Flutter app |
| Setup bottom navigation | 3 tabs: Projects, Agents, Settings; goRouter shell route | S | go_router, theme |

### Feature 1.3 — Drift Database
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Create database class | Define all tables per Phase 2 data architecture | M | Flutter app |
| Write migration 0001 | Initial schema SQL | S | Database class |
| Configure Drift codegen | Add build_runner; generate database code | S | Database class |
| Create database provider | Singleton Riverpod provider; lazy init | XS | Database class |

### Feature 1.4 — Cursor API Core Package
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Create package scaffold | `packages/cursor_api_core`; pubspec, lib/, test/ | XS | Monorepo |
| Implement CursorHttpClient | dio-based; Bearer auth injection; timeout config | S | Package scaffold |
| Implement error types | `CursorApiError` sealed class; all variants per Phase 2 | S | CursorHttpClient |
| Unit test error parsing | Test all HTTP status codes map to correct error types | S | Error types |

### Feature 1.5 — GitHub API Package
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Create package scaffold | `packages/github_api`; pubspec, lib/, test/ | XS | Monorepo |
| Implement GithubHttpClient | dio-based; Bearer auth; rate limit header parsing | S | Package scaffold |
| Implement GithubRateLimiter | Parse X-RateLimit-* headers; throw RateLimitFailure | S | GithubHttpClient |
| Unit test rate limiter | Test limit detection and error propagation | S | GithubRateLimiter |

---

## EPIC 2 — Authentication & Onboarding
**Goal:** User can set up API key, connect GitHub, pin a repo, run first agent
**Order:** After Epic 1

### Feature 2.1 — Cursor API Key Auth
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement SecureStorageService | flutter_secure_storage wrapper; read/write/delete key | S | Epic 1 |
| Build KeySetupScreen | Text field for paste; QR scan button; validate on submit via GET /v1/me | M | SecureStorageService |
| Implement QR scanner | mobile_scanner integration; parse `cursormc://auth?key=` URI | M | KeySetupScreen |
| Implement biometric gate | local_auth challenge on app resume; fallback to PIN | M | SecureStorageService |
| Auto-lock on idle | WidgetsBindingObserver; lock after configurable timeout | S | Biometric gate |

### Feature 2.2 — GitHub OAuth
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Register GitHub OAuth App | Document: Settings → Developer settings → OAuth Apps; callback URI `cursormc://oauth/callback` | XS (docs) | None |
| Implement PKCE flow | Generate verifier; compute challenge; open auth URL; handle callback | L | SecureStorageService |
| Store GitHub token | Write to flutter_secure_storage; handle refresh | S | PKCE flow |
| ConnectGitHubScreen | UI for auth button; success/error states | S | PKCE flow |

### Feature 2.3 — Onboarding Flow
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| WelcomeScreen | Explain app purpose; "Get Started" CTA | S | App shell |
| OnboardingNavigator | Step-based flow with progress indicator; skip for returning users | M | go_router |
| PinRepoScreen | Search GitHub repos; manual URL entry; pin first repo | M | GitHub API |
| FirstAgentScreen | Guided first-agent creation with pre-filled template | M | Chat feature |

---

## EPIC 3 — Core Chat (Agent Communication)
**Goal:** Create agent, stream response, send follow-ups, cancel, see history
**Order:** After Epic 2 — this is the core value proposition

### Feature 3.1 — Cursor Agents Package
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement AgentRepository interface | Define all methods: list, get, create, listRuns, getRun, createRun, cancel, usage, artifacts, models, repos | S | cursor_api_core |
| Implement AgentRepositoryImpl | Wire all methods to HTTP calls; map errors to CursorApiError | L | Interface |
| Unit test all CRUD operations | Mock HTTP; test happy path + all error codes | L | Impl |

### Feature 3.2 — SSE Streaming Package
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement SseParser | Pure Dart; parse SSE format; emit typed SseEvent sealed class | L | None (pure Dart) |
| Unit test SseParser | Test all event types; partial chunks; UTF-8 edge cases; empty lines | L | SseParser |
| Implement RunStreamService | dart:io HttpClient stream; Last-Event-ID; reconnection with exponential backoff | XL | SseParser |
| Integration test streaming | Test against mock SSE server (via shelf package) | L | RunStreamService |
| Implement ReconnectionManager | State machine: connected→disconnected→reconnecting→connected | M | RunStreamService |

### Feature 3.3 — Chat UI
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build ChatScreen scaffold | ListView.builder for messages; bottom composer; loading states | M | Epic 2 |
| Build message bubble widgets | User bubble (right); Assistant bubble (left with avatar); role-based styling | M | Theme |
| Build tool call chip widget | Expandable; tool name; status indicator; collapsible args/result | L | Theme |
| Build milestone marker widget | "Branch pushed", "PR opened", "Build passed" — inline in chat | M | Theme |
| Build composer widget | TextFormField; send button; mic button; attach button; disabled states | M | Theme |
| Implement chat provider | `agentChatProvider(agentId)` AsyncNotifierProvider.family; load + stream | L | Agents package, SSE package |
| Persist SSE events to SQLite | On each SseEvent: write ChatMessage + ToolCallLog to Drift | M | Drift |
| Load history from SQLite | On ChatScreen open: query all ChatMessage for agentId; render before SSE | S | Drift |

### Feature 3.4 — Agent Creation
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build NewAgentSheet | Prompt input; template picker; model picker; mode toggle; options (autoCreatePR, branch) | L | Theme, templates |
| Implement model picker | GET /v1/models; dropdown with model descriptions | M | Agents package |
| Implement createAgent use case | POST /v1/agents; save AgentSession + RunRecord; navigate to chat | M | Agents package |

### Feature 3.5 — Follow-up & Cancel
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement follow-up send | POST /v1/agents/{id}/runs; handle 409 AgentBusy (disable send until terminal) | M | Chat provider |
| Implement cancel | POST /v1/agents/{id}/runs/{runId}/cancel; update UI to CANCELLED state | S | Chat provider |
| Implement run status polling | Fallback poll every 10s when SSE disconnected | M | Chat provider |

### Feature 3.6 — Usage & Artifacts
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Fetch and display token usage | GET /v1/agents/{id}/usage on run complete; show in RunLogsScreen | S | Agents package |
| List artifacts | GET /v1/agents/{id}/artifacts; show thumbnails in chat; tap to download | M | Agents package |

---

## EPIC 4 — Projects Dashboard
**Goal:** Manage multiple pinned repos; see active agents per project
**Order:** After Epic 3

### Feature 4.1 — Project Management
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build DashboardScreen | Grid/list of pinned project cards | M | Epic 2 |
| Build ProjectCard widget | Repo name; active agent count; open PRs; last activity | M | Theme |
| Build AddProjectScreen | Search GitHub repos (GET /user/repos); manual URL; pin | M | GitHub API |
| Implement project CRUD | Create/delete/reorder pinned projects in Drift | S | Drift |
| Build ProjectDetailScreen | Agent list for project; PR list; CI status; file browser entry point | L | Epic 3, GitHub |

### Feature 4.2 — Dashboard Polling
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement dashboard refresh provider | Poll /v1/agents every 30s when screen visible; pause on background | M | Agents package |
| AppLifecycle management | WidgetsBindingObserver; pause/resume polling on foreground/background | S | Dashboard provider |

---

## EPIC 5 — GitHub Integration
**Goal:** View repos, browse files, review PRs, merge, track CI
**Order:** After Epic 4

### Feature 5.1 — Repository Browser
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build RepoBrowserScreen | Non-recursive file tree; expand folder on tap; breadcrumb nav | L | GitHub API |
| Build FileViewerScreen | Syntax-highlighted file content (flutter_highlight); read-only | M | GitHub API |
| Build CommitListScreen | Paginated commit history; SHA, message, author, date | M | GitHub API |

### Feature 5.2 — PR Review Flow
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build PRListScreen | Open PRs for project; status badges; agent-created vs human | M | GitHub API |
| Build PRDetailScreen | Title, description, checks status, branch info; merge button | L | GitHub API |
| Build DiffViewerScreen | Unified diff; syntax highlighted; file pagination (max 100 files); tap file to jump | XL | GitHub API |
| Build MergeConfirmSheet | Merge method picker; SHA confirmation; warning if checks failing | M | GitHub API |
| Implement merge + branch delete | PUT /pulls/{n}/merge; DELETE /git/refs/heads/{branch} | M | GitHub API |
| Implement PR review submit | POST /pulls/{n}/reviews; APPROVE / REQUEST_CHANGES / COMMENT | M | GitHub API |

### Feature 5.3 — CI Status
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Fetch check runs for PR | GET /repos/{o}/{r}/commits/{sha}/check-runs; show pass/fail/pending | M | GitHub API |
| Show CI status on dashboard | Latest commit check status per project card | S | GitHub API |

---

## EPIC 6 — Templates & Productivity
**Goal:** Prompt templates, search, export
**Order:** After Epic 3

### Feature 6.1 — Command Templates
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Define template data model | TemplateModel: id, name, description, promptTemplate, variables[] | S | Drift |
| Seed built-in templates | 8 templates per Phase 2 design document | S | Template model |
| Build TemplateListScreen | List with search; built-in vs custom badge | M | Drift |
| Build TemplateEditorScreen | Name, description, prompt with {variable} highlighting; save | L | Drift |
| Build TemplatePickerSheet | Triggered from chat composer; select → pre-fill composer | M | Chat UI |
| Implement variable substitution | Parse {variable} tokens; show input sheet before send | M | Templates |

### Feature 6.2 — Search
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Implement agent search | Search AgentSession.name; filter by project; filter by status | M | Drift |
| Implement message search | Full-text search across ChatMessage.content (SQLite FTS5) | L | Drift |

### Feature 6.3 — Export
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Export conversation as Markdown | Generate .md from ChatMessage rows; share_plus | M | Drift |
| Copy agent result to clipboard | Long-press on assistant bubble → copy | XS | Chat UI |

---

## EPIC 7 — Offline & Background
**Goal:** Background notifications, offline queue, reliable connectivity handling
**Order:** After Epic 3

### Feature 7.1 — Background Polling Service
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Setup WorkManager (Android) | workmanager package; register periodic task; handle Dart isolate init | L | Epic 1 |
| Setup BGTaskScheduler (iOS) | flutter_background_fetch or similar; register task identifier | L | Epic 1 |
| Implement background poll task | GET active runs; detect completion; write to SQLite | M | Agents package, Drift |
| Implement local notifications | flutter_local_notifications; permission request; notification on completion | M | WorkManager |

### Feature 7.2 — Offline Queue
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build ConnectivityService | connectivity_plus stream; expose isOnline bool stream | S | Epic 1 |
| Implement QueuedPromptService | Write to QueuedPrompt table when offline; process on reconnect | M | ConnectivityService, Drift |
| Build offline banner widget | AnimatedContainer banner: "Offline — prompts will be queued" | S | ConnectivityService |

---

## EPIC 8 — Settings & Security Hardening
**Goal:** Full settings, security hardening, polish
**Order:** After Epic 7

### Feature 8.1 — Settings
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Build SettingsScreen | API key management; GitHub connect/disconnect; poll interval; auto-lock timeout; dark mode (always on) | M | Epic 2 |
| Implement key rotation | Delete old key; prompt for new key; re-validate | S | Auth feature |
| Implement GitHub disconnect | Delete token; clear GitHub cache; return to onboarding step | S | Auth feature |

### Feature 8.2 — Security Hardening
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Add FLAG_SECURE (Android) | Prevent screenshots/screen recording of app content | S | Epic 1 |
| Add iOS content blur on background | Blur app content in app switcher | S | Epic 1 |
| Add certificate pinning | Pin api.cursor.com and api.github.com public keys | M | Epic 1 |
| Add jailbreak/root detection | flutter_jailbreak_detection; show warning (not block) | S | Epic 1 |
| Disable Android backup | android:allowBackup="false" in manifest | XS | Epic 1 |

---

## EPIC 9 — CI/CD & Release
**Goal:** Automated testing, release pipeline, app store submission
**Order:** After Epic 8

### Feature 9.1 — CI Pipeline (GitHub Actions)
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Lint workflow | `dart analyze` + `dart format --check` on PR | S | Epic 1 |
| Test workflow | `melos run test`; upload coverage to Codecov | M | Epic 1 |
| Build workflow (Android) | `flutter build apk --release`; verify no build errors | M | Epic 1 |
| Build workflow (iOS) | `flutter build ipa`; requires macOS runner | M | Epic 1 |

### Feature 9.2 — Android Release
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| Configure signing | keystore; key.properties; Gradle signing config | M | Epic 9.1 |
| Configure ProGuard | rules for Drift, dio, flutter_secure_storage | M | Signing |
| Play Store submission | Create store listing; screenshots; privacy policy | L | All Epics |

### Feature 9.3 — iOS Release
| Task | Subtasks | Complexity | Dependencies |
|---|---|---|---|
| iOS permissions | NSMicrophoneUsageDescription; NSCameraUsageDescription; NSFaceIDUsageDescription | S | iOS build |
| TestFlight submission | Archive; upload; add testers | M | iOS build |
| App Store submission | Store listing; review submission | L | TestFlight |

---

## Implementation Order Summary

```
Week 1: Epic 1 (Foundation) + Epic 2 (Auth/Onboarding)
Week 2: Epic 3 (Core Chat) — SSE + agent CRUD + chat UI
Week 3: Epic 4 (Dashboard) + Epic 5.1 (Repo Browser)
Week 4: Epic 5.2 (PR Review + Merge)
Week 5: Epic 6 (Templates) + Epic 7 (Offline/Background)
Week 6: Epic 8 (Security/Settings) + Epic 9 (CI/CD + Release)
```

---

## Total Complexity Estimate

| Epic | Complexity (story points) |
|---|---|
| Epic 1 — Foundation | ~20 pts |
| Epic 2 — Auth/Onboarding | ~25 pts |
| Epic 3 — Core Chat | ~60 pts |
| Epic 4 — Dashboard | ~25 pts |
| Epic 5 — GitHub | ~50 pts |
| Epic 6 — Templates | ~25 pts |
| Epic 7 — Offline/BG | ~30 pts |
| Epic 8 — Security | ~20 pts |
| Epic 9 — CI/Release | ~25 pts |
| **Total** | **~280 pts** |

At 1 Cursor Agent = ~20-40 pts/week (with human review): **8-12 weeks to v1.0**
