# API Guide
# Cursor Mobile Commander
# Cursor v1 API + GitHub REST API Reference

---

## Cursor API v1

Base URL: `https://api.cursor.com/v1`
Auth: `Authorization: Bearer {cursor_api_key}`
Content-Type: `application/json`

> ⚠️ The Cursor v1 API is in beta. Schemas may change. All response models use null-safe defaults on every field.

---

### Authentication

#### Validate API Key
```
GET /v1/me
```
Used on onboarding to verify the key. Returns user info on success, 401 on invalid key.

---

### Agents

#### List Agents
```
GET /v1/agents
```
Response: paginated list of agents.
Cache strategy: 30s in-memory; refresh on screen focus.

#### Get Agent
```
GET /v1/agents/{agentId}
```
Returns agent metadata including `latestRunId` and `status`.

#### Create Agent (+ first run)
```
POST /v1/agents
```
Body:
```json
{
  "repos": [{ "url": "https://github.com/owner/repo" }],
  "messages": [{ "role": "user", "content": "..." }],
  "model": "claude-sonnet-4-5",
  "mode": "agent",
  "options": {
    "autoCreatePr": true,
    "workOnCurrentBranch": false
  }
}
```
Returns: `{ "agentId": "...", "runId": "..." }`

#### List Models
```
GET /v1/models
```
Cache strategy: 24h.

#### List Repositories
```
GET /v1/repositories
```
Rate limit: 1 req/min, 30/hour. Cache 24h. Show cooldown timer on refresh button.

---

### Runs

#### List Runs for Agent
```
GET /v1/agents/{agentId}/runs
```
Paginated. Use cursor-based pagination when available.

#### Get Run
```
GET /v1/agents/{agentId}/runs/{runId}
```
Polling fallback when SSE is unavailable. Poll every 10s.

#### Create Follow-up Run
```
POST /v1/agents/{agentId}/runs
```
Body:
```json
{
  "messages": [{ "role": "user", "content": "..." }]
}
```
Returns 409 `agent_busy` if a run is still active. UI disables send button until run is terminal.

#### Cancel Run
```
POST /v1/agents/{agentId}/runs/{runId}/cancel
```
Terminal action. Agent status becomes CANCELLED.

---

### Streaming

#### Stream Run Events
```
GET /v1/agents/{agentId}/runs/{runId}/stream
```
Server-Sent Events (SSE). Headers required:
```
Accept: text/event-stream
Last-Event-ID: {lastEventId}   ← for reconnection
```

SSE Event Types:

| Event Type | Payload | Action |
|---|---|---|
| `assistant` | `{ delta: string }` | Append to current assistant bubble |
| `thinking` | `{ delta: string }` | Show in collapsible thinking block |
| `tool_call` | `{ callId, name, status, args?, result? }` | Render tool call chip |
| `status` | `{ status: string }` | Update run status indicator |
| `interaction_update` | `{ ... }` | Update tool call chip state |
| `result` | `{ text: string }` | Final complete text (may be truncated) |
| `done` | `{}` | Close stream; fetch /usage |
| `error` | `{ code, message }` | Map to CursorRunFailure; show error UI |

Reconnection policy:
- On disconnect: wait 1s, retry with Last-Event-ID
- Backoff: 1s → 2s → 4s → 8s → 16s → max 30s
- On 410 `stream_expired`: stop reconnecting; poll GET /run

---

### Usage

#### Get Agent Usage
```
GET /v1/agents/{agentId}/usage
```
May not always be populated. Handle gracefully (show "—" not error).
Response:
```json
{
  "runs": [
    { "runId": "...", "inputTokens": 1200, "outputTokens": 3400 }
  ]
}
```

---

### Artifacts

#### List Artifacts
```
GET /v1/agents/{agentId}/artifacts
```
Response includes `type`, `name`, and presigned download URL.
Display as thumbnails in chat for image artifacts; as chips for log files.

---

## GitHub REST API

Base URL: `https://api.github.com`
Auth: `Authorization: Bearer {github_access_token}`
Accept: `application/vnd.github+json`
API Version: `X-GitHub-Api-Version: 2022-11-28`

Rate limit: 5,000 requests/hour (authenticated). Parse `X-RateLimit-Remaining` and `X-RateLimit-Reset` on every response.

---

### Auth

#### OAuth Flow (PKCE)
```
Step 1 — Authorize:
  GET https://github.com/login/oauth/authorize
  ?client_id={CLIENT_ID}
  &redirect_uri=cursormc://oauth/callback
  &scope=repo+read:org
  &code_challenge={challenge}
  &code_challenge_method=S256

Step 2 — Exchange (POST to GitHub, not API):
  POST https://github.com/login/oauth/access_token
  Body: { client_id, code, code_verifier, redirect_uri }
  Response: { access_token, token_type, scope }
```

---

### Repositories

#### List User Repos
```
GET /user/repos?per_page=100&sort=updated&page={n}
```
Cache 24h. Show manual refresh with 60s cooldown.

#### Get Repository
```
GET /repos/{owner}/{repo}
```
Cache 5min.

#### List Branches
```
GET /repos/{owner}/{repo}/branches?per_page=100
```
Cache 5min.

---

### Pull Requests

#### List Open PRs
```
GET /repos/{owner}/{repo}/pulls?state=open&per_page=50
```
Cache 60s.

#### Get PR Detail
```
GET /repos/{owner}/{repo}/pulls/{pull_number}
```
Includes: `head`, `base`, `mergeable`, `mergeable_state`, `draft`.

#### List PR Files (Diff)
```
GET /repos/{owner}/{repo}/pulls/{pull_number}/files?per_page=100
```
Response includes `patch` field (unified diff).
Cache 7 days in DiffCache. Cap display at 100 files. Link to GitHub for larger PRs.

#### Submit PR Review
```
POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews
Body: { body, event: "APPROVE" | "REQUEST_CHANGES" | "COMMENT", comments: [] }
```

#### Merge PR
```
PUT /repos/{owner}/{repo}/pulls/{pull_number}/merge
Body: { merge_method: "merge" | "squash" | "rebase", commit_title?, commit_message? }
```
Errors: 405 (not mergeable), 409 (merge conflict), 422 (validation failed).
Always show MergeConfirmSheet before calling this endpoint.

#### Delete Branch (post-merge)
```
DELETE /repos/{owner}/{repo}/git/refs/heads/{branch}
```
Call after successful merge if "delete branch after merge" is enabled.

---

### Repository Contents

#### Get File Tree (non-recursive)
```
GET /repos/{owner}/{repo}/git/trees/{sha}
```
Do NOT use `?recursive=1` — load depth-first on user tap.

#### Get File Content
```
GET /repos/{owner}/{repo}/contents/{path}?ref={branch}
```
Response includes `content` (base64 encoded). Decode before displaying.
Cache 5min. Cap at 500KB — show warning for larger files.

---

### Commits

#### List Commits
```
GET /repos/{owner}/{repo}/commits?sha={branch}&per_page=30&page={n}
```

---

### CI Status

#### Get Check Runs for Commit
```
GET /repos/{owner}/{repo}/commits/{sha}/check-runs
```
Cache 60s when PR review screen is open. Don't poll on dashboard unless user requests.

---

## Error Handling Reference

### Cursor API Errors

| HTTP Status | Error Code | Action |
|---|---|---|
| 401 | `unauthorized` | Navigate to key setup screen |
| 404 | `not_found` | Show "Agent not found" — may have been deleted |
| 409 | `agent_busy` | Disable send; show "Agent is busy" indicator |
| 410 | `stream_expired` | Stop SSE reconnect; switch to poll |
| 413 | `context_too_large` | Show "Repository too large for this model" |
| 429 | `rate_limited` | Show "Rate limit reached, resets at {time}" |
| 5xx | server error | Retry after 30s; show "Cursor service unavailable" |

### GitHub API Errors

| HTTP Status | Meaning | Action |
|---|---|---|
| 401 | Token invalid/expired | Reconnect GitHub (OAuth flow) |
| 403 | Secondary rate limit | Wait and retry; show cooldown |
| 404 | Repo/resource not found | Remove from pinned list |
| 405 | PR not mergeable | Show "Cannot merge: checks not passed" |
| 409 | Merge conflict | Show "Merge conflict — resolve in GitHub" |
| 422 | Validation failed | Parse error message; show to user |
| 429 | Rate limit | Show reset time from X-RateLimit-Reset |
