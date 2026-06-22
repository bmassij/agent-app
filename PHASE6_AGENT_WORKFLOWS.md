# Phase 6 — Agent Workflow Designs
# Cursor Mobile Commander

Each workflow below defines a standard Cursor Background Agent task pattern.
These are the pre-built **Command Templates** shipped with the app.

For each agent: purpose, expected prompt, output format, review workflow, merge workflow.

---

## Workflow 1: SEO Audit Agent

### Purpose
Analyze the SEO health of a web project (static site, Next.js, Nuxt, etc.) and produce a prioritized report with concrete fixes.

### Trigger (App Template)
Template name: "SEO Audit"
Variable: `{repo}`, `{branch}` (auto-filled from project context)

### Expected Prompt
```
Perform a comprehensive SEO audit of the repository {repo} on branch {branch}.

Analyze:
1. Meta tags (title, description, og:*, twitter:*)
2. Heading hierarchy (H1-H6)
3. Image alt attributes
4. Page speed indicators (large assets, render-blocking resources)
5. Canonical URLs and robots.txt
6. Structured data / JSON-LD schema
7. Internal linking structure
8. Mobile responsiveness markers

Output:
- A detailed Markdown report at docs/SEO_AUDIT_{date}.md
- Priority: Critical / High / Medium / Low for each issue
- Concrete fix for each issue (code snippet where applicable)
- Summary table at the top

Do NOT auto-fix issues. Report only.
```

### Output Format
```
docs/SEO_AUDIT_2026-06-22.md
```

Contents:
```markdown
# SEO Audit — {repo}
## Summary
| Priority | Count |
|---|---|
| Critical | 2 |
| High | 5 |
...

## Critical Issues
### Missing meta description on 12 pages
**File:** src/pages/...
**Fix:** Add `<meta name="description" content="...">` to layout.html
...
```

### Review Workflow
1. Agent opens PR: `docs/SEO_AUDIT_{date}.md` added
2. Human reviews report for accuracy
3. Human creates a follow-up task: "Fix SEO Issues — Round 1" (separate agent run)

### Merge Workflow
- Standard squash merge to `develop`
- No code changes — docs PR only, low risk
- Human can approve without extended review

---

## Workflow 2: Website Audit Agent

### Purpose
Full technical audit of a website: performance, accessibility, broken links, console errors, security headers.

### Trigger (App Template)
Template name: "Website Audit"
Variables: `{repo}`, `{base_url}`

### Expected Prompt
```
Perform a full technical audit of the project in {repo}.

Assume the site runs at {base_url} in production.

Analyze the codebase for:
1. Accessibility: missing ARIA labels, focus management, color contrast issues in CSS
2. Performance: large image assets (>200KB), missing lazy loading, synchronous scripts
3. Security headers: check if CSP, HSTS, X-Frame-Options are configured in server/framework config
4. Broken internal links: scan all href/src attributes for references to missing files
5. Console error sources: look for patterns likely to produce runtime JS errors
6. Unused CSS/JS: identify large files with low selector usage
7. Dependency vulnerabilities: check package.json / pubspec.yaml for known CVEs (reference CVE IDs if known)

Output:
- docs/WEBSITE_AUDIT_{date}.md with priority ratings
- Per-issue: file location, line number (where applicable), recommended fix
- Do NOT make code changes
```

### Output Format
```
docs/WEBSITE_AUDIT_{date}.md
```

### Review Workflow
1. Agent opens PR with audit doc
2. Human reviews findings against live site behavior
3. Human creates targeted fix tasks per finding

### Merge Workflow
- Docs-only PR; merge to `develop` with single human review

---

## Workflow 3: Landing Page Agent

### Purpose
Create a complete, production-ready responsive landing page for a product or feature.

### Trigger (App Template)
Template name: "Build Landing Page"
Variables: `{repo}`, `{product_name}`, `{product_description}`, `{brand_colors}`

### Expected Prompt
```
Build a responsive landing page for {product_name} in the repository {repo}.

Product description: {product_description}
Brand colors: {brand_colors}

Requirements:
- Single HTML/CSS/JS file OR framework-native component (detect from repo stack)
- Above-fold: hero section with headline, sub-headline, CTA button
- Features section: 3-4 feature cards with icons
- Social proof section: placeholder testimonial cards
- Footer: links, copyright
- Fully mobile responsive (CSS Grid / Flexbox)
- Dark mode support via prefers-color-scheme
- Performance: no external JS dependencies unless already in project
- Accessibility: semantic HTML, alt tags, ARIA labels
- SEO: meta title, description, og:* tags

Output:
- Create the page file at the appropriate path for this project's stack
- Open a PR titled "feat: add landing page for {product_name}"
- Include screenshot description in PR body (you cannot take screenshots — describe layout)
```

### Output Format
- `src/pages/landing/{product_name_slug}.html` (or equivalent for the stack)
- PR opened with description of sections and layout

### Review Workflow
1. Human reviews generated HTML in PR diff
2. Human runs locally: `open src/pages/landing/...`
3. Human adds visual feedback as PR comment
4. Agent revises in follow-up run if needed

### Merge Workflow
- Human reviews; squash merge to `develop`
- Requires visual check before merge

---

## Workflow 4: Bug Fix Agent

### Purpose
Diagnose and fix a specific bug, with regression test.

### Trigger (App Template)
Template name: "Bug Fix"
Variables: `{repo}`, `{bug_description}`, `{reproduction_steps}`

### Expected Prompt
```
Fix the following bug in {repo}:

Bug description: {bug_description}

Reproduction steps:
{reproduction_steps}

Instructions:
1. Locate the root cause by searching the codebase
2. Implement the minimal fix — do not refactor unrelated code
3. Add a regression test that would catch this bug if it reoccurs
4. Update relevant documentation if behavior changes
5. Open a PR titled "fix: {bug_description_short}"

PR must include:
- Root cause analysis (2-3 sentences)
- Files changed and why
- Test added (file path + test description)
- Before/after behavior description

Do NOT change unrelated code. Do NOT refactor. Fix only the reported bug.
```

### Output Format
- Fix commit(s) on feature branch
- PR with root cause + test evidence

### Review Workflow
1. Human reads root cause analysis
2. Human checks diff is minimal (no scope creep)
3. Human checks regression test is meaningful
4. Optional: human runs tests locally

### Merge Workflow
- Squash merge to `develop`
- If critical bug: cherry-pick fix to `main` as hotfix

---

## Workflow 5: Repository Refactor Agent

### Purpose
Clean up a codebase: remove dead code, fix linting issues, update dependencies, improve naming.

### Trigger (App Template)
Template name: "Repository Cleanup"
Variables: `{repo}`, `{scope}` (e.g., "entire repo" or "apps/mobile/lib/features/auth")

### Expected Prompt
```
Perform a focused cleanup of {repo}, scope: {scope}.

Tasks:
1. Remove unused imports (lint: unused_import)
2. Remove dead code (unreachable code, unused variables, unused functions)
3. Fix all lint warnings reported by `dart analyze` (or equivalent for this stack)
4. Rename any symbols that violate the project naming conventions in docs/AGENT_GUIDE.md
5. Update pubspec.yaml dependencies to latest stable versions (check pub.dev)
6. Run formatter

Rules:
- Do NOT change business logic
- Do NOT change public API signatures
- Do NOT remove code that is commented out (leave for human decision)
- Do NOT change test files (tests may use internal symbols)
- Open ONE PR per logical change area (e.g., separate PR for deps vs lint fixes)

Open PRs with title "chore: {description}"
```

### Output Format
- Multiple small PRs (one per area)
- Each PR: `chore: remove unused imports in features/auth`

### Review Workflow
1. Human reviews each PR independently (small = fast review)
2. Verify no logic changes in diff
3. Run test suite before approving

### Merge Workflow
- Sequential merges to `develop` (one at a time to avoid conflicts)
- Agent waits for each merge before starting next refactor PR

---

## Workflow 6: Last War Optimizer Agent

### Purpose
Specific to the Last War game project. Analyze and optimize game content, battle mechanics code, resource calculators, or content generation pipelines.

### Trigger (App Template)
Template name: "Last War Optimizer"
Variables: `{repo}`, `{optimization_target}` (e.g., "resource calculator", "troop efficiency formula", "battle simulator")

### Expected Prompt
```
Optimize the Last War game project in {repo}.

Target: {optimization_target}

Instructions:
1. Analyze the current implementation of {optimization_target}
2. Identify performance bottlenecks, logical errors, or missing edge cases
3. Implement optimizations:
   - If calculator: verify formulas against known game constants; add missing unit types
   - If content: improve copy quality, add missing game terminology, fix factual errors
   - If code: optimize algorithmic complexity; add caching where appropriate
4. Add unit tests for all modified calculation functions
5. Document any game constants used (source: in-code comment or README note)
6. Open PR titled "feat: optimize {optimization_target}"

Important: Do not change the UI unless the task explicitly requires it. Logic layer only.
```

### Output Format
- Code changes in relevant module
- Updated tests
- PR with optimization summary + before/after complexity analysis

### Review Workflow
1. Human verifies game formulas against known values (manual check)
2. Human runs tests
3. Human checks performance: run before/after timing if applicable

### Merge Workflow
- Squash merge to `develop`
- Game constant changes require extra human verification before merge

---

## Workflow 7: Documentation Generator Agent

### Purpose
Generate or update documentation for a module, feature, or API.

### Trigger (App Template)
Template name: "Generate Documentation"
Variables: `{repo}`, `{module_path}`, `{doc_type}` (README / API reference / architecture / runbook)

### Expected Prompt
```
Generate {doc_type} documentation for the module at {module_path} in {repo}.

Instructions:
1. Read all source files in {module_path}
2. For README: write purpose, usage examples, configuration options, known limitations
3. For API reference: document every public class, method, and parameter (Dart docstrings + Markdown)
4. For architecture: describe data flow, dependencies, state management, error handling
5. For runbook: write step-by-step operational procedures (deploy, rollback, debug)

Output:
- Place documentation at {module_path}/README.md (or docs/{name}.md for architecture docs)
- Open PR titled "docs: generate {doc_type} for {module_path}"

Quality bar:
- Every public method documented
- At least one usage example per module
- No placeholder text like "TODO" or "describe here"
```

### Output Format
- Markdown file(s) at specified path
- Dart docstring updates in source files (for API reference)

### Review Workflow
1. Human reads generated docs for accuracy
2. Human verifies examples compile and run correctly
3. Human corrects any hallucinated behavior descriptions

### Merge Workflow
- Docs-only PR: fast-track single human review
- Code + docs PR: standard review

---

## Workflow 8: Feature Builder Agent

### Purpose
Implement a new feature end-to-end: domain model, repository, UI, tests.

### Trigger (App Template)
Template name: "Build Feature"
Variables: `{repo}`, `{feature_description}`, `{acceptance_criteria}`

### Expected Prompt
```
Implement the following feature in {repo}:

Feature: {feature_description}

Acceptance criteria:
{acceptance_criteria}

Instructions:
1. Read AGENT_GUIDE.md before starting — follow all conventions
2. Read FOLDER_STRUCTURE.md — place files in correct locations
3. Read ARCHITECTURE.md — use correct layer architecture
4. Plan your implementation (list files you will create/modify in PR description)
5. Implement in this order:
   a. Domain model + repository interface + failure types
   b. Repository implementation (data layer)
   c. Riverpod providers (use correct provider types per AGENT_GUIDE)
   d. Screen + widgets (presentation layer)
   e. Route (add to router.dart and routes.dart)
   f. Unit tests (domain + data layer)
   g. Widget test (at least one key screen)
6. Run melos run lint && melos run test before opening PR
7. Open PR titled "feat: {feature_name}"

Do NOT modify existing features unless the acceptance criteria explicitly requires it.
If you discover a dependency on an existing feature that needs changes: stop, describe in PR comment, wait for human instruction.
```

### Output Format
- Full feature implementation across domain/data/presentation layers
- Test files in test/ mirroring the feature structure
- PR with full file list and implementation rationale

### Review Workflow
1. Human reviews domain model for correctness
2. Human reviews provider types (match rules in ARCHITECTURE.md)
3. Human checks no business logic in widgets
4. Human runs app on device
5. Human verifies acceptance criteria manually
6. Human approves

### Merge Workflow
- Squash merge to `develop` after full human review
- New screen routes require smoke test on real device before merge

---

## Template Storage Format

Templates are stored in `apps/mobile/lib/features/templates/data/builtin_templates.dart`:

```dart
const List<TemplateModel> builtinTemplates = [
  TemplateModel(
    id: 'seo-audit',
    name: 'SEO Audit',
    description: 'Analyze SEO health and produce a prioritized report',
    promptTemplate: 'Perform a comprehensive SEO audit of {repo} on branch {branch}...',
    variables: ['repo', 'branch'],
    isBuiltin: true,
  ),
  // ... all 8 templates
];
```

Variables are filled in TemplatePickerSheet before the prompt is sent to the agent.
