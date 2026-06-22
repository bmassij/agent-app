# Cursor Mobile Commander

**Manage Cursor Background Agents from your phone. No PC required.**

Cursor Mobile Commander is a native Flutter application that connects directly to the Cursor Cloud Agent API and GitHub. It allows you to create agents, stream their output in real time, review their pull requests, and merge code — entirely from your mobile device.

---

## What It Does

- **Start agents** — Create a new Cursor Background Agent against any GitHub repository
- **Chat in real time** — Stream agent output as it happens (SSE)
- **Follow up** — Send additional instructions to an active or completed agent
- **Review PRs** — View agent-generated pull requests with syntax-highlighted diffs
- **Merge** — Approve and merge PRs directly from the app
- **Browse** — Explore repository files, commits, and branches
- **Templates** — Reuse common prompts (SEO audit, bug fix, refactor, etc.)
- **Offline** — Read past conversations and queue prompts when offline

---

## What It Does NOT Do

- Run local AI or local Cursor agents
- Require your Windows PC to be on
- Require a backend server
- Manage billing or Cursor subscription

---

## Requirements

- Cursor account with Cloud Agents enabled and a GitHub repository connected (via Cursor dashboard)
- Cursor API key (Dashboard → API Keys)
- GitHub account (OAuth connected in-app)
- Android 8.0+ (API 26) or iOS 14+

---

## Quick Start

1. Download from Play Store / App Store (or build from source)
2. Paste your Cursor API key or scan the QR code from the desktop helper
3. Connect your GitHub account
4. Pin a repository
5. Tap "New Agent" — describe your task — watch it work

---

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for system design, data flow, and module overview.

See [AGENT_GUIDE.md](AGENT_GUIDE.md) if you are a Cursor Agent maintaining this project.

---

## Development

See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) for setup instructions, build commands, and coding conventions.

---

## Security

See [SECURITY.md](SECURITY.md) for how API keys are stored, transport security, and responsible disclosure.

---

## License

MIT — see LICENSE file.

---

## Maintained By

This project is designed to be maintained by Cursor Background Agents. Human review is required for all merges. See [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow.
