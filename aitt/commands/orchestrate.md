---
name: orchestrate
description: Implementation coordinator that drives plan execution via subagents
category: orchestration
version: 2.9
schema: aitt/commands/cmd.md
model: opus
input:
  expects: "Path to implementation plan markdown file"
  required: true
  format: free-text
---

> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.

# Orchestrate

> Implementation coordinator that fully implements a plan to production quality using subagents, with intelligent verification that adapts to project capabilities.

## Purpose

Fully implement the plan at the provided path **exclusively through subagents**. You are orchestrating the work of subagents.

**Your role:**
- Read and analyze the plan
- Decompose work into tasks and write task specifications
- Launch subagents via the Task tool
- Monitor progress and forward results between dependent subagents
- Validate that implementation meets all original requirements

**You are forbidden from:**
- Using Edit/Write on source code files
- Using Bash to run tests, linters, builds, or any verification commands
- Implementing, debugging, or investigating errors directly
- Any hands-on action, regardless of how trivial it seems

If you catch yourself reaching for Edit/Write or Bash—STOP and delegate to a subagent.

**Use when:**
- Implementing a multi-phase feature from a detailed plan
- Coordinating parallel implementation across multiple files/modules

**Do not use when:**
- Simple single-file changes or quick bug fixes
- Exploratory research tasks

## Key Principles

### Execution Model

**Implementer + Orchestrator Verification:**
Each implementer subagent writes code and generates migration files (if schema changes are involved). The orchestrator then applies migrations via a dedicated subagent before launching a verification subagent to run CLI checks (unit tests, typecheck, lint). When a milestone has no schema changes, the implementer can self-verify inline. A dedicated final verifier is launched once after all milestones for comprehensive testing.

**Adaptive Verification (most to least efficient):**
1. Unit tests and automated test suites
2. CLI/script execution (API endpoints, command-line tools)
3. Browser-based testing via Chrome Devtools MCP
4. Full E2E testing via Playwright/Selenium

**Migration-First Execution:**
When a milestone involves database schema changes, migrations must be generated and applied *before* self-verification runs. Code that depends on new columns, tables, or relations cannot be tested against an outdated schema. Implementers include migration generation as part of their implementation work. The orchestrator ensures migrations are applied (via a subagent) before any verification step that depends on the new schema. When possible, break schema-dependent work into smaller increments: generate migration → apply → implement code → verify. This keeps the feedback loop tight and prevents the "build everything blind, hope it works" anti-pattern.

**Complete Execution — No Deferral:**
Every plan item MUST be fully implemented. If a task proves harder than expected, solve it—don't defer it. The final requirements validation treats any deferred or missing item as mandatory work.

**Server Health Invariant:**
A broken dev server is a broken feedback loop. If the dev server crashes, fails to start, or becomes unresponsive at any point during implementation — whether from a code change, a new endpoint, a missing dependency, a schema mismatch, or any other cause — the responsible subagent (or a dedicated recovery subagent) must diagnose and fix the issue before any further implementation work proceeds. Continuing to write code against an untestable system is forbidden. This applies to every phase: implementer self-verification, milestone transitions, and final verification. The orchestrator treats a non-running server as a blocking failure equivalent to failing tests — no milestone can advance while the server is down.

### Communication

**Subagent Reporting:**
Reports must be detailed enough that the orchestrator and subsequent subagents can continue work without re-reading the codebase. Include: functional summary, requirements addressed, all files changed with what changed in each, key type signatures and API contracts introduced, patterns and conventions chosen, and any decisions that affect downstream work. Don't dump entire file contents, but do include the specific signatures, interfaces, and contracts that other agents need to build on.

**Inter-Subagent Communication:**
The orchestrator reads each report, extracts what the next subagent needs, and includes it in the next task's `context_from_previous` field. The quality of this handoff depends entirely on report detail — a vague report forces the next agent to rediscover context, wasting tokens and risking inconsistency.

### Code Standards

**Simplicity:**
Prefer the smallest solution that meets the plan. No code duplication, no speculative abstractions. Reuse existing primitives; match existing code style, patterns, and conventions.

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
5. **Work breakdown** — Epics → tasks

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
| DB migrations | `package.json` scripts (db:migrate, db:push, db:generate), Drizzle/Prisma/Knex config, migration directories | Milestone execution — run before self-verification |

Detection priority: `package.json` scripts → test config files → test directories → E2E screenshot fixtures → API route definitions → MCP server availability → dead code analyzer → migration config/scripts.

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
    - epic: "Epic Name"
      tasks:
        - name: "Task name"
          files: [affected files]
          depends_on: [task names]
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
2. **Parallelizable task groups** — Tasks within a milestone that can run concurrently (no file conflicts)
3. **Definition of done** — Per milestone: what must be implemented and what self-verification must pass
4. **Verification strategy** — Based on detected capabilities (see below)
5. **Model selection** — Per task (see below)

#### Verification Strategy

**Per milestone:**
1. Implementers generate migration files (if schema changes involved) and write code
2. Orchestrator applies migrations via a dedicated subagent before verification
3. Verification subagent runs CLI checks (unit tests, typecheck, lint, API tests)

This ensures code is always verified against the actual database state — never against a stale schema.

**Once after all milestones (dedicated final verifier):**
Full verification — all CLI tests, runtime startup check, E2E tests, browser testing via Chrome Devtools MCP (if feature has UI).

**Skip UI verification for:** Backend/API-only changes, config/data changes, library/utility code.

#### Model Selection

| Task Type | Model |
|-----------|-------|
| Architecture decisions, risky refactors | Opus |
| New component scaffolding, complex tasks | Opus |
| Straightforward implementation, tests, config | Opus |
| Verification tasks | Opus |

---

### Step 3: Define Task Templates

Define the task specifications that will be filled in for each subagent during execution. Three templates are needed: implementers (used per-milestone in Step 5), a final verifier (used once in Step 7), and a requirements validator (used once in Step 8).

Every subagent receives the plan file path so it has full context of the overall feature being built.

#### Implementer Task Spec

For every implementer task, provide:

```yaml
task_spec:
  plan_file: "path/to/plan.md"  # Always include — gives subagent full feature context
  name: "Task name"
  scope: "What to implement"
  original_requirements:
    - "Requirement 1 this task addresses"
    - "Requirement 2 this task addresses"
  files_affected: [list of file paths]

  # REQUIRED for dependent tasks — orchestrator populates from previous report
  context_from_previous:
    summary: "What was built before this task"
    artifacts:
      - type: "types" | "api" | "component" | "schema" | "config"
        location: "path/to/file.ts"
        details: "Key signatures or contracts"
    decisions:
      - "Decision made by previous agent and why"
    raw_report: |
      [Relevant excerpt from previous subagent's report]

  discovery:
    requirement: |
      Before implementing new functionality, search the codebase for existing code to reuse or extend:
      1. Search for existing functions, classes, utilities, and helpers that overlap with what you're about to build
      2. Search for existing type definitions, interfaces, and constants that can be reused
      3. Check shared packages and libraries for primitives that cover your use case
      4. If a suitable existing implementation exists, extend or wrap it — do not create a parallel version
      5. Document in your report what you found and whether you reused, extended, or had to build from scratch

  constraints:
    - "Follow existing code style"
    - "No new dependencies unless required"
    - "Match error handling patterns"
    - "No code duplication or speculative abstractions"
    - "Search for and reuse existing definitions before creating new ones"
  required_tests: [list of test requirements]
  expected_outputs: [list of artifacts]

  # Database migration handling — include only when task involves schema changes.
  # Implementers generate migration files as part of their work.
  # The orchestrator applies migrations via a separate subagent before self-verification.
  migration:
    has_schema_changes: true/false
    migration_steps:
      - "Generate migration files (e.g., pnpm social:db:generate)"
      - "Migration files to be applied by orchestrator before verification"
    note: |
      If your task modifies database schema (new tables, columns, relations, indexes):
      1. Update the schema file as part of your implementation
      2. Generate migration files using the project's migration tool
      3. Report the migration files in your handoff notes
      4. Do NOT apply migrations yourself — the orchestrator handles this
      Self-verification will run AFTER the orchestrator applies your migrations.

  # Self-verification: implementer runs these AFTER migrations have been applied.
  # Subagents inherit CLAUDE.md — they know the project's test/lint/typecheck commands.
  self_verification:
    checks: [unit tests, typecheck, lint]
    api_tests: [endpoints to curl, if applicable]
    requirement: "All checks must pass. Fix issues and re-run until green."
    precondition: "Migrations (if any) must be applied before running these checks."
    server_health: |
      After your changes, if the dev server is running (or needs to be running for verification):
      1. Verify the dev server starts and stays running without crashes
      2. If it crashes or fails to start — diagnose the root cause, fix it, and confirm it runs
      3. Do NOT report completion while the server is in a broken state
      4. If your changes introduced a new endpoint or modified routing, verify the server
         accepts the new routes without errors
      This is a blocking requirement — a broken server means your task is not done.

  report_format: |
    ## Implementation Report: [Task Name]

    ### Discovery Results
    [What existing code was found and reused/extended. What had to be built from scratch and why.]

    ### What Was Implemented
    [Functional description — what the user can now do]

    ### Requirements Addressed
    - ✓ Requirement 1: [how it's satisfied]

    ### Changes Made
    - `path/to/file.ts`: [what changed and why]
    - `path/to/other.ts`: [what changed and why]

    ### Key Artifacts Introduced
    [Type signatures, interfaces, function signatures, API contracts,
     data structures, or configuration that other code depends on.
     Include the actual signatures — not just "added types to file.ts"
     but the signatures themselves so downstream agents can use them.]

    ### Migrations Generated (if applicable)
    - `path/to/migration-file.sql`: [what it does]
    - Migration must be applied before verification can run

    ### Self-Verification Results
    - Migrations applied: yes/no/not-needed
    - Unit tests: pass/fail
    - Typecheck: pass/fail
    - Lint: pass/fail
    - Server health: confirmed-running/not-applicable
    - [Issues fixed during verification, if any]

    ### Handoff Notes
    [REQUIRED for downstream tasks. Summarize:
     - What was built and where (file paths + purpose)
     - Key signatures and contracts the next agent needs to use or extend
     - Patterns and conventions established (naming, error handling, etc.)
     - Decisions made and their rationale
     - Anything the next agent should know to avoid breaking this work
     The orchestrator extracts this section and passes it to
     dependent subagents via context_from_previous.]
```

#### Final Verifier Spec

Used once in Step 7, after all milestones and code cleanup:

```yaml
final_verifier_spec:
  plan_file: "path/to/plan.md"  # Always include — gives subagent full feature context
  name: "Final Verification: [Feature Name]"
  original_requirements: [ALL requirements from plan]

  # Subagents inherit CLAUDE.md — they know the project's specific commands.
  # Specify WHAT to verify, not HOW (no hardcoded commands).
  cli_verification:
    checks: [unit tests, typecheck, lint]
    api_tests: [endpoints with expected status codes]

  runtime_verification:
    startup: "Start the dev server, verify no crashes within 30s"
    smoke_test:
      - "Key pages load without 500s or white screens"
      - "API endpoints return expected response shapes"
      - "No module resolution errors at runtime"
    shutdown: "Stop the dev server after verification"

  ui_verification:  # Only if feature has UI components
    required: true/false
    skip_reason: "backend-only" | null
    e2e_tests:
      screenshots:
        enabled: true/false
        review_action: "Read screenshots with AI to verify visual appearance"
    browser_testing:
      url: "http://localhost:PORT/path"
      scenarios:
        - "Happy path walkthrough"
        - "Edge cases"
        - "Error states"

  failure_handling: "Fix issues and re-verify. CLI must pass before runtime. Runtime must pass before UI."

  report_format: |
    ## Final Verification Report

    ### CLI Results
    [pass/fail for each check]

    ### Runtime Results
    [Startup status, smoke test results]

    ### UI Results (if applicable)
    [E2E results, screenshot review, browser testing]

    ### Requirements Verified
    - ✓ Requirement 1: [verification method]

    ### Issues Found and Fixed
    [Any problems resolved during verification]
```

#### Requirements Validator Spec

Used once in Step 8, after final verification passes:

```yaml
requirements_validator_spec:
  plan_file: "path/to/plan.md"  # Always include — validator reads the plan to extract all requirements
  name: "Requirements Validation: [Feature Name]"
  final_verifier_report: |
    [Full report from the final verifier subagent]
  implementer_reports: |
    [Summary of all implementer reports — what was built, where, how verified]

  task: |
    Read the plan file and extract every requirement and acceptance criterion.
    For each one, determine whether it is fully satisfied by searching the codebase
    for implementation evidence and cross-referencing with the verification reports.

  checks:
    - "Every requirement from the plan is mapped to implementation evidence (file:line)"
    - "Every acceptance criterion has a corresponding verification result"
    - "No requirement is marked as deferred, partial, or known limitation"
    - "No requirement was silently dropped or overlooked"

  report_format: |
    ## Requirements Validation Report

    ### Requirements Traceability
    - ✓ Requirement 1: implemented in `path/file.ts:line`, verified by [method]
    - ✓ Requirement 2: implemented in `path/file.ts:line`, verified by [method]
    - ✗ Requirement 3: NOT satisfied — [what's missing]

    ### Acceptance Criteria
    - ✓ Criterion 1: [evidence]
    - ✓ Criterion 2: [evidence]

    ### Gaps Found
    [List of any requirements not fully satisfied, with details on what's missing]

    ### Verdict
    ALL SATISFIED | GAPS FOUND (list count)
```

---

### Step 4: Checkpoint — Ready to Execute

> **GATE:** Do not proceed until satisfied.

- [ ] All tasks assigned with implementer specs
- [ ] Dependencies between tasks identified
- [ ] Parallel groups identified
- [ ] Model selection justified
- [ ] Self-verification checks specified per implementer (what to verify, not specific commands)

**If not satisfied:** Return to Step 2

---

### Step 5: Execute Milestones

For each milestone in order, execute the implementation and verify results before moving on.

#### Per Milestone

1. **Prepare task specs** — Fill in the implementer template from Step 3 with task-specific details
2. **Launch implementer subagents** — Via the Task tool, with parallel launches where no file conflicts exist. Implementers write code AND generate migration files (if schema changes are involved), but do NOT apply migrations or run self-verification yet.
3. **Forward results** — When a subagent completes and the next depends on it:
   - Read the completed subagent's Handoff Notes
   - Populate `context_from_previous` in the next task spec
   - Launch the dependent subagent with full context
4. **Apply migrations** — If any implementer in this milestone generated migration files:
   - Launch a migration subagent to back up the database and run all pending migrations
   - Wait for confirmation that migrations applied successfully
   - If migration fails → launch a fix subagent to resolve schema issues, then re-apply
5. **Run self-verification** — Launch a verification subagent to run CLI checks (unit tests, typecheck, lint) against the now-migrated database. This subagent also fixes any issues it finds.
6. **Verify server health** — If the dev server should be running (or needs to run for this milestone's verification), confirm it starts and stays running. If it crashes or fails to start after the milestone's changes, launch a recovery subagent to diagnose and fix the issue before advancing. No milestone transition is allowed while the server is broken.
7. **If pass** → Proceed to next milestone
8. **If fail** → Launch a fix subagent to resolve issues and re-verify

#### Migration Timing

The default flow above batches migrations per milestone. For milestones with multiple schema-dependent tasks, use a tighter loop:

```
Task A (schema change) → generate migration → apply migration → Task B (depends on A's schema) → generate migration → apply migration → verify all
```

Choose the granularity based on task dependencies:
- **Batch per milestone** — When tasks in the milestone don't depend on each other's schema changes
- **Incremental (per task)** — When a later task depends on an earlier task's schema changes to write correct code. Apply migrations between tasks so the next implementer can read the actual database schema and write verified code against it.

#### Coordination Rules

1. **Parallel work** — Launch concurrent tasks when no file conflicts
2. **Sequential work** — Wait for completion before launching dependent tasks
3. **File ownership** — Never launch parallel tasks that edit the same files
4. **Status tracking** — Track: current milestone, in-progress, blocked, next
5. **No shortcuts** — Even trivial fixes go through the Task tool
6. **Server health is non-negotiable** — If at any point the dev server crashes, fails to start, or becomes unresponsive (due to code changes, new endpoints, dependency issues, etc.), all implementation work stops until the server is restored. The subagent that broke it fixes it. If the cause is unclear, launch a dedicated recovery subagent. Never proceed with implementation against a broken, untestable system.

#### Quality Gates (apply to all subagent work)

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

### Step 6: Code Cleanup

After all milestones pass, launch a cleanup subagent before final verification:

1. **Remove dead code** — If a dead code analyzer was detected (e.g. knip, ts-prune), run it first to get an authoritative list of unused exports, imports, variables, functions, and types. Otherwise, use grep/search to find them manually. Also remove commented code blocks.
2. **Fix code duplication** — Scan all files changed during this implementation for duplicated logic, copy-pasted blocks, and near-identical patterns. Extract shared helpers, consolidate repeated code paths, and ensure no two places implement the same logic independently. Compare new code against pre-existing utilities and abstractions — if something already exists that covers the same concern, refactor to use it instead of keeping the duplicate.
3. **Remove debug artifacts** — `console.log`/`debug`/`debugger` statements, TODO/FIXME from this implementation
4. **Remove temp artifacts** — Temp files, scripts, one-time migration scripts
5. **Remove leftover functionality** — Feature flags for testing, experimental code paths, stub implementations, dead conditional branches
6. **Update documentation** — README.md if new scripts/commands; CLAUDE.md if new patterns

Cleanup runs BEFORE final verification so any breakage from code removal is caught. Items that look dead but might be needed (public API, dynamic imports) should be preserved with justification.

---

### Step 7: Final Verification

After cleanup, launch a dedicated final verifier subagent using the spec from Step 3.

Verification order:
1. **CLI tests** — All unit tests, typecheck, lint pass
2. **Runtime check** (always) — Dev server starts, no crashes, key pages/endpoints respond, no 500s or module errors
3. **UI verification** (only if feature has UI) — E2E tests, screenshots with AI review, Chrome MCP browser testing, full feature walkthrough

If issues found → fix and re-verify. Continue until the project runs AND all tests pass.

---

### Step 8: Requirements Validation

Launch a dedicated requirements validator subagent using the spec from Step 3. Provide it with the plan file, all implementer reports, and the final verifier report.

The validator independently reads the plan, extracts every requirement and acceptance criterion, and searches the codebase for implementation evidence. It produces a traceability report.

**If all requirements satisfied** → Proceed to Step 9.
**If gaps found** → Create new implementer tasks for each gap, include context from prior work, launch subagents, re-run verification (Steps 5-7), then re-run validation until all requirements are met.

---

### Step 9: Completion

When all acceptance criteria are met, requirements validation passes, and code is clean:

1. **Produce final report** (see Outputs)
2. **Produce release checklist** for merge/deploy

## Outputs

### Final Report Schema

```yaml
completion_report:
  summary: "What was implemented"

  requirements_traceability:
    - requirement: "Original requirement"
      status: "satisfied"
      implementation: "path/to/file.ts:line"
      verification: "unit_test" | "api_test" | "e2e" | "browser"

  milestones_completed:
    - name: "Milestone"
      tasks: [completed tasks]
      self_verification: "pass"

  testing:
    cli: { unit_tests: "pass", typecheck: "pass", lint: "pass" }
    runtime: { startup: "pass", smoke_test: ["/ → 200", "/feature → 200"], errors: "none" }
    ui: { method: "playwright" | "chrome_mcp" | "skipped", results: "pass", screenshots: [reviewed files] }

  code_cleanup:
    dead_code_removed: [items]
    debug_artifacts_removed: [items]
    temp_files_deleted: [items]
    documentation_updated: [items]

  quality_notes: { simplicity: "...", duplication: "...", maintainability: "..." }
  risks_limitations: [any known limitations]

  release_checklist:
    - "All requirements met"
    - "All tests passing"
    - "Project runs (dev server + smoke tests)"
    - "Code cleanup complete"
    - "Documentation updated"
    - "Ready for merge"
```

## Examples

### Basic Usage

```
/orchestrate docs/plans/feature-name.md
```

### Example Execution Flow

```
1. Analyze plan: docs/plans/feature-name.md
   → 3 phases, 12 tasks, 2 parallel groups
   → Capabilities: vitest, playwright, Chrome MCP, knip

2. Execution strategy:
   → Per milestone: implementer self-verifies (CLI)
   → Final: CLI + runtime + E2E + Chrome MCP
   → Phase 1: Opus | Phase 2-3: Sonnet

3. Execute milestones:
   Phase 1: Foundation
     → Schema + migration generated
     → DB backed up, migration applied ✓
     → Types + repository implemented
     → Self-verification pass ✓
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
   → CLI: all pass
   → Runtime: server starts on :3010, smoke tests pass
   → UI: E2E pass, screenshots reviewed, Chrome MCP walkthrough pass

6. Requirements validation: 3/3 satisfied

✓ IMPLEMENTATION COMPLETE — ready for review
```

## Error Handling

### ERR-001: Plan File Not Found

**Cause:** Invalid path or file doesn't exist
**Resolution:** Verify path, check for typos, ensure `.md` extension

---

### ERR-002: Subagent Failure

**Cause:** Syntax errors, test failures, missing dependencies
**Resolution:**
1. Read the subagent's error output
2. Identify the specific issue
3. Adjust the task spec or approach
4. Re-launch subagent

---

### ERR-003: Verification Loop Stuck

**Cause:** Unclear requirements or conflicting constraints
**Resolution:**
1. Document the specific failure
2. Assess if the requirement is achievable
3. Adjust approach or flag for manual review

---

### ERR-004: File Conflict

**Cause:** Multiple subagents editing the same file
**Resolution:** Stop conflicting subagents, sequence them instead

---

### ERR-005: Cleanup Breaks Tests

**Cause:** Removed code that was actually used
**Resolution:**
1. Identify which removal caused the failure from git diff
2. Restore the removed code
3. Document why it appeared dead but wasn't
4. Re-run cleanup with updated understanding

If uncertain about removal (public API, dynamic imports, reflection): preserve with justification and flag for human review.

---

### ERR-006: Dev Server Crash or Failure to Start

**Cause:** Code changes introduced a runtime error, missing import, broken route, schema mismatch, or dependency issue that prevents the dev server from running.

**Resolution:**
1. Stop all in-progress implementation work — do not write more code against a broken system
2. Read the server's error output (crash logs, stack trace, startup errors)
3. Identify the specific change that caused the failure (check recent subagent changes)
4. Launch a recovery subagent with the error context and a mandate to fix the server
5. Recovery subagent diagnoses root cause, applies fix, and confirms the server starts and stays running
6. Only after server health is confirmed, resume implementation work
7. If the fix requires reverting a subagent's changes, revert and re-implement with a corrected approach

## Summary

```
✓ ORCHESTRATE COMPLETE

[1-2 sentence summary]

Milestones: X/Y completed
Verification:
  - Implementer self-verification: all pass
  - Final CLI: pass
  - Runtime: starts and runs, smoke tests pass
  - Final UI: pass | skipped (backend-only)

Requirements: X/X satisfied

Code Cleanup:
  - Dead code removed: X items
  - Debug artifacts: Y removed
  - Temp files: N deleted
  - Documentation: updated | no changes needed

Quality: [brief assessment]

Release Checklist:
- [ ] All requirements met
- [ ] All tests passing
- [ ] Project runs
- [ ] Code cleanup complete
- [ ] Documentation updated
- [ ] Ready for merge
```

**"Partially complete" is NOT a valid final state.** If any requirements remain unmet, loop back to create new tasks. Only use the blocked status for genuine external dependencies outside the orchestrator's control:

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
