# Cloud Agent Parity Architecture

## Overview

`commander_orchestrator` enriches short user prompts before calling the official Cursor Cloud Agents API v1. No second LLM, no hidden endpoints.

## Packages

| Package | Role |
|---------|------|
| `cursor_api_agents` | Full API models (`AgentRepoConfig`, `prUrl`, `env`, `prompt.images`, …) |
| `github_api` | Branches, commits, PRs, CI, README, file presence |
| `commander_orchestrator` | Context → briefing → `POST /v1/agents` |

## Flow

```
User prompt + repo
  → PromptIntent (rule-based)
  → RepositoryScanner (GitHub if token available)
  → ContextCache (15 min TTL)
  → PromptBuilder (compact briefing in prompt.text)
  → AgentCommandOrchestrator
  → Cursor Cloud API
```

## Client configuration

| Platform | Cursor key | GitHub enrichment |
|----------|------------|-------------------|
| Desktop | `CURSOR_API_KEY` in `.env` | Optional `GITHUB_TOKEN` in `.env` |
| Mobile | Secure storage | Optional GitHub OAuth token |

Without GitHub token, orchestrator still sets `startingRef`, `mode`, `prUrl` when known, and relies on the cloud VM to read `AGENTS.md` / rules.

## Remaining gaps vs cursor.com

| Feature | Reason |
|---------|--------|
| Local IDE tabs / terminal / diagnostics | Not exposed by public API |
| Dashboard secrets / named environments UI | Configure via cursor.com; API `env.name` supported in models |
| Remote desktop control | UI-only on cursor.com |
| List environments API | No official list endpoint — use dashboard names |
