---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite, Agent, WebFetch, WebSearch
description: "Creates structured implementation plans with codebase analysis"
category: workflow
version: 1.3
schema: aitt/commands/cmd.md
model: opus
input:
  expects: "Description of the feature, task, or change to plan"
  required: true
  format: free-text
---

> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.

# Plan

> Creates structured implementation plans by exploring the codebase, analyzing architecture, evaluating trade-offs, and producing an actionable plan document ready for `/orchestrate`.

## Purpose

Produce a thorough, opinionated implementation plan for a feature, refactor, or change. The plan is the bridge between an idea and `/orchestrate` execution — it captures the "what," "why," and "how" so the orchestrator can focus purely on delegation.

**Use when:**
- Implementing a new feature that touches multiple files or modules
- Refactoring existing systems where multiple valid approaches exist
- Making architectural decisions that affect the codebase long-term
- The scope or approach is unclear and needs exploration first

**Do not use when:**
- Single-file bug fixes with obvious solutions
- Trivial changes (typos, config tweaks, adding a log line)
- Pure research or exploration tasks (use the Explore agent directly)

## Key Principles

**Exploration Before Opinion:**
Read the code before forming conclusions. Every architectural recommendation must be grounded in what actually exists, not assumptions about what should exist.

**Anti-Pattern to Avoid:**
- **Wrong:** Proposing a Redux store without checking if the project already uses Zustand
- **Correct:** Explore state management patterns in the codebase, then recommend an approach consistent with existing conventions

**Plan the Seams, Not the Code:**
The plan defines the *connection points* between work scopes — not the code inside them. Include everything needed to implement correctly, nothing more. Each phase declares the interfaces, types, contracts, and data shapes it exposes to the next phase. Be concrete — type signatures, method signatures, API shapes, and data schemas, not prose descriptions.

Do not include: function bodies, SQL queries, component JSX, step-by-step implementation logic, exact variable names, line-by-line code changes, or pixel-perfect UI specs. Describe what each component/module should do, which patterns to follow, what interfaces it exposes, and what the acceptance criteria are — let the implementer handle the internals.

**Anti-Pattern to Avoid:**
- **Wrong:** Writing out function bodies, full component implementations, or specifying exact variable names and line-by-line changes
- **Correct:** Define the type signatures, API contracts, data schemas, and module boundaries. The implementer writes the code; the plan defines where the pieces snap together.

**Example:** If Phase 1 creates a repository and Phase 2 builds a service that uses it, the plan should specify the repository's public interface (method signatures, return types, error contract) — not the SQL queries inside it. Phase 2's implementer then knows exactly what they can call without reading Phase 1's internals.

**Orchestrate-Ready Output:**
Plans must contain what `/orchestrate` needs: requirements, acceptance criteria, architecture overview, implementation phases with interface contracts, and verification expectations. If the plan can't be handed directly to `/orchestrate`, it's incomplete.

**Consistency Over Novelty:**
When the codebase has established patterns, follow them. Introducing a new pattern requires justification beyond "it's better" — it must be demonstrably necessary.

## Inputs

**Expects:** Description of the feature, task, or change to plan
**Required:** Yes

### Usage

```
/plan add user authentication with JWT
/plan migrate the scheduling system from cron to a queue-based approach
/plan refactor the media library to support S3 storage
```

The input should describe the goal clearly enough to guide exploration. Additional context (constraints, preferences, related issues) is welcome.

## Prerequisites

### Gate 1: Input Contains Actionable Goal

**Check:** The input describes a concrete feature, change, or task (not a vague wish)
**Pass:** Proceed to Process
**Fail:** Ask the user to clarify what they want to build or change

**Fail Output:**
```
I need a clearer picture of what to plan. Could you describe:
- What feature or change you want to implement?
- What problem it solves or what capability it adds?
```

## Process

### Step 1: Understand the Goal

Parse the input to extract:

1. **What** — The feature, change, or refactor being requested
2. **Why** — The motivation or problem being solved (ask if not obvious)
3. **Scope boundaries** — What's in scope vs. explicitly out of scope

If the goal is ambiguous, ask one focused clarifying question before proceeding. Do not stall — make reasonable assumptions and document them.

---

### Step 2: Explore the Codebase

Thoroughly investigate the relevant parts of the codebase. This is the most important step — skipping it leads to plans that fight the existing architecture.

#### 2.1 Map the Relevant Architecture

- Identify which packages, modules, and files are involved
- Trace data flow through the affected area (API routes → services → repositories → data layer)
- Understand existing patterns: naming conventions, file organization, error handling, testing approach

#### 2.2 Identify Existing Conventions

| Aspect | What to Look For |
|--------|-----------------|
| File structure | How are similar features organized? (co-located tests, barrel exports, etc.) |
| Naming | Variable/function naming patterns, file naming conventions |
| Error handling | Thrown errors vs. returned errors, error types used |
| Testing | Unit vs. integration split, mocking strategy, test data patterns |
| State management | How is state handled in similar features? |
| API patterns | Route structure, validation, response formats |
| Type patterns | Interface vs. type, branded types, generic patterns |

#### 2.3 Identify Dependencies and Constraints

- What must exist before this can be built? (prerequisite features, migrations, config)
- What existing behavior must not break? (regression risks)
- Are there performance constraints? (data volume, response time expectations)
- Are there security considerations? (auth, input validation, data exposure)

#### Search Patterns

Use these to efficiently explore:

```bash
# Find similar features for pattern reference
glob: src/**/*{feature-keyword}*
grep: "class.*Repository" or "function.*Service" in relevant packages

# Understand the module boundary
grep: "export" in the module's index.ts
grep: "import.*from.*{module}" across the codebase

# Find test patterns
glob: **/*.test.{ts,tsx} near the affected area
```

---

### Step 3: Evaluate Approaches

When multiple implementation paths exist, evaluate each against these criteria:

| Criterion | Question |
|-----------|----------|
| Consistency | Does this match existing patterns in the codebase? |
| Simplicity | Is this the smallest change that solves the problem? |
| Maintainability | Will this be easy to understand and modify later? |
| Testability | Can this be tested without complex setup? |
| Performance | Does this meet the performance requirements? |
| Security | Does this follow security best practices? |
| Migration risk | How risky is the transition? Can it be done incrementally? |

#### Decision Format

For each significant decision, document:

```markdown
### Decision: [Topic]

**Options considered:**
1. **[Option A]** — [Brief description]
   - Pro: [advantage]
   - Con: [disadvantage]
2. **[Option B]** — [Brief description]
   - Pro: [advantage]
   - Con: [disadvantage]

**Chosen:** Option [X]
**Rationale:** [Why this option wins given the codebase context]
```

If the decision is genuinely ambiguous and user preference matters, ask using AskUserQuestion. Otherwise, make the call and document the reasoning.

---

### Step 4: Checkpoint — Exploration Complete

> **GATE:** Do not proceed to plan composition until satisfied.

- [ ] Relevant codebase areas explored (not assumed)
- [ ] Existing patterns and conventions identified
- [ ] Dependencies and constraints documented
- [ ] Key architectural decisions made (or questions asked)
- [ ] Module boundaries and interface patterns understood (how existing modules expose their contracts)
- [ ] No critical unknowns remaining

**If not satisfied:** Return to Step 2 or Step 3

---

### Step 5: Compose the Plan Document

Write the plan as a Markdown file in `docs/plans/${PROJECT_NAME}/`. Use descriptive kebab-case filenames (e.g., `add-jwt-authentication.md`, `migrate-scheduler-to-queue.md`).

Number the main sections sequentially (1, 2, 3...). Include only sections relevant to the plan — required sections are always present, optional sections appear when applicable.

#### Plan Document Structure

```markdown
# [Feature Name]: Implementation Plan

## Overview (required)

[1-3 paragraphs explaining what this plan achieves, why it's needed,
and the high-level approach. This should be understandable by someone
who hasn't read the rest of the document.]

## [N]. Technology & Architecture Decisions (include when relevant)

[Document each significant decision using the format from Step 3.
Include: chosen approach, alternatives considered, rationale.]

## [N]. Design (include when relevant)

[The visual and interaction design for user-facing changes.
Include: screen layouts as ASCII wireframes, component inventory
with placement and purpose, interaction patterns (click flows,
form behavior, modals, transitions), UI states (empty, loading,
error, success), and responsive behavior across breakpoints.

For technical design (schemas, APIs, data flow, type definitions),
use the Architecture Decisions or Implementation Phases sections.]

## [N]. Configuration & Environment (include when relevant)

[Environment variables, config file changes, or infrastructure
requirements needed for the feature.]

## [N]. Files to Modify (required)

### New Files
| File | Purpose |
|------|---------|
| `path/to/new-file.ts` | [What it does] |

### Modified Files
| File | Changes |
|------|---------|
| `path/to/existing-file.ts` | [What changes and why] |

### Deleted Files
| File | Reason |
|------|--------|
| `path/to/obsolete-file.ts` | [Why it's no longer needed] |

### No Changes Required
[List areas that might seem affected but actually aren't, with reasoning]

## [N]. Implementation Phases (required)

[Break the work into sequential phases. Each phase should be
independently verifiable — after completing it, you can confirm
it works before moving to the next.

Each phase MUST define its interface contract: what it exposes
to subsequent phases. This is the critical connective tissue
that allows milestones to snap together without guesswork.]

### Phase 1: [Name] (foundation)
- [Task 1]
- [Task 2]

**Exposes to next phase:**
[The interfaces, types, API contracts, or data shapes this phase
creates that subsequent phases depend on. Be specific — method
signatures, type definitions, endpoint shapes, database schemas.]

```typescript
// Example: what Phase 2 can rely on
interface UserRepository {
  findById(id: string): Promise<User | null>;
  create(data: CreateUserInput): Promise<User>;
}
```

**Verify:** [How to confirm this phase works]

### Phase 2: [Name]

**Receives from Phase 1:** [Reference the interfaces/contracts
defined in Phase 1 that this phase consumes]

- [Task 1]
- [Task 2]

**Exposes to next phase:**
[Interfaces this phase adds or extends for Phase 3]

**Verify:** [How to confirm this phase works]

[Continue for all phases. The final phase has no "Exposes"
section — it completes the feature.]

## [N]. Testing Strategy (include when relevant)

[What tests need to be written or updated. Unit, integration,
E2E coverage expectations. Test data requirements.]

## [N]. Risks and Mitigations (include when relevant)

| Risk | Impact | Mitigation |
|------|--------|------------|
| [What could go wrong] | [Consequence] | [How to prevent or recover] |

## [N]. Migration & Rollback Strategy (include when relevant)

[Data migration steps, rollback procedures, incremental
rollout strategy if applicable.]

## Summary (required)

[Concise recap: what this plan delivers, the key architectural
choices, and why this approach was selected over alternatives.
This is what someone reads to understand the full concept
without reading implementation details.]

## Implementation Tracking Checklist (required)

[Checkbox list of every task across all phases.
This is what /orchestrate uses to track progress.]

### Phase 1: [Name]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]
- [ ] Task 1
- [ ] Task 2
```

---

### Step 6: Checkpoint — Plan Quality

> **GATE:** Do not present the plan until all validation checks pass.

Run every check in the **Validation** section below. If any check fails, follow its fix procedure, then re-check.

**If not satisfied:** Return to Step 5 and improve.

---

### Step 7: Parallel Review Subagents

Launch two review subagents in parallel to validate the plan from different perspectives. Both must complete before proceeding.

#### 7.1 Architectural Review Agent

Use Task tool with `subagent_type: Plan` to review the plan document for architectural quality.

**Review Criteria:**
- **No cheap shortcuts:** Solutions address root causes, not symptoms; no workarounds or temporary fixes disguised as permanent solutions
- **Clean responsibilities:** Each module/component has a single, well-defined purpose; no god objects or kitchen-sink modules
- **No duplications:** No redundant code paths, duplicate data structures, or repeated logic across phases
- **Architectural best practices:** Follows SOLID principles, maintains loose coupling, respects existing codebase patterns
- **No over-engineering:** Solutions match the problem complexity; no premature abstractions, unnecessary indirection, or speculative generality

**Prompt template:**
```
Review the implementation plan at docs/plans/${PROJECT_NAME}/<name>.md for architectural quality.

Evaluate against these criteria:
1. No cheap shortcuts - Are solutions addressing root causes or just patching symptoms?
2. Clean responsibilities - Does each component have a single, well-defined purpose?
3. No duplications - Is there any redundant logic, duplicate data structures, or repeated code paths?
4. Best practices - Does it follow SOLID, maintain loose coupling, respect existing patterns?
5. No over-engineering - Is the solution complexity appropriate to the problem? No premature abstractions?

If issues found, list each with:
- What: The specific issue
- Where: Which section/phase
- Fix: How to address it

If the plan passes all criteria, confirm: "Architectural review: PASSED"
```

#### 7.2 Coverage Review Agent

Use Task tool with `subagent_type: Plan` to verify the plan covers all necessary aspects.

**Review Criteria:**
- **Complete feature coverage:** All aspects of the requested feature are addressed
- **Edge cases identified:** Error states, boundary conditions, and exceptional flows considered
- **Integration points covered:** All touchpoints with existing systems are addressed
- **Testing coverage:** Test strategy covers the feature adequately
- **Migration/rollback:** Data migration and rollback scenarios addressed (if applicable)
- **Security considerations:** Auth, validation, data exposure risks addressed (if applicable)
- **No orphaned dependencies:** All prerequisites and downstream effects are accounted for

**Prompt template:**
```
Review the implementation plan at docs/plans/${PROJECT_NAME}/<name>.md for completeness.

Check for missing aspects:
1. Feature coverage - Are all aspects of the requested feature addressed?
2. Edge cases - Are error states, boundary conditions, and exceptional flows covered?
3. Integration points - Are all touchpoints with existing systems addressed?
4. Testing coverage - Does the test strategy adequately cover the feature?
5. Migration/rollback - Are data migration and rollback scenarios addressed (if needed)?
6. Security - Are auth, validation, and data exposure risks addressed (if needed)?
7. Dependencies - Are all prerequisites and downstream effects accounted for?

If gaps found, list each with:
- What: The missing aspect
- Impact: Why it matters
- Suggestion: How to address it

If the plan is complete, confirm: "Coverage review: PASSED"
```

#### Handling Review Results

**If both agents return PASSED:** Proceed to Step 8

**If either agent identifies issues:**
1. Read the agent feedback
2. Return to Step 5 to address the identified issues
3. Re-run Step 6 checkpoint
4. Re-run Step 7 reviews
5. Repeat until both reviews pass

---

### Step 8: Present Summary and Request Approval

After writing the plan file, present a structured summary to the user. The summary has three mandatory sections and two conditional sections that together convey the full concept without requiring the user to open the plan file.

#### 8.1 Business Strategy

Explain the business-level behavior this plan delivers. Not long prose — concise, structured points that answer:

- **What changes for the user?** — Observable behavior from the end-user perspective
- **What business rules are introduced or modified?** — Decision logic, constraints, triggers
- **What workflows change?** — Step-by-step user journeys affected, new flows added
- **What data relationships are created?** — How entities connect, what depends on what

Use bullet points or a short table. Each point should describe a concrete behavior, not an abstract goal.

#### 8.2 User Journey (conditional — include when the plan introduces or changes user-facing workflows)

Map the step-by-step experience from the user's perspective. Show what the user does, what the system responds with, and decision points along the way.

Use a numbered flow format:

```
1. User does [action]
2. System responds with [result]
3. User chooses [option A] or [option B]
   → A: [what happens]
   → B: [what happens]
4. ...
```

Include:
- **Happy path** — The primary flow from start to completion
- **Key branches** — Where the user can take different paths and what each leads to
- **Error/edge states** — What happens when things go wrong (validation failures, permission denied, network errors)

Keep it concise — this is a journey map, not a spec. One flow per major user interaction. If the plan has multiple distinct user journeys, show each separately with a label.

#### 8.3 Design Plan (conditional — include when the plan involves UI changes, new screens, or visual/interaction design)

Present the visual and interaction design using ASCII mockups, layout descriptions, or structured component breakdowns. This section answers "what does the user see and interact with?"

Include:
- **Screen layouts** — ASCII wireframes or structured descriptions of new/changed screens, showing component placement, visual hierarchy, and responsive breakpoints
- **Component inventory** — New UI components needed, their purpose, and where they appear
- **Interaction patterns** — How users interact with the UI (click flows, form behavior, drag-and-drop, modals, transitions)
- **States and variations** — Empty states, loading states, error states, success states, and how the UI adapts to different data conditions
- **Responsive behavior** — How layouts adapt across breakpoints (mobile, tablet, desktop) if applicable

Use ASCII art for wireframes when spatial layout matters:

```
┌─────────────────────────────────┐
│ Header / Navigation             │
├──────────┬──────────────────────┤
│ Sidebar  │ Main Content Area    │
│          │ ┌──────────────────┐ │
│          │ │ Component A      │ │
│          │ └──────────────────┘ │
│          │ ┌──────────────────┐ │
│          │ │ Component B      │ │
│          │ └──────────────────┘ │
└──────────┴──────────────────────┘
```

Use structured lists when describing component behavior or states:

```
**[Screen/Component Name]:**
- Layout: [description]
- Components: [list]
- States: default | loading | empty | error
- Actions: [what user can do]
```

Keep it design-focused — describe what users see and how they interact, not the implementation details behind it.

#### 8.4 Data Flow (conditional — include when the plan involves data moving through multiple system layers)

Visualize how data moves through the system using an arrow-chain format:

```
[Entry point] → [Processing step] → [Storage] → [Output]
```

Include:
- **Input sources** — Where data enters (UI form, API call, cron trigger, webhook, etc.)
- **Transformations** — What processing happens at each step (validation, enrichment, computation)
- **Storage touchpoints** — Where data is persisted or read (database tables, cache, external APIs)
- **Output destinations** — Where data ends up (UI render, API response, notification, external service)

For plans with multiple data paths (e.g., write flow vs. read flow), show each separately. Label each flow.

#### 8.5 Architectural Plan

Describe the technical approach at system level:

- **Pattern/approach chosen** — What architectural pattern drives the implementation and why
- **Key decisions** — Technology choices, trade-offs made, alternatives rejected (with rationale)
- **Integration points** — What existing systems this connects to and how
- **Phase overview** — Number of phases, what each phase delivers, dependency chain between them

#### 8.6 Affected File Structure

Present the file impact as a structured tree or table:

- **New files** — Path and one-line purpose
- **Modified files** — Path and what changes
- **Deleted files** — Path and why (if any)

Group by package/module for readability.

#### 8.7 Close

State where the full plan lives (`docs/plans/${PROJECT_NAME}/<name>.md`) and ask the user if they'd like to:
- Approve and proceed to implementation (via `/orchestrate`)
- Request modifications to the plan
- Discuss specific decisions further

## Outputs

### Files Generated

```
docs/plans/${PROJECT_NAME}/<feature-name>.md    # The implementation plan
```

### Plan Document Properties

- Written in Markdown
- Saved to `docs/plans/${PROJECT_NAME}/` with descriptive kebab-case filename
- Self-contained — readable without additional context
- Structured for consumption by `/orchestrate`
- Contains implementation tracking checklist with unchecked boxes

## Examples

### Basic Usage

```
/plan add dark mode toggle to the admin app
```

### Complex Feature

```
/plan migrate the post scheduling system from single-timezone to multi-timezone support with per-user timezone preferences
```

### Refactoring

```
/plan refactor the media library repository to support pluggable storage backends (local filesystem and S3)
```

### Example Summary Output
https://github.com/mksglu/claude-context-mode?tab=readme-ov-file
````
## Plan: JWT Authentication

### Business Strategy

- **User behavior:** Users log in with email/password, receive a persistent session. Authenticated users access admin routes; unauthenticated users are redirected to login
- **Session lifecycle:** Sessions expire after 7 days of inactivity; refresh tokens extend active sessions transparently
- **Authorization model:** Role-based — `admin` and `viewer` roles. Admins manage content, viewers read-only. Role assigned at user creation
- **Security rules:** Max 5 failed login attempts per 15 minutes per IP. Passwords require 8+ chars with mixed case + number. Tokens invalidated on password change
- **Account recovery:** Password reset via email link (24h expiry, single-use token)

### User Journey

**Login flow:**
1. User navigates to any admin page
2. System detects no valid session → redirects to `/login`
3. User enters email + password, clicks "Log in"
4. System validates credentials
   → Success: Sets httpOnly cookie, redirects to original destination (or `/dashboard`)
   → Invalid credentials: Shows inline error "Invalid email or password", stays on login page
   → Rate limited: Shows "Too many attempts. Try again in X minutes"
5. User is now authenticated — all admin routes accessible

**Session expiry:**
1. User's token expires after 7 days of inactivity
2. Next request → system returns 401
3. Client-side middleware catches 401 → redirects to `/login` with return URL preserved
4. User re-authenticates → returns to where they left off

**Password reset:**
1. User clicks "Forgot password?" on login page
2. User enters email → system sends reset link (regardless of whether email exists — no user enumeration)
3. User clicks link → lands on reset form (or "Link expired" if >24h)
4. User sets new password → all existing sessions invalidated → redirected to login

### Design Plan

**Login page (`/login`):**
```
┌─────────────────────────────────────┐
│           [Logo / Brand]            │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Email                         │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Password              [👁]    │  │
│  └───────────────────────────────┘  │
│  [ Forgot password? ]               │
│                                     │
│  ┌───────────────────────────────┐  │
│  │         Log in                │  │
│  └───────────────────────────────┘  │
│                                     │
│  [!] Error message area (hidden)    │
└─────────────────────────────────────┘
```

- **Layout:** Centered card on muted background, max-width 400px, vertically centered
- **Components:** TextInput (email), PasswordInput (with visibility toggle), Button (primary), inline Alert
- **States:**
  - Default: Empty form, button enabled
  - Loading: Button shows spinner, inputs disabled
  - Error: Inline alert below form with error message, inputs re-enabled
  - Rate limited: Alert with countdown timer, submit disabled

**Password reset page (`/reset-password`):**
- Same centered card layout as login
- Single email input + submit button (request flow)
- New password + confirm password inputs (reset flow)
- Success state: confirmation message with link back to login

### Data Flow

**Authentication:**
Login form → `POST /api/auth/login` → rate limiter check → bcrypt verify against `users` table → JWT minted (userId + role in payload) → httpOnly cookie set → 200 response

**Request authorization:**
Incoming request → Fastify `onRequest` hook → extract JWT from cookie → verify signature + expiry → decode payload → attach `request.user` → route handler executes (or 401 if invalid)

**Token refresh:**
Client request with near-expiry token → auth middleware detects <1h remaining → mints fresh token → sets updated cookie → original request proceeds

### Architectural Plan

- **Pattern:** Fastify plugin-based auth middleware (consistent with existing plugin patterns in the codebase)
- **Key decisions:**
  - JWT in httpOnly cookies over localStorage → XSS protection
  - bcrypt for password hashing → already a project dependency
  - PostgreSQL users table in social database → reuses existing Drizzle setup
  - Fastify `onRequest` hook for route protection → non-invasive, per-route opt-in
- **Integration:** Connects to existing Drizzle ORM layer and Fastify server. No new external dependencies
- **Phases:** 5 phases — (1) DB schema & migration → (2) Auth service & JWT utils → (3) Fastify middleware plugin → (4) Login/logout UI → (5) Protected route migration

### Affected File Structure

**packages/social/**
| Action | File | Purpose |
|--------|------|---------|
| New | `src/db/schema/users.ts` | User table schema with roles |
| New | `src/auth/auth-service.ts` | Login, logout, token refresh logic |
| New | `src/auth/jwt-utils.ts` | Token mint/verify helpers |
| Modified | `src/db/schema.ts` | Export new users table |
| Modified | `src/index.ts` | Wire auth service singleton |

**web/oxyness-admin/**
| Action | File | Purpose |
|--------|------|---------|
| New | `server/plugins/auth.ts` | Fastify auth plugin |
| New | `pages/login/+Page.tsx` | Login page UI |
| Modified | `server/index.ts` | Register auth plugin |
| Modified | `pages/+config.ts` | Add route guard config |

Full plan: `docs/plans/oxyness-admin/add-jwt-authentication.md`

Shall I proceed with /orchestrate, or would you like to adjust anything?
````

## Validation

Step 6 references this section as the authoritative quality gate. Run all checks in order.

### Check 1: Plan File Exists

**Method:** Verify `docs/plans/${PROJECT_NAME}/<name>.md` was written successfully
**On success:** Proceed to next check
**On failure:** Write the file and re-validate

### Check 2: Required Sections Present

**Method:** Verify the plan contains all required sections: Overview, Files to Modify, Implementation Phases, Summary, Implementation Tracking Checklist
**On success:** Proceed to next check
**On failure:** Add missing sections and re-validate

### Check 3: Interface Contracts Defined

**Method:** Verify every phase (except the final one) has an "Exposes to next phase" section with concrete type signatures, method signatures, or API shapes. Verify every phase (except the first) has a "Receives from" reference to what it depends on. Connection points must be concrete code-level definitions, not prose descriptions.
**On success:** Proceed to next check
**On failure:**
1. Identify phases missing interface contracts
2. Add concrete contracts — types, function signatures, endpoint shapes
3. Ensure the receiving phase references what it depends on
4. Re-validate

### Check 4: No Implementation Code

**Method:** Verify the plan does not contain function internals, SQL query bodies, component JSX, or implementation logic. Interface definitions (type signatures, method signatures, schemas) are expected; code that goes inside functions is not.
**On success:** Proceed to next check
**On failure:**
1. Identify code body content
2. Replace with interface definitions or remove
3. Re-validate

### Check 5: Checklist Completeness

**Method:** Verify the Implementation Tracking Checklist contains a checkbox for every task mentioned in every phase
**On success:** Proceed to next check
**On failure:** Add missing checklist items and re-validate

### Check 6: Orchestrate Compatibility

**Method:** Verify the plan contains requirements, acceptance criteria (in phases), architecture overview, interface contracts between phases, and verification expectations. The plan must be self-contained — handable to `/orchestrate` without additional context.
**On success:** Proceed to next check
**On failure:** Enhance the plan with missing orchestrate-required content

### Check 7: No Time Estimates

**Method:** Search for time-related language (hours, days, weeks, minutes, "quick", "should be fast")
**On success:** Complete validation
**On failure:** Remove all time estimates and re-validate

## Error Handling

### ERR-001: Insufficient Codebase Context

**Symptoms:** Plan makes recommendations that conflict with existing patterns
**Cause:** Exploration step was too shallow

**Resolution:**
1. Return to Step 2
2. Expand exploration scope
3. Re-evaluate decisions against actual codebase patterns
4. Revise plan accordingly

---

### ERR-002: Ambiguous Requirements

**Symptoms:** Plan contains multiple "if X then Y, if Z then W" branches
**Cause:** Requirements weren't clarified before planning

**Resolution:**
1. Identify the specific ambiguity
2. Ask one focused question via AskUserQuestion
3. Update the plan with the clarified direction
4. Remove conditional branches

---

### ERR-003: Plan Too Vague for Orchestrate

**Symptoms:** Plan reads like a wishlist, not an implementation guide
**Cause:** Missing concrete details (files, phases, acceptance criteria)

**Resolution:**
1. Add specific file paths for every change
2. Break phases into concrete tasks
3. Add verification criteria for each phase
4. Ensure the implementation tracking checklist covers every task

---

### ERR-004: Scope Creep

**Symptoms:** Plan keeps growing, includes tangential improvements
**Cause:** Not establishing clear scope boundaries early

**Resolution:**
1. Re-read the original input
2. Remove anything not directly required by the stated goal
3. Move "nice to have" items to a "Future Considerations" section (not tracked in checklist)
4. Confirm scope with user if uncertain

## Summary

After creating the plan, present the structured summary defined in Step 8:

1. **Business Strategy** — Concrete business behaviors, rules, and data relationships
2. **User Journey** *(conditional)* — Step-by-step user flows with happy path, branches, and error states
3. **Design Plan** *(conditional)* — ASCII wireframes, component inventory, interaction patterns, UI states, and responsive behavior
4. **Data Flow** *(conditional)* — Arrow-chain visualization of data moving through system layers
5. **Architectural Plan** — Pattern, decisions, integrations, phase overview
6. **Affected File Structure** — New/modified/deleted files grouped by package

Close with the plan file path and approval prompt.

## References

### Related Commands

- `/orchestrate` - Executes the plan via subagents (consumes this command's output)
- `/commit` - Creates git commit after plan-driven implementation
