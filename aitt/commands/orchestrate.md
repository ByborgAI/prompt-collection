---
name: orchestrate
description: Implementation coordinator that drives plan execution in main context
category: orchestration
version: 3.1
schema: aitt/commands/cmd.md
model: opus
input:
  expects: "Path to implementation plan markdown file"
  required: true
  format: free-text
---

> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.

# Orchestrate

> Implementation coordinator that fully implements a plan to production quality within the main context, with intelligent verification that adapts to project capabilities.

## Purpose

Fully implement the plan at the provided path **directly in the main context**. With 1M token context, all planning and implementation happen in a single conversation. Final verification and code review are delegated to parallel subagents for thoroughness and speed.

**Your role:**
- Read and analyze the plan
- Decompose work into milestones and tasks
- Implement each task directly using Edit/Write/Bash tools
- Run milestone-level verification (tests, typecheck, lint) directly
- Launch parallel subagents for final verification and code review
- Validate that implementation meets all original requirements

**Use when:**
- Implementing a multi-phase feature from a detailed plan
- Coordinating implementation across multiple files/modules

**Do not use when:**
- Simple single-file changes or quick bug fixes
- Exploratory research tasks

## Key Principles

### Execution Model

**Direct Implementation with Inline Verification:**
Each milestone is implemented and verified directly. Write code, generate migrations (if schema changes are involved), apply migrations, then run CLI checks (unit tests, typecheck, lint). After all milestones, parallel subagents handle comprehensive final verification (runtime, E2E, browser testing) and code review (security, clean code, architecture, performance, error handling, dead code).

**Adaptive Verification (most to least efficient):**
1. Unit tests and automated test suites
2. CLI/script execution (API endpoints, command-line tools)
3. Browser-based testing via Chrome Devtools MCP
4. Full E2E testing via Playwright/Selenium

**Migration-First Execution:**
When a milestone involves database schema changes, migrations must be generated and applied *before* verification runs. Code that depends on new columns, tables, or relations cannot be tested against an outdated schema. When possible, break schema-dependent work into smaller increments: generate migration, apply, implement code, verify. This keeps the feedback loop tight.

**Complete Execution — No Deferral:**
Every plan item MUST be fully implemented. If a task proves harder than expected, solve it — don't defer it. The final requirements validation treats any deferred or missing item as mandatory work.

**Server Health Invariant:**
A broken dev server is a broken feedback loop. If the dev server crashes, fails to start, or becomes unresponsive at any point during implementation — whether from a code change, a new endpoint, a missing dependency, a schema mismatch, or any other cause — diagnose and fix the issue before any further implementation work proceeds. Continuing to write code against an untestable system is forbidden.

### Code Standards

**Simplicity:**
Prefer the smallest solution that meets the plan. No code duplication, no speculative abstractions. Reuse existing primitives; match existing code style, patterns, and conventions.

**Discovery Before Creation:**
Before implementing new functionality, search the codebase for existing code to reuse or extend. Check shared packages, utilities, and helpers. If something already exists that covers the same concern, extend or wrap it — do not create a parallel version.

**Code Hygiene:**
Before declaring completion, the codebase must be clean: no dead code, unused exports, debug logs, temp scripts, or leftover experimental code. The final state contains only what's necessary.

## Inputs

**Expects:** Path to implementation plan markdown file
**Required:** Yes

### Usage

```
/orchestrate docs/plans/feature-name.md
```

### Plan File Requirements

The plan file should contain:
- Requirements and acceptance criteria
- Architecture or file structure overview
- Implementation checklist or phases
- Verification/testing expectations

## Prerequisites

### Gate 1: Plan File Exists

**Check:** Provided path resolves to a readable markdown file
**Pass:** Proceed to Gate 2
**Fail:** Exit — `Plan file not found: <path>. Verify the path and try again.`

### Gate 2: Plan Contains Actionable Content

**Check:** Plan has identifiable tasks, phases, or checklist items
**Pass:** Proceed to Process
**Fail:** Exit — `Plan file lacks actionable structure. Expected: phases, checklist items, or task breakdown.`

## Process

### Step 1: Analyze the Plan

Read the plan file and extract:

1. **Requirements** — What must be built
2. **Acceptance criteria** — How to verify success
3. **Dependencies** — What must exist before implementation
4. **Risks** — What could go wrong
5. **Work breakdown** — Epics, tasks

#### Project Capability Detection

Detect available project capabilities for verification and cleanup:

| Capability | Detection Method | Used In |
|------------|------------------|---------|
| Unit tests | `package.json` scripts (test, jest, vitest, mocha) | Milestone & final verification |
| API endpoints | Route files, OpenAPI specs, server code | Milestone & final verification |
| CLI scripts | `package.json` scripts, `scripts/` folder | Milestone & final verification |
| Playwright | `playwright.config.*`, `@playwright/test` dependency | Final verification |
| E2E Screenshots | `e2e/fixtures/screenshots.ts` or similar | Final verification |
| Chrome Devtools MCP | MCP server availability | Final verification |
| Dead code analyzer | `package.json` scripts/deps (knip, ts-prune, unimported) | Cleanup phase |
| DB migrations | `package.json` scripts (db:migrate, db:push, db:generate), Drizzle/Prisma/Knex config, migration directories | Milestone execution — run before verification |

Detection priority: `package.json` scripts, test config files, test directories, E2E screenshot fixtures, API route definitions, MCP server availability, dead code analyzer, migration config/scripts.

#### Unknowns Handling

If critical information is missing: make reasonable assumptions, document them, and proceed.

#### Output Schema

```yaml
plan_analysis:
  requirements: [list]
  acceptance_criteria: [list]
  dependencies: [list]
  risks: [list]
  work_breakdown:
    - milestone: "Milestone Name"
      tasks:
        - name: "Task name"
          files: [affected files]
          depends_on: [task names]
          has_schema_changes: true/false
  verification_capabilities:
    unit_tests: { available: bool, command: string, framework: string }
    api_testing: { available: bool, endpoints: [list] }
    e2e_testing: { available: bool, framework: string, command: string, screenshots: { available: bool, env_var: string } }
    browser_testing: { available: bool, method: string }
    dead_code_analyzer: { available: bool, tool: string, command: string }
    db_migrations: { available: bool, tool: string, generate_command: string, migrate_command: string, backup_command: string }
```

---

### Step 2: Design Execution Strategy

Using the analysis from Step 1, produce an execution plan:

1. **Ordered milestones** — Sequential phases with clear boundaries
2. **Task ordering within milestones** — Dependency-respecting sequence
3. **Definition of done** — Per milestone: what must be implemented and what verification must pass
4. **Verification strategy** — Based on detected capabilities (see below)

#### Verification Strategy

**Per milestone:**
1. Implement code and generate migration files (if schema changes involved)
2. Apply migrations before verification
3. Run CLI checks (unit tests, typecheck, lint)

**Once after all milestones:**
Full verification — all CLI tests, runtime startup check, E2E tests, browser testing via Chrome Devtools MCP (if feature has UI).

**Skip UI verification for:** Backend/API-only changes, config/data changes, library/utility code.

---

### Step 3: Checkpoint — Ready to Execute

> **GATE:** Do not proceed until satisfied.

- [ ] All milestones ordered with clear boundaries
- [ ] Tasks within each milestone ordered by dependencies
- [ ] Schema-change tasks identified with migration steps
- [ ] Verification checks specified per milestone

**If not satisfied:** Return to Step 2

---

### Step 4: Execute Milestones

For each milestone in order, implement all tasks and verify results before moving on.

#### Per Milestone

1. **Discovery** — Before implementing, search the codebase for existing code to reuse or extend. Check shared packages, utilities, helpers, type definitions, and constants.
2. **Implement tasks** — Work through each task in dependency order:
   - Read affected files to understand current state
   - Write code using Edit/Write tools
   - Generate migration files if schema changes are involved
3. **Apply migrations** — If any task in this milestone generated migration files:
   - Back up the database
   - Run all pending migrations
   - If migration fails, diagnose and fix the schema issue, then re-apply
4. **Run verification** — Run CLI checks (unit tests, typecheck, lint) against the now-migrated database
5. **Verify server health** — If the dev server should be running (or needs to run for verification), confirm it starts and stays running. If it crashes after the milestone's changes, diagnose and fix before advancing.
6. **If pass** — Proceed to next milestone
7. **If fail** — Fix issues and re-verify

#### Migration Timing

The default flow batches migrations per milestone. For milestones with multiple schema-dependent tasks, use a tighter loop:

```
Task A (schema change) → generate migration → apply migration → Task B (depends on A's schema) → generate migration → apply migration → verify all
```

Choose the granularity based on task dependencies:
- **Batch per milestone** — When tasks don't depend on each other's schema changes
- **Incremental (per task)** — When a later task depends on an earlier task's schema changes

#### Quality Gates (apply to all work)

**Functionality:**
- Features work per plan + acceptance criteria
- No partial implementations

**Correctness & Safety:**
- Input validation at system boundaries
- Error handling consistent with codebase
- No security vulnerabilities

**Code Quality:**
- No copy/paste duplication, unnecessary layers, or dead code
- No unused imports, variables, exports, or type definitions
- No commented-out code blocks
- Clear file responsibilities, small readable functions

**Code Hygiene:**
- No `console.log`/`console.debug`/`debugger` (except intentional logging)
- No TODO/FIXME from this implementation (existing ones OK)
- No temp scripts, experimental code paths, or stub implementations

**Documentation:**
- README.md updated if new commands/scripts/setup steps added
- CLAUDE.md updated if new patterns/conventions added

---

### Step 5: Code Cleanup

After all milestones pass, perform quick cleanup before final verification. Thorough code quality analysis (dead code, duplication, architecture) is handled by dedicated subagents in Step 6.

1. **Remove debug artifacts** — `console.log`/`debug`/`debugger` statements, TODO/FIXME from this implementation
2. **Remove temp artifacts** — Temp files, scripts, one-time migration scripts
3. **Update documentation** — README.md if new scripts/commands; CLAUDE.md if new patterns

Cleanup runs BEFORE final verification so any breakage from removal is caught.

---

### Step 6: Final Verification

After cleanup, run comprehensive verification and code review using parallel subagents. Each subagent is responsible for its own domain — it finds issues, validates they are real (not false positives), fixes them, and reports what was changed.

#### Wave 1: CLI Gate (blocking)

Launch a single subagent. Wave 2 cannot start until this passes.

| Subagent | Responsibility |
|----------|---------------|
| **CLI Verifier** | Run unit tests, typecheck, lint. Fix all failures. Re-run until green. |

#### Wave 2: Parallel Verification + Code Review

Launch all applicable subagents in parallel after Wave 1 passes. Each subagent receives the plan file path and the list of files changed during this implementation.

**Verification subagents:**

| Subagent | Responsibility |
|----------|---------------|
| **Runtime Verifier** | Start dev server, verify no crashes within 30s, smoke test key pages/endpoints, check for 500s and module errors. Fix crashes and re-verify. |
| **E2E Test Runner** | Run Playwright tests, capture screenshots, review screenshots with AI for visual regressions. Fix failing tests. (Skip if no UI changes) |
| **Browser Tester** | Chrome MCP walkthrough — manually verify the feature works, test happy paths and edge cases, check console errors and network requests. Fix issues found. (Skip if no UI changes) |

**Code review subagents:**

| Subagent | Responsibility |
|----------|---------------|
| **Security Reviewer** | Audit changed files for injection risks (SQL, XSS, command), auth/authz gaps, secrets in code, OWASP top 10 patterns. Validate each finding is a real risk (not a false positive). Fix confirmed vulnerabilities. |
| **Clean Code Reviewer** | Review changed files for code duplication, poor naming, oversized functions, readability issues, SRP violations. Validate findings make sense in context. Fix confirmed violations. |
| **Architecture Reviewer** | Review changed files for module boundary violations, incorrect dependency direction, tight coupling, inconsistent patterns, missed abstractions. Validate findings against project conventions. Fix confirmed violations. |
| **Performance Reviewer** | Review changed files for N+1 queries, missing indexes on new queries, unnecessary DB calls, bundle size impact from heavy imports, redundant computations. Validate findings are actual bottlenecks. Fix confirmed issues. |
| **Error Handling Reviewer** | Review changed files for unhandled promise rejections, missing try/catch at boundaries, silent error swallowing, missing React error boundaries, poor error messages. Validate findings are real gaps. Fix confirmed issues. |
| **Dead Code Analyzer** | Run dead code analysis tool (knip/ts-prune if available, otherwise grep-based search). Analyze results to distinguish genuinely dead code from dynamically used code. Remove confirmed dead exports, imports, functions, types. Preserve items used via dynamic imports or public API with justification. |

#### Subagent Instructions (shared across all Wave 2 subagents)

Each subagent must:
1. **Scope** — Focus only on files changed during this implementation (provided in task spec) and their immediate callers/callees
2. **Find** — Identify issues within their domain
3. **Validate** — Judge whether each finding is real and worth fixing (not a false positive, not a style preference, not pre-existing)
4. **Fix** — Apply fixes directly for all confirmed issues
5. **Report** — Return a structured report of findings and changes made

Report format per subagent:
```markdown
## [Reviewer Name] Report

### Findings & Fixes
- [Finding]: [why it's real] → Fixed in `path/file.ts:line`

### No Issues (if applicable)
All checked, no issues found.

### Skipped (if applicable)
[What was skipped and why — e.g., pre-existing issues outside scope]
```

#### Wave 2 Completion

After all Wave 2 subagents complete:
1. **Collect reports** — Read all subagent reports
2. **Re-run CLI gate** — Code review fixes may have introduced regressions. Run unit tests, typecheck, lint again. Fix if needed.
3. **Resolve conflicts** — If multiple reviewers changed the same file, verify changes are compatible
4. **Confirm server health** — Verify dev server still starts and runs after all fixes

---

### Step 7: Requirements Validation

Read the plan file and extract every requirement and acceptance criterion. For each one, determine whether it is fully satisfied by searching the codebase for implementation evidence.

Produce a traceability report:

```markdown
## Requirements Traceability
- Requirement 1: implemented in `path/file.ts:line`, verified by [method]
- Requirement 2: implemented in `path/file.ts:line`, verified by [method]

## Acceptance Criteria
- Criterion 1: [evidence]

## Gaps Found
[Any requirements not fully satisfied]

## Verdict
ALL SATISFIED | GAPS FOUND (list count)
```

**If all requirements satisfied** — Proceed to Step 8.
**If gaps found** — Implement missing requirements, re-run verification (Steps 4-6), then re-validate until all requirements are met.

---

### Step 8: Completion

When all acceptance criteria are met, requirements validation passes, and code is clean:

1. **Produce final report** (see Outputs)
2. **Produce release checklist** for merge/deploy

## Outputs

### Final Report

The final report is a structured markdown document for a tech lead / architect audience. Every section is mandatory. Use bullet points — no prose paragraphs. Be specific with counts, file paths, and results. The report must answer: what was built, does it work, were there surprises, is it safe to merge.

```markdown
# Implementation Report: [Feature Name]

## Overview
- **Verdict:** ready to merge / blocked / issues remaining
- **Scope:** [modules/packages affected]
- **New dependencies:** [list, or none]
- **Migrations:** [list migration files applied, or none]

## What Was Built
- [Capability 1: what users can now do]
- [Capability 2: what users can now do]
- [...]

### Key Decisions
- [Decision and rationale]
- [Trade-off chosen and why]

### Files Changed
- `path/file.ts` — [what changed]
- `path/other.ts` — [what changed]
- [...]

## Verification

### CLI
- **Unit tests:** pass/fail — [X tests, Y suites]
- **Typecheck:** pass/fail
- **Lint:** pass/fail

### Runtime
- **Server startup:** [starts on port X, no crashes / failed — reason]
- **Smoke tests:** [endpoints/pages tested with status codes]
- **Console errors:** [none / list]

### E2E Tests
- **Status:** pass / skipped ([reason])
- **Tests run:** [test files and scenarios]
- **Screenshots:** [reviewed, visual issues found / clean]

### Browser Testing (Chrome MCP)
- **Status:** pass / skipped ([reason])
- **Scenarios tested:** [list each with result]
- **Console errors:** [none / list]
- **Network issues:** [none / list failed requests]

## Code Review

### Security — [X findings, X fixed]
- [Finding: what, where, severity] → Fixed in `path/file.ts:line`
- [Or: Clean — no issues]

### Clean Code — [X findings, X fixed]
- [Finding: what, where] → Fixed: [how]
- [Or: Clean — no issues]

### Architecture — [X findings, X fixed]
- [Finding: what, where] → Fixed: [how]
- [Or: Clean — no issues]

### Performance — [X findings, X fixed]
- [Finding: what, where] → Fixed: [how]
- [Or: Clean — no issues]

### Error Handling — [X findings, X fixed]
- [Finding: what, where] → Fixed: [how]
- [Or: Clean — no issues]

### Dead Code — [X items removed]
- [What was removed, from where]
- [Or: Clean — nothing found]

### Post-Review Regression Check
- **CLI re-run:** pass/fail

## Risks & Limitations
- [Edge cases not covered]
- [Assumptions made during implementation]
- [Areas deserving extra scrutiny]
- [Or: None identified]

## Release Checklist
- [ ] Requirements satisfied (X/X)
- [ ] Tests passing
- [ ] Server runs
- [ ] Code review clean
- [ ] Documentation updated
- [ ] Ready for merge
```

## Examples

### Basic Usage

```
/orchestrate docs/plans/feature-name.md
```

### Example Execution Flow

```
1. Analyze plan: docs/plans/feature-name.md
   → 3 phases, 12 tasks
   → Capabilities: vitest, playwright, Chrome MCP, knip

2. Execution strategy:
   → Per milestone: implement → migrate → verify (CLI)
   → Final: CLI + runtime + E2E + Chrome MCP

3. Execute milestones:
   Phase 1: Foundation
     → Schema + migration generated
     → DB backed up, migration applied ✓
     → Types + repository implemented
     → Verification pass ✓
   Phase 2: Core logic
     → New column migration generated → applied ✓
     → Service + API implemented
     → 1 test failure → fixed → pass ✓
   Phase 3: Integration (no schema changes)
     → UI wired to API → pass ✓

4. Code cleanup:
   → knip: removed unused helper, 5 imports
   → Removed 4 console.logs, 1 temp script
   → Updated README.md

5. Final verification:
   Wave 1 (CLI gate):
     → Unit tests, typecheck, lint: all pass ✓
   Wave 2 (parallel):
     → Runtime: server starts on :3010, smoke tests pass ✓
     → E2E: Playwright pass, screenshots reviewed ✓
     → Browser: Chrome MCP walkthrough pass ✓
     → Security: 1 finding (unescaped input) → fixed ✓
     → Clean Code: 2 findings (naming, duplication) → fixed ✓
     → Architecture: no issues ✓
     → Performance: 1 finding (N+1 query) → fixed ✓
     → Error Handling: 1 finding (missing try/catch) → fixed ✓
     → Dead Code: removed 3 unused exports ✓
   Post-review CLI re-check: all pass ✓

6. Requirements validation: 3/3 satisfied

✓ IMPLEMENTATION COMPLETE — ready for review
```

## Error Handling

### ERR-001: Plan File Not Found

**Cause:** Invalid path or file doesn't exist
**Resolution:** Verify path, check for typos, ensure `.md` extension

---

### ERR-002: Verification Loop Stuck

**Cause:** Unclear requirements or conflicting constraints
**Resolution:**
1. Document the specific failure
2. Assess if the requirement is achievable
3. Adjust approach or flag for manual review

---

### ERR-003: Cleanup Breaks Tests

**Cause:** Removed code that was actually used
**Resolution:**
1. Identify which removal caused the failure from git diff
2. Restore the removed code
3. Document why it appeared dead but wasn't
4. Re-run cleanup with updated understanding

If uncertain about removal (public API, dynamic imports, reflection): preserve with justification and flag for human review.

---

### ERR-004: Dev Server Crash or Failure to Start

**Cause:** Code changes introduced a runtime error, missing import, broken route, schema mismatch, or dependency issue that prevents the dev server from running.

**Resolution:**
1. Stop all implementation work — do not write more code against a broken system
2. Read the server's error output (crash logs, stack trace, startup errors)
3. Identify the specific change that caused the failure
4. Diagnose root cause, apply fix, and confirm the server starts and stays running
5. Only after server health is confirmed, resume implementation work
6. If the fix requires reverting changes, revert and re-implement with a corrected approach

## Completion Rules

**"Partially complete" is NOT a valid final state.** If any requirements remain unmet, loop back to implement them. Only use the blocked status for genuine external dependencies outside the orchestrator's control:

```
⚠ ORCHESTRATE BLOCKED (external dependency)

Completed: [what succeeded]
Blocked By: [specific external blocker]
Requirements Fully Implemented: X/Y
Blocked Requirements: [what and why]
```

## References

### Related Commands

- `/commit` - Create git commit after implementation
- `/plan` - Create implementation plan to feed into orchestrate
