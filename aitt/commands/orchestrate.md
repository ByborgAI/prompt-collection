---
name: orchestrate
description: Implementation coordinator that drives plan execution via subagents
category: orchestration
version: 2.2
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

---

**ABSOLUTE RULE: The orchestrator (you) CANNOT write code, debug, or verify. ONLY subagents can.**

- Orchestrator: coordinates, plans, delegates, monitors results
- Subagents: write ALL code, run ALL debugging, perform ALL verification

This is non-negotiable. No exceptions. No "just this once."

---

## Purpose

Fully implement the plan at the provided path to production quality **exclusively through subagents**. You are the conductor—subagents are the musicians. You coordinate, delegate, and verify; subagents do ALL implementation work.

**CRITICAL RULE: You MUST NOT write implementation code directly.**

Your role is strictly limited to:
- Reading and analyzing the plan
- Decomposing work into tasks
- Writing task specifications for subagents
- Launching subagents via the Task tool
- Monitoring progress and coordinating handoffs
- Reviewing subagent reports (NOT running commands yourself)
- Synthesizing final reports
- **Validating that implementation meets original requirements**

**You are FORBIDDEN from:**
- Using Edit/Write tools on source code files
- Using Bash to run tests, linters, or any verification commands
- Using Bash to debug or investigate errors directly
- Implementing "just this one small thing" yourself
- "Helping out" with implementation when subagents struggle
- Running `pnpm test`, `pnpm lint`, `pnpm build`, etc. directly

If you catch yourself reaching for Edit/Write on source files, or Bash to run tests/linters/builds—STOP. Delegate to a subagent instead.

**Use when:**
- Implementing a multi-phase feature from a detailed plan
- Coordinating parallel implementation work across multiple files/modules
- Ensuring consistent quality gates and verification across implementation

**Do not use when:**
- Simple single-file changes
- Quick bug fixes
- Exploratory research tasks

## Key Principles

**Mandatory Delegation:**
ALL implementation work MUST go through subagents. The orchestrator's job is to coordinate, not to code. Every line of implementation code should be written by a subagent launched via the Task tool.

**Anti-Pattern to Avoid:**
- **Wrong:** "This is just a small change, I'll do it myself to save time"
- **Correct:** Create a task spec and launch a subagent, no matter how small the change

**Adaptive Verification Strategy:**
Verification should use the most efficient approach available. CLI-based testing (unit tests, API calls, scripts) is faster and more reliable than UI testing. Always start with CLI verification; only escalate to UI testing when CLI tests pass or when the feature requires visual/interaction verification.

**Verification Hierarchy (most to least efficient):**
1. Unit tests and automated test suites
2. CLI/script execution (API endpoints, command-line tools)
3. Browser-based testing via Chrome MCP
4. Full E2E testing via Playwright/Selenium

**Subagent Reporting Protocol:**
Every subagent MUST report what it implemented in a clear, functional summary. Reports should focus on:
- **What was implemented** (functionality and concept)
- **How it meets requirements** (mapping to acceptance criteria)
- **Verification results** (what passed, what failed)
- Code snippets ONLY when necessary for another agent to continue work

**Anti-Pattern to Avoid (Reporting):**
- **Wrong:** Dumping entire file contents or verbose code blocks
- **Correct:** Summarize functionality, reference file:line for details

**Clean, Simple, Maintainable:**
Prefer the smallest solution that meets the plan. No gold-plating.

**No Code Duplication:**
Reuse existing primitives/components; factor shared logic into well-named utilities only when it removes real repetition in ≥2 places.

**No Over-Engineering:**
No speculative abstractions, frameworks, or "future-proofing" unless explicitly required by the plan.

**Consistency:**
Match existing code style, patterns, naming, file structure, and error-handling conventions.

**Anti-Pattern to Avoid (Code Quality):**
- **Wrong:** Creating a generic utility "for future use" when only one call site exists
- **Correct:** Write the specific code inline; extract only when duplication actually occurs

**Requirements Traceability:**
At completion, every original requirement must be demonstrably met. The orchestrator tracks requirements → implementation → verification as a chain. Nothing is "done" until verified against the original plan.

**Code Hygiene:**
Before declaring completion, ensure the codebase is clean. Remove all dead code, unused exports, debug logs, temp scripts, and leftover functionality from experimentation. The final state should contain only what's necessary for the implemented feature—nothing more.

**Anti-Pattern to Avoid (Code Hygiene):**
- **Wrong:** Leaving `console.log` statements, commented-out code, or unused functions "just in case"
- **Correct:** Remove everything not needed; version control preserves history if needed later

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

**Check:** Verify the provided path resolves to a readable markdown file
**Pass:** Proceed to Gate 2
**Fail:** Exit with error

**Fail Output:**
```
Plan file not found: <path>
Verify the path and try again.
```

---

### Gate 2: Plan File Contains Actionable Content

**Check:** Plan has identifiable tasks, phases, or checklist items
**Pass:** Proceed to Process
**Fail:** Exit with guidance

**Fail Output:**
```
Plan file lacks actionable structure.
Expected: phases, checklist items, or task breakdown.
Review the plan and add implementation details.
```

## Process

### Step 1: Ingest & Decompose

Read the plan file thoroughly and extract:

1. **Requirements** - What must be built
2. **Acceptance criteria** - How to verify success
3. **Dependencies** - What must exist before implementation
4. **Risks** - What could go wrong
5. **Work breakdown** - Epics → tasks

#### Project Capability Detection

Before planning verification, detect available testing capabilities by checking:

| Capability | Detection Method | Verification Approach |
|------------|------------------|----------------------|
| Unit tests | `package.json` scripts (test, jest, vitest, mocha) | Run test suite |
| API endpoints | Route files, OpenAPI specs, server code | CLI calls via curl/httpie |
| CLI scripts | `package.json` scripts, `scripts/` folder | Direct execution |
| Playwright | `playwright.config.*`, `@playwright/test` dependency | Run E2E suite |
| Selenium | `selenium-webdriver` dependency, test configs | Run E2E suite |
| Chrome MCP | MCP server availability | Browser-based verification |

**Detection Priority:**
1. Check `package.json` for test scripts and testing dependencies
2. Look for test configuration files (`jest.config.*`, `vitest.config.*`, `playwright.config.*`)
3. Scan for test directories (`__tests__/`, `tests/`, `e2e/`, `spec/`)
4. Check for API route definitions (enables CLI-based API testing)
5. Verify MCP server availability for browser testing

#### Unknowns Handling

If critical information is missing:
- Make reasonable assumptions
- Document assumptions explicitly
- Proceed without stalling

#### Output Schema

```yaml
plan_analysis:
  requirements: [list of requirements]
  acceptance_criteria: [list of criteria]
  dependencies: [list of dependencies]
  risks: [list of identified risks]
  work_breakdown:
    - epic: "Epic Name"
      tasks:
        - name: "Task name"
          files: [affected files]
          depends_on: [task names]
  verification_capabilities:
    unit_tests:
      available: true/false
      command: "pnpm test" | null
      framework: "jest" | "vitest" | etc.
    api_testing:
      available: true/false
      endpoints: [list of testable endpoints]
    cli_scripts:
      available: true/false
      scripts: [list of available scripts]
    e2e_testing:
      available: true/false
      framework: "playwright" | "selenium" | null
      command: "pnpm test:e2e" | null
    browser_testing:
      available: true/false
      method: "chrome_mcp" | null
```

---

### Step 2: Plan Execution & Verification Strategy

Produce a concise execution plan with:

1. **Ordered milestones** - Sequential phases
2. **Parallelizable task groups** - What can run concurrently
3. **Definition of done** - Per milestone
4. **Verification strategy** - Tailored to detected capabilities

#### Verification Strategy Selection

Based on detected capabilities from Step 1, apply a **tiered verification strategy**:

```
┌─────────────────────────────────────────────────────────────┐
│           VERIFICATION STRATEGY (TWO TIERS)                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  MILESTONE VERIFICATION (after each milestone)             │
│  ─────────────────────────────────────────────             │
│  CLI-only, fast feedback:                                  │
│     ├── Unit tests (pnpm test)                             │
│     ├── Type checking (pnpm typecheck)                     │
│     ├── Linting (pnpm lint)                                │
│     └── API endpoint tests via curl/scripts                │
│                                                             │
│  FINAL VERIFICATION (once, after all milestones)           │
│  ─────────────────────────────────────────────             │
│  Full verification including UI:                           │
│     ├── All CLI tests from milestone verification          │
│     ├── E2E tests (Playwright/Selenium) if available       │
│     ├── Browser testing via Chrome MCP                     │
│     └── Full feature walkthrough                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Why This Approach:**
- **Milestone verification** catches issues early with fast CLI feedback
- **Final verification** ensures the complete feature works end-to-end
- Avoids slow E2E runs after every small change
- Browser testing is expensive—save it for when it matters most

**Strategy Selection Rules:**
- **After each milestone** → CLI tests only (unit, lint, typecheck, API curl)
- **Final verification** → CLI tests + E2E + browser testing (if UI exists)
- **Backend-only features** → Skip UI testing entirely
- **API/service changes** → Skip UI testing (curl/scripts sufficient)
- **Config/data changes** → Skip UI testing
- **Frontend components** → Include UI testing in final verification
- **Full-stack features with UI** → Include UI testing in final verification

#### Task Assignment

For each task, assign:
- **IMPLEMENTER** subagent - Does the work
- **VERIFIER** subagent - Validates the work using selected strategy

#### Model Selection

| Task Type | Model | Justification |
|-----------|-------|---------------|
| Architecture decisions | Opus | Complex reasoning required |
| Risky refactors | Opus | High-stakes changes |
| New component scaffolding / complex task | Opus | Design decisions |
| Straightforward implementation | Sonnet | Well-defined scope |
| Test writing | Sonnet | Clear patterns |
| Config changes | Sonnet | Low complexity |
| Verification tasks | Sonnet | Pattern-based execution |

---

### Step 3: Subagent Orchestration

#### Implementer Task Spec

For every implementer task, provide:

```yaml
task_spec:
  name: "Task name"
  scope: "What to implement"
  original_requirements:
    - "Requirement 1 this task addresses"
    - "Requirement 2 this task addresses"
  files_affected: [list of file paths]
  constraints:
    - "Follow existing code style"
    - "No new dependencies unless required"
    - "Match error handling patterns"
  simplicity_guidance:
    - "No code duplication"
    - "No speculative abstractions"
    - "Smallest solution that works"
  required_tests: [list of test requirements]
  expected_outputs: [list of artifacts]
  rollback_notes: "How to undo if needed"

  # Reporting requirements for the subagent
  reporting_requirements:
    must_include:
      - "Summary of what was implemented (functionality, not code)"
      - "Which original requirements are now satisfied"
      - "Files modified with brief description of changes"
      - "Any new tests added"
      - "Any assumptions made"
    must_exclude:
      - "Full file contents (reference file:line instead)"
      - "Verbose code blocks (unless needed for next agent)"
    format: |
      ## Implementation Report: [Task Name]

      ### What Was Implemented
      [Functional description - what the user can now do]

      ### Requirements Addressed
      - ✓ Requirement 1: [how it's satisfied]
      - ✓ Requirement 2: [how it's satisfied]

      ### Changes Made
      - `path/to/file.ts`: [brief description]
      - `path/to/test.ts`: Added tests for [what]

      ### Verification Notes
      [Any manual verification performed, CLI tests run]

      ### Handoff Notes (if applicable)
      [Only include code snippets if next agent needs them]
```

#### Verifier Task Spec

There are **two types of verifier tasks**—use the appropriate spec:

##### Milestone Verifier Spec (CLI-only, after each milestone)

```yaml
milestone_verifier_spec:
  name: "Milestone Verification: [Milestone Name]"
  type: "milestone"  # CLI-only verification
  original_requirements:
    - "Requirements addressed in this milestone"

  cli_verification:
    unit_tests:
      command: "pnpm test"
      expected: "all tests pass"
    typecheck:
      command: "pnpm typecheck"
      expected: "no errors"
    lint:
      command: "pnpm lint"
      expected: "no errors"
    api_tests:  # If applicable
      endpoints:
        - method: "GET/POST/etc"
          url: "/api/endpoint"
          expected_status: 200
      command: "curl commands or test script"

  failure_criteria:
    - "Any CLI test fails"
    - "Type errors present"
    - "Lint errors present"

  reporting_requirements:
    format: "brief_summary"
    include:
      - "CLI test results (pass/fail)"
      - "Issues found with file:line references"
    exclude:
      - "Full code dumps"
      - "UI testing results (not applicable)"
```

##### Final Verifier Spec (Full verification, once after all milestones)

```yaml
final_verifier_spec:
  name: "Final Verification: [Feature Name]"
  type: "final"  # Full verification including UI
  original_requirements:
    - "ALL requirements from plan"

  cli_verification:
    unit_tests:
      command: "pnpm test"
      expected: "all tests pass"
    typecheck:
      command: "pnpm typecheck"
      expected: "no errors"
    lint:
      command: "pnpm lint"
      expected: "no errors"
    api_tests:
      endpoints: [all relevant endpoints]
      command: "curl commands or test script"

  ui_verification:  # Only if feature has UI components
    required: true/false
    skip_reason: "backend-only" | "api-only" | null
    method: "playwright" | "selenium" | "chrome_mcp"
    e2e_tests:
      command: "pnpm test:e2e" | null
    browser_testing:
      startup: "pnpm dev"
      url: "http://localhost:PORT/path"
      test_scenarios:
        - "Happy path: Full feature walkthrough"
        - "Edge case: [description]"
        - "Error state: [description]"
      use_chrome_mcp: true/false

  failure_criteria:
    - "CLI tests fail → STOP, fix first"
    - "E2E tests fail"
    - "Browser testing finds issues"
    - "Requirements not fully met"

  reporting_requirements:
    format: "comprehensive_summary"
    include:
      - "All CLI test results"
      - "UI test results (if applicable)"
      - "Which requirements are satisfied"
      - "Any issues found with file:line references"
    exclude:
      - "Full code dumps"
      - "Verbose logs unless debugging"
```

**Verification Flow:**

1. **After each milestone** → Launch milestone verifier (CLI-only)
   - Run unit tests, typecheck, lint
   - Test API endpoints if applicable
   - Fix issues, re-run until pass
   - **No UI testing at this stage**

2. **After ALL milestones complete** → Code cleanup first
   - Remove dead code, debug artifacts, temp files
   - Update documentation if needed
   - **Cleanup before verification catches breakage**

3. **After cleanup** → Launch final verifier
   - Run all CLI tests (comprehensive)
   - Run E2E tests if available and applicable
   - Browser testing via Chrome MCP if UI exists
   - Full feature walkthrough
   - Fix issues, re-run until pass

4. **When to skip UI verification:**
   - Backend/API-only changes
   - Config or data changes
   - Library/utility code
   - No user-facing changes

---

### Step 4: Checkpoint — Execution Plan Ready

> **GATE:** Do not proceed until satisfied.

- [ ] All tasks assigned to implementer + verifier
- [ ] Dependencies between tasks identified
- [ ] Parallel groups identified
- [ ] Model selection justified for each task

**If not satisfied:** Return to Step 2

---

### Step 5: Execute Implementation

Launch subagents **using the Task tool** according to the execution plan.

**REMINDER: You MUST use the Task tool for ALL implementation.**

#### How to Launch Subagents

Use the Task tool with `subagent_type: "general-purpose"` for implementation:

```
Task tool call:
  subagent_type: "general-purpose"
  description: "Implement [task name]"
  prompt: |
    [Full task spec from Step 3]

    Implementation requirements:
    - Files to modify: [list]
    - Expected behavior: [description]
    - Tests to add/update: [list]

    When complete, run verification commands and report results.
```

#### Coordination Rules

1. **Parallel work** - Launch concurrent Task calls when no file conflicts
2. **Sequential work** - Wait for Task completion before launching dependent tasks
3. **File ownership** - Never launch parallel Tasks that edit same files
4. **Status updates** - Track: current milestone, in-progress, blocked, next
5. **No shortcuts** - Even "trivial" fixes must go through Task tool

#### Quality Gates (Non-Negotiable)

**Functionality:**
- Features work per plan + acceptance criteria
- No partial implementations

**Correctness & Safety:**
- Input validation at system boundaries
- Error handling consistent with codebase
- No security vulnerabilities

**Code Quality:**
- No copy/paste duplication
- No unnecessary layers/patterns
- Clear file responsibilities
- Small, readable functions
- No dead code or unused exports
- No unused imports or variables
- No commented-out code blocks

**Code Hygiene:**
- No `console.log`, `console.debug`, or debug statements
- No TODO/FIXME comments from this implementation (existing ones OK)
- No temp scripts or files created during implementation
- No leftover experimental code paths
- No orphaned helper functions
- No unused type definitions or interfaces

**Testing & Tooling:**
- All tests pass locally
- Lint/format/typecheck pass
- No noisy logs in production code

**Documentation:**
- README.md updated if new commands, scripts, or setup steps added
- CLAUDE.md updated if new patterns, conventions, or AI-relevant context added
- Keep updates brief—document what exists, not implementation details

---

### Step 6: Milestone Verification Loop

After **each milestone** (not after final):

1. Launch **milestone verifier** subagent with CLI-only spec
2. Verifier performs CLI verification only:
   - Unit tests (pnpm test)
   - Type checking (pnpm typecheck)
   - Linting (pnpm lint)
   - API tests via curl/scripts (if applicable)
3. If issues found:
   - Verifier fixes directly (has Edit/Write access)
   - Re-runs CLI tests
   - Continues until pass
4. If cannot fix → escalate to new implementer

**No UI testing at this stage.** Save it for final verification.

**REMINDER:** ALL verification and fixing happens in subagents. Do NOT run tests yourself.

#### Milestone Verification Flow

```
┌─────────────────┐
│   Implement     │ (subagent)
│   Milestone N   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│      MILESTONE VERIFICATION (CLI only)          │
│  1. pnpm test → unit tests                      │
│  2. pnpm typecheck → type checking              │
│  3. pnpm lint → linting                         │
│  4. curl/scripts → API tests (if applicable)    │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌────────────────────┐
│  All CLI Pass?     │
└────────┬───────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌────────────────────────────────────┐
│  Yes  │  │  No → Fix and re-run CLI tests     │
│       │  └────────────────────────────────────┘
│ PASS  │
│       │
│ → Next│
│ Mile- │
│ stone │
└───────┘
```

---

### Step 6b: Code Cleanup Verification

After all milestones complete and before final verification, run a cleanup sweep to eliminate cruft from the implementation process. **Cleanup happens first because removing code can break behavior**—we need the final verification to catch any issues.

#### Cleanup Verifier Task Spec

```yaml
cleanup_verifier_spec:
  name: "Code Cleanup: [Feature Name]"
  type: "cleanup"

  files_to_scan:
    - "All files modified/created during this implementation"
    - "New test files"
    - "Any temp files or scripts in project root/scripts/"

  dead_code_detection:
    unused_exports:
      method: "Search for exports not imported elsewhere"
      tools: "grep, AST analysis, IDE hints"
    unused_imports:
      method: "Lint errors or IDE warnings"
      action: "Remove all unused imports"
    unused_variables:
      method: "Lint errors, underscore prefix check"
      action: "Remove or properly ignore with underscore"
    orphaned_functions:
      method: "Search for functions never called"
      action: "Remove if not part of public API"
    commented_code:
      method: "Search for multi-line commented blocks"
      action: "Remove (git preserves history)"
    unused_types:
      method: "Search for types/interfaces not referenced"
      action: "Remove if not part of public API"

  debug_artifacts:
    console_statements:
      pattern: "console.log|console.debug|console.info|console.warn(?!.*production)"
      exceptions: "Intentional logging in error handlers or logger utilities"
      action: "Remove all debug logging"
    debugger_statements:
      pattern: "debugger;"
      action: "Remove all"
    todo_comments:
      pattern: "TODO|FIXME|HACK|XXX"
      check: "Are these from THIS implementation or pre-existing?"
      action: "Remove if from this implementation; leave pre-existing"

  temp_artifacts:
    temp_files:
      locations:
        - "Project root (*.tmp, *.bak, *.log)"
        - "scripts/ (temp-*.mjs, test-*.mjs)"
        - ".claude/ or similar"
      action: "Delete all temp files created during implementation"
    temp_scripts:
      pattern: "Files with 'temp', 'test', 'debug', 'scratch' in name"
      check: "Created during this implementation?"
      action: "Delete if created during this implementation"
    migration_scripts:
      check: "One-time scripts that have been run?"
      action: "Delete or move to archive/ if needed for documentation"

  leftover_functionality:
    feature_flags:
      check: "Any feature flags added for testing?"
      action: "Remove if no longer needed, or document if intentional"
    experimental_paths:
      check: "Alternative implementations tried but abandoned?"
      action: "Remove completely"
    stub_implementations:
      check: "Placeholder functions returning dummy data?"
      action: "Either implement properly or remove"
    disabled_code:
      pattern: "if (false) or if (0) or similar"
      action: "Remove dead branches"

  documentation_updates:
    readme_md:
      check: "New scripts, commands, or setup steps added?"
      action: "Add brief entry to relevant section (Scripts Reference, Quick Start, etc.)"
    claude_md:
      check: "New patterns, conventions, or AI-relevant guidelines?"
      action: "Add brief entry to relevant section"
    style: "Brief and factual—what it is, not how it works internally"

  reporting_requirements:
    format: |
      ## Cleanup Report: [Feature Name]

      ### Dead Code Removed
      - `path/file.ts`: Removed unused function `helperXyz`
      - `path/file.ts`: Removed unused import `SomeModule`

      ### Debug Artifacts Removed
      - `path/file.ts:42`: Removed console.log
      - `path/file.ts:87`: Removed debugger statement

      ### Temp Files Deleted
      - `scripts/temp-migration.mjs`: Deleted (one-time script)
      - `test-output.log`: Deleted

      ### Leftover Functionality Removed
      - `path/file.ts`: Removed experimental caching approach

      ### Items Preserved (with justification)
      - `path/file.ts:23`: Kept TODO comment (pre-existing)
      - `utils/logger.ts`: Kept console.warn (intentional error logging)

      ### Documentation Updated
      - `README.md`: Added new script `pnpm xyz` to Scripts Reference
      - `CLAUDE.md`: No updates needed (no new patterns)

      ### Final State
      - Total files cleaned: X
      - Lines removed: ~Y
```

#### Cleanup Flow

```
┌─────────────────────────────────────────────────────────────┐
│              CODE CLEANUP VERIFICATION                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. DEAD CODE SCAN                                          │
│     ├── Unused exports → Remove                             │
│     ├── Unused imports → Remove                             │
│     ├── Unused variables → Remove                           │
│     ├── Orphaned functions → Remove                         │
│     ├── Commented code blocks → Remove                      │
│     └── Unused types/interfaces → Remove                    │
│                                                             │
│  2. DEBUG ARTIFACTS SCAN                                    │
│     ├── console.log/debug → Remove                          │
│     ├── debugger statements → Remove                        │
│     └── New TODO/FIXME comments → Remove                    │
│                                                             │
│  3. TEMP ARTIFACTS SCAN                                     │
│     ├── Temp files (*.tmp, *.bak, *.log) → Delete           │
│     ├── Temp scripts (temp-*, debug-*) → Delete             │
│     └── One-time migration scripts → Delete/Archive         │
│                                                             │
│  4. LEFTOVER FUNCTIONALITY SCAN                             │
│     ├── Test feature flags → Remove                         │
│     ├── Experimental code paths → Remove                    │
│     ├── Stub implementations → Complete or Remove           │
│     └── Dead conditional branches → Remove                  │
│                                                             │
│  5. DOCUMENTATION CHECK                                     │
│     ├── README.md → Update if new scripts/commands          │
│     └── CLAUDE.md → Update if new patterns/conventions      │
│                                                             │
│  → Cleanup complete, proceed to Final Verification          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Important Notes

1. **Cleanup runs BEFORE final verification** - This ensures any issues caused by code removal are caught
2. **Preserve intentional patterns** - Not all console.* is debug (logger utilities, error handlers)
3. **Check git status** - Don't delete files tracked in git unless they're implementation artifacts
4. **Document exceptions** - If something looks like cruft but needs to stay, document why
5. **Keep docs brief** - README/CLAUDE.md updates should be one-liners; users can read source for details

---

### Step 7: Final Verification (After Cleanup)

After cleanup, run comprehensive final verification to catch any issues cleanup may have caused:

1. Launch **final verifier** subagent with full spec
2. Verifier performs:
   - **CLI verification** (all tests, lint, typecheck)
   - **UI verification** (only if feature has UI components):
     - E2E tests (Playwright/Selenium) if available
     - Browser testing via Chrome MCP
     - Full feature walkthrough
3. If issues found → fix and re-verify
4. Continue until all tests pass

#### Final Verification Flow

```
┌─────────────────────────────────────┐
│  Cleanup Complete                   │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│        FINAL CLI VERIFICATION                   │
│  1. pnpm test → all unit tests                  │
│  2. pnpm typecheck                              │
│  3. pnpm lint                                   │
│  4. All API endpoint tests                      │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌────────────────────┐
│  CLI Pass?         │
└────────┬───────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌────────────────────────────┐
│  Yes  │  │  No → Fix first            │
└───┬───┘  └────────────────────────────┘
    │
    ▼
┌────────────────────────────────────────┐
│  Feature has UI components?            │
└────────┬───────────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌─────────────────────────────────────┐
│  No   │  │  Yes                                │
│       │  │  ┌───────────────────────────────┐  │
│ DONE  │  │  │  UI VERIFICATION              │  │
│       │  │  │  1. E2E (Playwright/Selenium) │  │
└───────┘  │  │  2. Chrome MCP browser test   │  │
           │  │  3. Full feature walkthrough  │  │
           │  └───────────────┬───────────────┘  │
           │                  │                  │
           │             ┌────┴────┐             │
           │             │  Pass?  │             │
           │             └────┬────┘             │
           │          Yes     │     No           │
           │        ┌─────────┴─────────┐        │
           │        ▼                   ▼        │
           │      DONE         Fix and re-run   │
           └─────────────────────────────────────┘
```

---

### Step 7b: Final Requirements Validation

Before declaring completion, verify **every original requirement** is satisfied.

#### Requirements Traceability Check

```yaml
requirements_validation:
  original_requirements:
    - requirement: "Requirement 1 from plan"
      status: "satisfied" | "partially_satisfied" | "not_implemented"
      evidence:
        - "Implementation location (file:line)"
        - "Verification method used"
        - "Test that confirms it works"
    - requirement: "Requirement 2 from plan"
      status: "satisfied"
      evidence: [...]

  acceptance_criteria:
    - criterion: "Acceptance criterion 1"
      verified: true/false
      verification_method: "unit_test" | "api_test" | "e2e_test" | "manual_browser"
      evidence: "How it was verified"

  gaps_identified:
    - "Any requirement not fully met"
    - "Any acceptance criterion not verified"
```

#### Validation Process

1. **List all original requirements** from the plan
2. **Map each requirement** to implementation evidence:
   - Which files implement it
   - Which tests verify it
   - How it was validated (CLI vs UI)
3. **Identify gaps** - any requirement not fully satisfied
4. **If gaps exist:**
   - Create new implementer task for missing functionality
   - Re-run verification loop
   - Repeat until all requirements satisfied
5. **Only proceed to completion when ALL requirements are satisfied**

---

### Step 8: Completion

When all acceptance criteria are demonstrably met AND requirements validation passes AND code cleanup is complete:

1. **Final verifier signs off** with:
   - Summary of what changed
   - How it was tested (exact commands + results)
   - Requirements traceability matrix
   - Code cleanup report (what was removed)
   - Review notes on simplicity/duplication/maintainability
   - Remaining risks/known limitations (if any)

2. **Produce release checklist** for merge/deploy

## Outputs

### Artifacts Produced

```
Implementation complete:
├── All code changes per plan
├── Updated/added tests
├── Updated docs/config as needed
├── Requirements traceability matrix
└── Final verification report
```

### Final Report Schema

```yaml
completion_report:
  summary: "Brief description of what was implemented"

  requirements_traceability:
    - requirement: "Original requirement 1"
      status: "satisfied"
      implementation: "path/to/file.ts:line"
      verification: "unit_test" | "api_test" | "e2e" | "browser"
    - requirement: "Original requirement 2"
      status: "satisfied"
      implementation: "path/to/file.ts:line"
      verification: "unit_test"

  milestones_completed:
    - name: "Milestone 1"
      tasks: [completed tasks]
      verification:
        cli_tests: "pass"
        ui_tests: "pass" | "skipped (backend only)"

  testing:
    cli_verification:
      unit_tests: "pnpm test → pass"
      api_tests: "curl endpoints → pass"
      scripts: "pnpm script:name → pass"
    ui_verification:
      method: "playwright" | "chrome_mcp" | "skipped"
      results: "all scenarios pass"

  subagent_reports:
    - agent: "Implementer 1"
      summary: "Functional summary of what was implemented"
    - agent: "Verifier 1"
      summary: "What was verified, which requirements confirmed"

  code_cleanup:
    dead_code_removed:
      - "Unused function `xyz` from path/file.ts"
      - "Unused imports from X files"
    debug_artifacts_removed:
      - "console.log statements: X removed"
      - "debugger statements: Y removed"
    temp_files_deleted:
      - "scripts/temp-migration.mjs"
      - "test-output.log"
    leftover_functionality_removed:
      - "Experimental caching approach"
      - "Test feature flags"
    preserved_with_justification:
      - "path/file.ts:23: TODO comment (pre-existing)"
    documentation_updated:
      - "README.md: Added script to Scripts Reference"
      - "CLAUDE.md: No updates needed"

  quality_notes:
    simplicity: "Assessment of code simplicity"
    duplication: "Any duplication concerns"
    maintainability: "Maintainability assessment"
    hygiene: "Code is clean, no debug artifacts or dead code"

  risks_limitations:
    - "Any known limitations"

  release_checklist:
    - [ ] All CLI tests pass
    - [ ] All UI tests pass (if applicable)
    - [ ] All requirements satisfied
    - [ ] No TypeScript errors
    - [ ] Code cleanup complete (no dead code, debug logs, temp files)
    - [ ] Documentation updated (README.md, CLAUDE.md if needed)
    - [ ] Code reviewed
    - [ ] Ready for merge
```

## Examples

### Basic Usage

```
/orchestrate docs/plans/feature-name.md
```

### Example Execution Flow

```
1. Reading plan: docs/plans/feature-name.md

2. Plan Analysis:
   - 3 phases identified
   - 12 tasks extracted
   - 2 parallel groups possible
   - Verification capabilities detected:
     ├── Unit tests: available (vitest/jest)
     ├── API endpoints: /api/resource/*
     ├── E2E: playwright available
     └── Chrome MCP: available

3. Verification Strategy:
   - Milestone verification: CLI only (unit, lint, typecheck, API curl)
   - Final verification: CLI + E2E + Chrome MCP (has UI components)

4. Execution Plan:
   Phase 1 (Foundation): 4 tasks → Opus
   Phase 2 (Core Logic): 5 tasks → Sonnet, parallel where possible
   Phase 3 (Integration): 3 tasks → Sonnet

5. Launching Phase 1 implementer...
   [Implementer Report: Foundation complete, types defined]

6. MILESTONE Verification Phase 1 (CLI only):
   - pnpm test → pass
   - pnpm typecheck → pass
   - pnpm lint → pass
   ✓ Phase 1 complete → proceed to next milestone

7. Launching Phase 2 tasks (some in parallel)...
   [Implementer Reports: Core logic implemented]

8. MILESTONE Verification Phase 2 (CLI only):
   - pnpm test → 1 failure → Fixed → pass
   - curl /api/resource → 200 OK
   - pnpm typecheck → pass
   ✓ Phase 2 complete → proceed to next milestone

[... continues through all phases with CLI-only verification ...]

9. ALL MILESTONES COMPLETE → CODE CLEANUP:
    Dead code removed:
    - Removed unused helper function
    - Removed 5 unused imports across 3 files
    - Removed commented-out experimental code

    Debug artifacts removed:
    - 4 console.log statements removed
    - 1 debugger statement removed

    Temp files deleted:
    - scripts/temp-setup.mjs (one-time script, completed)
    - test-output.json

    Documentation updated:
    - README.md: Added new command to Scripts Reference
    - CLAUDE.md: No updates needed

10. FINAL VERIFICATION (after cleanup):

    CLI Verification:
    - pnpm test → all pass
    - pnpm typecheck → pass
    - pnpm lint → pass
    - All API endpoints → pass

    UI Verification (feature has UI):
    - playwright e2e → pass
    - Chrome MCP browser test:
      - Primary flow → works
      - Edit flow → works
      - Error states → handled correctly

11. Final Requirements Validation:
    - ✓ Requirement 1 (api + ui verified)
    - ✓ Requirement 2 (api + ui verified)
    - ✓ Requirement 3 (e2e tested)

✓ IMPLEMENTATION COMPLETE
  - 12/12 tasks completed
  - All requirements satisfied
  - Milestone CLI tests: all pass
  - Final CLI tests: pass
  - Final UI tests: pass
  - Code cleanup: complete
  - Ready for review
```

## Error Handling

### ERR-000: Orchestrator Direct Action (SELF-CHECK)

**Symptoms:** You (the orchestrator) are about to use Edit/Write/Bash for implementation, debugging, or verification
**Cause:** Temptation to "just do it quickly" instead of delegating

**Self-Check Questions:**
- Am I about to edit a `.ts`, `.tsx`, `.js`, `.jsx`, `.css`, `.scss`, or similar file?
- Am I about to run `pnpm test`, `pnpm lint`, `pnpm build`, or similar commands?
- Am I about to debug an error by reading logs or running diagnostic commands?
- Am I about to write implementation code rather than task specs?
- Did I think "this is too small to bother with a subagent"?

**If YES to any above:**
1. STOP immediately
2. Do NOT proceed with the action
3. Create a task specification instead
4. Launch a subagent via the Task tool
5. Wait for subagent to complete and report results

**Remember:** There is no task too small for a subagent. Your job is to orchestrate, not implement, debug, or verify.

---

### ERR-001: Plan File Not Found

**Symptoms:** Command fails at Gate 1
**Cause:** Invalid path or file doesn't exist

**Resolution:**
1. Verify the file path is correct
2. Check for typos in the path
3. Ensure the file has `.md` extension
4. Retry with correct path

---

### ERR-002: Subagent Failure

**Symptoms:** Implementer or verifier subagent reports failure
**Cause:** Various - syntax errors, test failures, missing dependencies

**Resolution:**
1. Read the subagent's error output
2. Identify the specific issue
3. Fix the issue or adjust the task spec
4. Re-run the subagent

---

### ERR-003: Verification Loop Stuck

**Symptoms:** Verification keeps failing after multiple iterations
**Cause:** Unclear requirements or conflicting constraints

**Resolution:**
1. Document the specific verification failure
2. Assess if the requirement is achievable
3. Either:
   - Adjust the approach
   - Flag for manual review
   - Document as known limitation

---

### ERR-004: File Conflict

**Symptoms:** Multiple subagents attempting to edit same file
**Cause:** Incorrect parallel grouping

**Resolution:**
1. Stop conflicting subagents
2. Sequence the tasks instead of parallelizing
3. Re-run in correct order

---

### ERR-005: Cleanup Breaks Tests

**Symptoms:** Tests fail after removing code during cleanup
**Cause:** Removed code that was actually used (false positive in dead code detection)

**Resolution:**
1. Identify which removal caused the failure from git diff
2. Restore the removed code
3. Verify tests pass again
4. Document why the code appeared dead but wasn't
5. Re-run cleanup with updated understanding

---

### ERR-006: Uncertain About Removal

**Symptoms:** Code looks unused but might be needed (public API, dynamic imports, reflection)
**Cause:** Dead code detection has limitations with dynamic patterns

**Resolution:**
1. Check if code is part of public API (exported for external use)
2. Search for dynamic references: `import()`, string-based property access
3. Check for test fixtures or mocks that reference the code
4. **When in doubt, preserve with justification** in cleanup report
5. Flag for human review if still uncertain

## Summary

After orchestration completes, provide:

```
✓ ORCHESTRATE COMPLETE

[1-2 sentence summary of what was implemented]

Milestones: X/Y completed
Verification:
  - Milestone CLI tests: all pass
  - Final CLI tests: pass
  - Final UI tests: pass | skipped (backend-only)

Requirements: X/X satisfied

Code Cleanup (before final verification):
  - Dead code removed: X items
  - Debug artifacts removed: Y console.logs, Z debuggers
  - Temp files deleted: N files
  - Documentation: updated | no changes needed

Quality: [brief assessment]

Release Checklist:
- [ ] All requirements met
- [ ] All tests passing
- [ ] Code cleanup complete
- [ ] Documentation updated
- [ ] Ready for merge
```

If issues occurred:

```
⚠ ORCHESTRATE PARTIALLY COMPLETE

Completed: [what succeeded]
Incomplete: [what failed]

Verification Status:
  - Milestone CLI: [status]
  - Cleanup: [status]
  - Final CLI: [status]
  - Final UI: [status]

Requirements Gap:
- [ ] Unsatisfied: [requirement]

Cleanup Gap:
- [ ] Unresolved: [item that couldn't be safely removed]

Issues:
- [Issue description]

Next Steps:
1. [Specific action]
```

## References

### Related Commands

- `/commit` - Create git commit after implementation
