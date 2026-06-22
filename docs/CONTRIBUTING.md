# Contributing
# Cursor Mobile Commander

This project is maintained primarily by **Cursor Background Agents**, with human review on all merges.

---

## Branching Strategy

### Branch Types

| Branch | Purpose | Protected |
|---|---|---|
| `main` | Production releases | Yes — no direct push |
| `develop` | Integration branch | Yes — no direct push |
| `feat/{ticket}-{description}` | New features | No |
| `fix/{ticket}-{description}` | Bug fixes | No |
| `chore/{description}` | Maintenance / docs / config | No |
| `release/{version}` | Release preparation | Yes |

### Branch Naming Examples

```
feat/CMC-42-add-template-editor
fix/CMC-55-sse-reconnect-on-410
chore/update-flutter-3-22
release/1.0.0
```

---

## Pull Request Rules

### All PRs require:
- Target branch: `develop` (not `main` directly)
- At least 1 human reviewer approval
- All CI checks passing (lint, test, build)
- PR description filled using the template below

### PR Description Template

```markdown
## What this PR does
[One paragraph description of the change]

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Chore / Refactor
- [ ] Documentation

## Files changed
[Key files and the reason for each change]

## API calls made
[List any new Cursor or GitHub API calls added]

## Tests added
[List test files added or updated]

## Schema changes
[List any Drift schema changes and migration files]

## Known limitations
[Any known issues or follow-up tasks]

## Checklist
- [ ] `melos run lint` passes with no warnings
- [ ] `melos run test` passes (all tests green)
- [ ] No secrets in code or logs
- [ ] New files follow FOLDER_STRUCTURE.md conventions
- [ ] AGENT_GUIDE.md rules followed
```

---

## Cursor Agent Workflow

When a Cursor Background Agent creates a PR:

1. **Agent creates feature branch** from `develop`
2. **Agent implements** the task following AGENT_GUIDE.md
3. **Agent opens PR** to `develop` with filled PR template
4. **CI runs** lint + test + build automatically
5. **Human reviews**: checks for correctness, edge cases, security
6. **Human approves** and merges using Squash Merge
7. **Branch deleted** automatically after merge

### Agent PR Labels

Agents should add labels to PRs:
- `agent-created` — created by a Cursor Agent
- `needs-human-review` — always on agent PRs
- `size: small / medium / large` — based on files changed

---

## Release Strategy

### Versioning

Semantic Versioning: `MAJOR.MINOR.PATCH`

- `PATCH` — bug fixes, no new features
- `MINOR` — new features, backward compatible
- `MAJOR` — breaking change (rare — mobile apps should avoid breaking changes)

### Release Flow

```
1. Create release branch: git checkout -b release/1.2.0 develop
2. Bump version in pubspec.yaml (version: 1.2.0+42)
3. Update ROADMAP.md with release notes
4. PR: release/1.2.0 → main
5. Human reviews release PR
6. Merge to main (Merge Commit — not squash, to preserve history)
7. Tag: git tag v1.2.0
8. Merge back: main → develop
9. CI triggers Play Store / TestFlight upload
```

### Hotfix Flow

```
1. git checkout -b fix/hotfix-critical-crash main
2. Fix the issue
3. PR → main (fast-track human review)
4. Merge + tag (e.g., v1.1.1)
5. Cherry-pick to develop
```

---

## Code Review Checklist (for Human Reviewers)

When reviewing an agent-created PR:

- [ ] Does it follow the folder structure in FOLDER_STRUCTURE.md?
- [ ] Does it follow the provider type rules in ARCHITECTURE.md?
- [ ] Are all new API calls handled with typed error mapping?
- [ ] Are secrets absent from all new code?
- [ ] Are tests meaningful (not just coverage padding)?
- [ ] Does any new Drift migration follow the no-destructive-changes rule?
- [ ] Does the PR description include `AGENT_QUESTION` or `AGENT_ESCALATE` markers that need human response?

---

## Commit Message Convention

Format: `{type}({scope}): {description}`

Types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`

Examples:
```
feat(chat): add milestone markers for PR events
fix(sse): reconnect using Last-Event-ID on 410 response
chore(deps): upgrade flutter to 3.22.0
docs(agent-guide): add how-to for new Drift tables
test(cursor-api): add coverage for rate limit error mapping
```

---

## What Agents Cannot Do Without Human Approval

- Delete or modify existing Drift migrations
- Change certificate pinning configuration
- Modify OAuth callback URI
- Change secure storage key names
- Modify CI/CD pipeline YAML files
- Change ProGuard / obfuscation rules
- Add new third-party packages with network access

These changes require an `AGENT_ESCALATE` comment in the PR.
