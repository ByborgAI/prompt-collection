---
name: cmd
description: Create, rewrite, or extend slash commands following the schema
category: orchestration
version: 1.3
schema: aitt/commands/cmd.md
model: opus
input:
  expects: "Mode and target specification"
  required: true
  format: conditional
---

> **⚠️ Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.

# Cmd

> Create, rewrite, or extend slash commands following the embedded schema specification.

## Purpose

This command serves as both the authoritative schema definition and an operational tool for command authorship. Use it to:

- **Create** new commands from scratch with proper structure
- **Rewrite** existing non-compliant commands to follow the schema
- **Extend** schema-compliant commands with additional functionality

**Use when:**
- Starting a new slash command
- Migrating legacy commands to schema compliance
- Adding features to existing commands while maintaining structure

**Do not use when:**
- Making minor content edits (use direct file editing)
- The target is not a slash command

## Inputs

**Expects:** Mode and target specification
**Required:** Yes

### Mode A: Create (with input)

```
/cmd create <command-name>
```

Creates a new command with the specified name. The command will guide you through:
- Description and category selection
- Command type template selection
- Section-by-section content development

**Example:**
```
/cmd create deploy-staging
```

### Mode B: Rewrite (with input)

```
/cmd rewrite <path-to-command>
```

Transforms an existing non-compliant command to follow the schema. Creates a `.bak` backup before modification.

**Example:**
```
/cmd rewrite .claude/commands/worktree.md
```

### Mode C: Extend (with input)

```
/cmd extend <path-to-command>
```

Adds functionality to an existing schema-compliant command. Can modify any section or add new optional sections.

**Example:**
```
/cmd extend .claude/commands/deploy.md
```

### Mode D: Interactive (no input)

```
/cmd
```

Prompts for mode selection when invoked without arguments.

## Prerequisites

### Gate 1: Valid Mode Detection

**Check:** Input matches one of: `create <name>`, `rewrite <path>`, `extend <path>`, or empty
**Pass:** Proceed to mode-specific gate
**Fail:** Exit with usage guidance

**Fail Output:**
```
Invalid input. Usage:
  /cmd create <command-name>
  /cmd rewrite <path-to-command>
  /cmd extend <path-to-command>
  /cmd                         (interactive mode)
```

---

### Gate 2: Target Validation (rewrite/extend modes)

**Check:** Target file exists at specified path
**Pass:** Proceed to Process
**Fail:** Exit with file not found error

**Fail Output:**
```
Target not found: <path>
Verify the file path and try again.
```

---

### Gate 3: Schema Compliance (extend mode only)

**Check:** Target command follows schema structure (has frontmatter, required sections)
**Pass:** Proceed to Process
**Fail:** Suggest rewrite mode instead

**Fail Output:**
```
Target command is not schema-compliant.
Use '/cmd rewrite <path>' to transform it first.
```

## Process

### Step 1: Parse Input and Determine Mode

Extract mode and target from `$ARGUMENTS`:

```
Input: ""                    → Mode: interactive
Input: "create foo"          → Mode: create, Target: foo
Input: "rewrite path/cmd.md" → Mode: rewrite, Target: path/cmd.md
Input: "extend path/cmd.md"  → Mode: extend, Target: path/cmd.md
```

---

### Step 2: Execute Mode-Specific Workflow

#### Mode: Create

##### Step 2.1: Gather Command Metadata

Prompt user for:
1. **Description** - One-line description (< 80 chars)
2. **Category** - One of: documentation, workflow, analysis, generation, orchestration
3. **Command Type** - One of the 5 templates (see Schema Specification)

##### Step 2.2: Generate Skeleton

Based on selected type, generate command skeleton:

```markdown
---
name: <command-name>
description: <user-provided>
category: <user-selected>
version: 1.0
schema: aitt/commands/cmd.md
input:
  expects: "[To be defined]"
  required: true
  format: free-text
---

> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.

# <Command Name>

> <description>

## Purpose

[Define the command's goal and when to use it]

## Inputs

**Expects:** [What input the command needs]
**Required:** [Yes | No | Conditional]

[Document input format based on command needs]

## Prerequisites

[Define entry conditions if applicable, or remove section]

## Process

### Step 1: [First Action]

[Describe step with implementation details]

### Step 2: [Next Action]

[Continue with process steps]

## Outputs

[Define artifacts produced, or remove section]

## Examples

### Basic Usage
```
/command-name argument
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| [Error type] | [Cause] | [Fix] |

## References

- Schema: `aitt/commands/cmd.md`
```

##### Step 2.3: Guide Content Development

For each section, provide:
1. Section purpose (from Schema Specification)
2. Prompts for content
3. Validation of completeness

##### Step 2.4: Write Command File

Write completed command to `.claude/commands/<name>.md`

---

#### Mode: Rewrite

##### Step 2.1: Read Existing Command

Read target file and analyze current structure.

##### Step 2.2: Extract Intent and Content

Map existing content to schema sections:

| Existing Pattern | Maps To |
|------------------|---------|
| Inline description | Purpose section |
| Arguments/Parameters | Inputs section |
| Workflow/Steps | Process section |
| Notes/Warnings | Error Handling |
| Commands/Code | Process step implementation |

##### Step 2.3: Create Backup

```bash
cp <target> <target>.bak
```

##### Step 2.4: Generate Schema-Compliant Version

Transform content into schema structure while preserving:
- Original functionality and intent
- All process steps and logic
- Error handling information
- Any code examples

##### Step 2.5: Present for Approval

Show diff between original and transformed version. Request user approval before writing.

##### Step 2.6: Write Updated File

Upon approval, write schema-compliant version to target path.

---

#### Mode: Extend

##### Step 2.1: Read Existing Command

Read schema-compliant target file.

##### Step 2.2: Gather Extension Requirements

Prompt user for:
- Which section(s) to modify
- What functionality to add
- Any new sections needed

##### Step 2.3: Generate Modifications

Create additions while:
- Preserving existing structure
- Maintaining schema compliance
- Following section-specific formatting

##### Step 2.4: Present for Approval

Show proposed changes. Request user approval.

##### Step 2.5: Update File

Upon approval, write extended version to target path.

---

#### Mode: Interactive

##### Step 2.1: Present Mode Selection

```
Schema Command - Select Mode:

1. create  - Generate new command from scratch
2. rewrite - Transform existing command to schema
3. extend  - Add functionality to compliant command

Enter mode and target (e.g., 'create my-command'):
```

##### Step 2.2: Route to Appropriate Mode

Parse selection and execute corresponding workflow.

---

### Step 3: Checkpoint — Output Validation

> **GATE:** Do not proceed until satisfied.

- [ ] Output follows schema structure
- [ ] All required sections present (Purpose, Process)
- [ ] Frontmatter complete and valid
- [ ] No schema violations detected

**If not satisfied:** Return to Step 2 and correct issues.

---

### Step 4: Report Completion

Output summary:
- Mode executed
- File path created/modified
- Backup path (if rewrite mode)
- Any warnings or notes

## Outputs

### Files Generated/Modified

**Create mode:**
```
.claude/commands/<name>.md    # New command file
```

**Rewrite mode:**
```
<target>.bak                  # Backup of original
<target>                      # Transformed command
```

**Extend mode:**
```
<target>                      # Extended command
```

### Success Output

```
Schema command completed successfully.

Mode: <create|rewrite|extend>
Target: <path>
Status: <created|rewritten|extended>

[Backup: <path>.bak]          # Rewrite mode only
```

## Validation

### Check 1: Frontmatter Validity

**Method:** Parse YAML frontmatter, verify required fields present
**Required fields:** name, description, category, version

**On success:** Proceed to next check

**On failure:**
1. Identify missing fields
2. Add missing fields with appropriate values
3. Re-validate

---

### Check 2: Section Completeness

**Method:** Verify required sections exist (Purpose, Process minimum)

**On success:** Proceed to next check

**On failure:**
1. Identify missing sections
2. Generate placeholder content
3. Prompt user to complete
4. Re-validate

---

### Check 3: Schema Notice (for created/rewritten commands)

**Method:** Verify schema notice blockquote present after frontmatter

**On success:** Complete validation

**On failure:**
1. Add schema notice:
   ```
   > **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying.
   ```
2. Re-validate

## Error Handling

### ERR-001: Invalid Mode

**Symptoms:** Command fails at input parsing
**Cause:** Unrecognized mode keyword

**Resolution:**
1. Check spelling of mode (create, rewrite, extend)
2. Ensure proper spacing between mode and target
3. Retry with correct syntax

---

### ERR-002: Target Not Found

**Symptoms:** Command fails at Gate 2
**Cause:** File path incorrect or file doesn't exist

**Resolution:**
1. Verify file path is correct (relative to repo root)
2. Check file extension (.md)
3. Use glob to search: `**/*<partial-name>*.md`
4. Retry with correct path

---

### ERR-003: Non-Compliant Target (extend mode)

**Symptoms:** Command fails at Gate 3
**Cause:** Target doesn't follow schema structure

**Resolution:**
1. Use rewrite mode first: `/cmd rewrite <target>`
2. Then use extend mode on the rewritten command

---

### ERR-004: Backup Failed

**Symptoms:** Rewrite mode fails before transformation
**Cause:** Permission or disk space issue

**Resolution:**
1. Check write permissions for target directory
2. Verify sufficient disk space
3. Manually backup file if needed
4. Retry operation

---

### ERR-005: User Rejected Changes

**Symptoms:** Transformation/extension abandoned
**Cause:** User declined approval

**Resolution:**
1. Review proposed changes
2. Modify requirements if needed
3. Re-run command with adjusted approach

## Examples

### Example 1: Create New Command

**Input:**
```
/cmd create deploy-staging
```

**Interaction:**
```
Creating new command: deploy-staging

Description (< 80 chars):
> Deploys application to staging environment

Category:
1. documentation
2. workflow
3. analysis
4. generation
5. orchestration

Select [1-5]: 2

Command Type:
1. Simple Action - Single focused action
2. Delegation - Wraps base command with context
3. Multi-Step Workflow - Orchestrates multiple steps
4. Analysis/Report - Analyzes and produces report
5. Documentation Generation - Creates artifacts from source

Select [1-5]: 3

Generating skeleton...

[Skeleton presented for review]

Proceed with guided content development? [Y/n]
```

**Result:**
```
.claude/commands/deploy-staging.md created
```

---

### Example 2: Rewrite Legacy Command

**Input:**
```
/cmd rewrite .claude/commands/worktree.md
```

**Interaction:**
```
Rewriting: .claude/commands/worktree.md

Analyzing existing structure...

Detected content:
- Description (line 1)
- Arguments section
- Workflow section (5 steps)
- Implementation details

Mapping to schema sections...

[Diff presented]

--- Original
+++ Transformed

-Create a new worktree for a branch.
+---
+name: worktree
+description: Create a new worktree for a branch
+category: workflow
+version: 1.0
+schema: aitt/commands/cmd.md
...

Backup will be created at: .claude/commands/worktree.md.bak

Apply transformation? [Y/n]
```

**Result:**
```
Backup: .claude/commands/worktree.md.bak
Rewritten: .claude/commands/worktree.md
```

---

### Example 3: Extend Existing Command

**Input:**
```
/cmd extend .claude/commands/deploy-staging.md
```

**Interaction:**
```
Extending: .claude/commands/deploy-staging.md

Current sections:
1. Purpose
2. Inputs
3. Process (4 steps)
4. Outputs
5. Error Handling

What would you like to add/modify?
> Add rollback capability to Process section

Generating extension...

[Proposed changes presented]

### Step 5: Rollback (if deployment fails)

If health check fails:
1. Identify previous stable version
2. Execute rollback: `kubectl rollout undo deployment/app`
3. Verify rollback successful
4. Report failure with rollback status

Apply extension? [Y/n]
```

**Result:**
```
Extended: .claude/commands/deploy-staging.md
```

---

### Example 4: Interactive Mode

**Input:**
```
/cmd
```

**Interaction:**
```
Schema Command - Select Mode:

1. create  - Generate new command from scratch
2. rewrite - Transform existing command to schema
3. extend  - Add functionality to compliant command

Enter mode and target: create api-test
```

**Result:** Proceeds with create mode workflow.

## References

### Internal References

- Schema Specification: See below (embedded in this command)
- Command Types: See "Command Type Templates" section

### External References

- Claude Code documentation: https://docs.anthropic.com/claude-code

---
---

# Schema Specification

> **Version:** 1.3
> **Purpose:** Standardized structure for all slash commands in `.claude/commands/`

This specification defines a consistent format for Claude Code slash commands, ensuring clarity, maintainability, and predictable behavior across all commands.

---

## Schema Structure

```yaml
# FRONTMATTER (Optional but recommended)
---
name: command-name
description: One-line description shown in command list
category: documentation | workflow | analysis | generation | orchestration  # examples; custom values allowed
version: 1.0
schema: aitt/commands/cmd.md  # Reference to schema - modifications must follow this
input:
  expects: "Feature name and optional configuration"
  required: true
  format: free-text | json | named-params | none | conditional
---

# BODY (Markdown)
```

---

## Section Reference

| # | Section | Required | Purpose |
|---|---------|----------|---------|
| 1 | Frontmatter | Recommended | Machine-readable metadata |
| 2 | Purpose | Required | What the command does |
| 3 | Key Principles | If applicable | Core philosophy and approach |
| 4 | Inputs | If applicable | Variables, arguments, context |
| 5 | Prerequisites | If applicable | Entry conditions, early-exit gates |
| 6 | Process | Required | Step-by-step execution flow |
| 7 | Outputs | If applicable | Files, reports, artifacts produced |
| 8 | Examples | Recommended | Usage and output examples |
| 9 | Validation | If applicable | Post-execution checks with fix procedures |
| 10 | Cleanup | If applicable | Resource cleanup after execution |
| 11 | Error Handling | Recommended | Failure modes and recovery |
| 12 | References | If applicable | Related commands, external docs |

---

## Complete Template

```markdown
---
name: example-command
description: Brief description for command listing
category: documentation
version: 1.0
schema: aitt/commands/cmd.md  # Schema reference - modifications must follow this
model: sonnet                    # Optional: preferred model (sonnet|opus|haiku)
tools: [Read, Write, Glob]       # Optional: allowed tools
mcp_servers: [chrome]            # Optional: required MCP servers
input:                           # Optional: quick input summary
  expects: "Target name"
  required: true
  format: free-text
---

> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying. If not found, ask user.

# Command Name

> Brief one-sentence description of what this command accomplishes.

## Purpose

Expanded description of the command's goal and when to use it.

## Key Principles (Optional)

**[Principle Name]:**
Core concept or philosophy that guides this command's approach.

**Anti-Pattern to Avoid:**
- **Wrong:** Description of incorrect approach
- **Correct:** Description of correct approach

## Inputs

**Expects:** Target name and optional configuration
**Required:** Target required, options optional

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| Target | Yes | string | The target to process |
| Options | No | JSON | Additional configuration |

### Usage
```
/example-command MyTarget
/example-command MyTarget {"verbose": true}
```

## Prerequisites

### Check 1: [Condition Name]

**Check:** What to verify
**Pass:** Proceed to next check
**Fail:** Exit with [output/message]

### Check 2: [Condition Name]

**Check:** What to verify
**Pass:** Proceed to Process
**Fail:** Exit with [output/message]

## Process

### Step 1: Initialization
Description of first step.

```bash
# Commands to execute
npm run setup --target=$TARGET
```

### Step 2: Execution
Description of second step.

#### Case A: Condition Met
- Action when condition is true

#### Case B: Condition Not Met
- Action when condition is false

#### Output Schema
```json
{
  "result": "success | error",
  "data": { }
}
```

### Step 3: Checkpoint — Quality Gate

> **GATE:** Do not proceed until satisfied.

- [ ] Condition 1 met
- [ ] Condition 2 met

**If not satisfied:** Return to Step 2

### Step 4: Finalization
Description of final step.

#### Implementation
```javascript
// Update status in registry
const data = JSON.parse(fs.readFileSync('registry.json'));
data.status = 'completed';
fs.writeFileSync('registry.json', JSON.stringify(data, null, 2));
```

## Outputs

### Files Generated
```
output-folder/
├── artifact-1.md
├── artifact-2.mmd
└── artifact-3.json
```

### Output Format
Description or schema of output structure.

## Examples

### Basic Usage
```
/example-command MyTarget
```

### With Options
```
/example-command MyTarget {"option": "value"}
```

### Example Output
```markdown
# Generated Report
...
```

## Validation

### Check 1: Schema Compliance

**Method:** Run `validation-command`
**On success:** Proceed to next check
**On failure:**
1. Identify invalid fields from error output
2. Fix each violation
3. Re-run validation
4. Repeat until passes

### Check 2: Content Accuracy

**Method:** Cross-reference output against source
**On success:** Proceed to Cleanup
**On failure:**
1. Identify discrepancy
2. Correct output
3. Re-validate

## Cleanup

**If [resource was used]:**
- Cleanup action 1
- Cleanup action 2

**If [resource was not used]:**
- No cleanup required

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| `Target not found` | Invalid input | Verify target exists |
| `Missing dependency` | Prerequisite not met | Run `/prerequisite` first |

## References

- Related: `/related-command`
- External: [Documentation Link](url)
- Depends on: `/dependency-command`
```

---

## Section Specifications

### 1. Frontmatter

YAML metadata block for machine parsing.

```yaml
---
name: kebab-case-name          # Command identifier
description: string            # One-line description (< 80 chars)
category: enum                 # See categories below
version: semver                # Schema version (e.g., 1.0)
author: string                 # Optional creator
requires: [string]             # Optional dependencies
schema: aitt/commands/cmd.md  # Schema this command follows (recommended)

# Execution Control (Optional)
model: sonnet | opus | haiku   # Preferred Claude model
tools: [Tool1, Tool2]          # Allowed tools whitelist
mcp_servers: [server1]         # Required MCP servers

# Input Definition (Optional - choose format that fits)
input:
  expects: string              # Brief description of expected input
  required: boolean            # Is input required?
  format: free-text | json | named-params | none | conditional
---
```

**Note:** The `input` property in frontmatter provides a quick summary. Detailed input documentation belongs in the Inputs section of the command body.

**Schema Reference:**
The `schema` property declares which schema this command follows. When present:
- Agents modifying the command MUST read and follow the referenced schema
- If the schema file is not found, agents MUST ask the user for the schema location before making modifications
- This ensures structural consistency across command updates

**Required Schema Notice:**
Commands following this schema MUST include a visible notice immediately after the frontmatter:
```markdown
> **Schema:** This command follows `aitt/commands/cmd.md`. Read schema before modifying. If not found, ask user.
```
This ensures future agents see the schema requirement even if they don't parse frontmatter.

**Categories:**
- `documentation` - Generates docs, specs, diagrams
- `workflow` - Orchestrates multi-step processes
- `analysis` - Inspects code/data, produces reports
- `generation` - Creates code, files, artifacts
- `orchestration` - Coordinates other commands/agents

**Execution Control Properties:**
- `model` - Specify preferred Claude model for this command
- `tools` - Whitelist of tools the command may use
- `mcp_servers` - MCP servers required for command execution

---

### 2. Purpose

Clear statement of what the command does.

```markdown
## Purpose

This command [action verb] [target] to [outcome].

**Use when:**
- Scenario 1
- Scenario 2

**Do not use when:**
- Anti-pattern 1
```

---

### 3. Key Principles

Optional section describing the core philosophy, approach, and guiding concepts that inform how the command works. Useful for complex commands where understanding the "why" helps users apply the command correctly.

```markdown
## Key Principles

**[Principle Name]:**
Description of the core concept or philosophy.

**[Another Principle]:**
Description of another guiding principle.

**Anti-Pattern to Avoid:**
- **Wrong:** Description of incorrect approach or common mistake
- **Correct:** Description of the right way to think about it
```

**When to include Key Principles:**
- Command has a specific methodology or approach that isn't obvious
- There are common misconceptions about how the command should be used
- The command embodies a particular philosophy (e.g., "transaction completeness" vs "module boundaries")
- Understanding the principles helps users make better decisions during execution

**Example principles:**
- **Transaction Completeness:** "Documentation captures the entire user transaction from action to idle state"
- **Source Truth:** "Source code is authoritative—documentation must match implementation"
- **1:1 Correspondence:** "Every BDD scenario must have a corresponding flowchart path"

---

### 4. Inputs

Document what input the command expects. The format is flexible—choose the structure that best describes your command's input requirements.

#### Input Summary (Required)

Always start with a brief summary of input expectations:

```markdown
## Inputs

**Expects:** [Description of what input the command needs]
**Required:** Yes | No | Conditional
```

#### Format A: Free Text

For commands accepting natural language or simple string input:

```markdown
## Inputs

**Expects:** Free text describing the target
**Required:** Yes

The command accepts `$ARGUMENTS` as free-form text input.

**Examples:**
- `/command analyze the login flow`
- `/command Email/Password Login`
- `/command "feature name with spaces"`
```

#### Format B: Structured (JSON/YAML)

For commands expecting structured data:

```markdown
## Inputs

**Expects:** JSON object with feature metadata
**Required:** Yes

### Schema
```json
{
  "feature_name": "string (required)",
  "category": "string (required)",
  "evidence": ["array of file paths (optional)"]
}
```

### Example
```json
{
  "feature_name": "User Login",
  "category": "Authentication"
}
```
```

#### Format C: Named Parameters

For commands with multiple distinct inputs:

```markdown
## Inputs

**Expects:** Feature name and optional configuration
**Required:** Feature name required, options optional

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| Feature name | Yes | string | Name of feature to process |
| Options | No | JSON | Additional configuration |

### Usage Patterns
```
/command FeatureName
/command FeatureName {"verbose": true}
```
```

#### Format D: No Input

For commands that operate without user input:

```markdown
## Inputs

**Expects:** None
**Required:** No

This command auto-detects its target based on [context/state/configuration].
```

#### Format E: Conditional Input

For commands with mode-dependent inputs:

```markdown
## Inputs

**Expects:** Optional target specification
**Required:** Conditional

### Mode A: Auto-Select (no input)
```
/command
```
Command automatically selects next item from queue.

### Mode B: Specific Target (with input)
```
/command TargetName
```
Command processes the specified target.
```

#### Context Files (Optional)

If the command auto-loads context files:

```markdown
### Context Files
- `@path/to/config.md` - Loaded automatically for [purpose]
- `@path/to/data.json` - Required data source
```

---

### 5. Prerequisites

Entry conditions that must be satisfied before the main process begins. If any prerequisite fails, the command exits early with an appropriate message or error output.

```markdown
## Prerequisites

### Gate 1: [Condition Name]

**Check:** Description of what to verify
**Pass:** Proceed to next gate
**Fail:** Exit with [specific output or message]

**Fail Output Template (if applicable):**
```yaml
status: "error"
error_type: "prerequisite_failed"
message: "Description of why prerequisite was not met"
```

---

### Gate 2: [Condition Name]

**Check:** Description of what to verify
**Pass:** Proceed to Process
**Fail:** Exit with [specific output or message]
```

**Key characteristics:**
- Prerequisites run BEFORE the main process
- Each gate is evaluated in order
- Failure causes immediate exit (no partial execution)
- Fail outputs can include structured error artifacts
- All gates must pass to proceed to Process

**Common prerequisite patterns:**
- Check if output already exists (skip/overwrite decision)
- Validate target accessibility (URL reachable, file exists)
- Verify required dependencies are available
- Confirm required MCP servers are connected

---

### 6. Process

Step-by-step execution with clear decision points. Includes support for checkpoints, special case handling, and embedded implementation details.

#### Embedding Implementation Details

**Steps SHOULD include concrete implementation details** when they help clarify execution. This includes:

| Content Type | When to Include | Example |
|--------------|-----------------|---------|
| Bash commands | CLI operations, file manipulation, tool invocation | `npx mmdc -i file.mmd -o output.svg` |
| Code snippets | Programmatic logic, data transformations | JavaScript, Python, etc. |
| Schema definitions | Data structures the step produces or consumes | JSON Schema, TypeScript interfaces |
| File templates | Content structure for generated files | Markdown templates, config files |
| Search patterns | Grep/glob patterns for discovery | `grep -r "ClassName" --include="*.kt"` |
| API examples | Request/response structures | REST endpoints, GraphQL queries |

**Principle:** If an agent would need to guess HOW to implement a step, the step lacks sufficient detail. Include the implementation inline.

```markdown
## Process

### Step 1: [Action Verb] [Target]

Description of what happens.

```bash
# Concrete command to execute
npx some-tool --input file.json --output result.md
```

#### Substep 1.1: Condition Handling

**If** condition A:
- Action 1
- Action 2

**Else if** condition B:
- Alternative action

**Else:**
- Default action

### Step 2: [Next Action]

Continue with next logical step...

#### Output Schema

When this step produces structured data, define the schema:

```json
{
  "status": "completed | failed",
  "output_path": "string",
  "metadata": {
    "created_at": "ISO8601 timestamp",
    "source_files": ["array of paths"]
  }
}
```

#### Implementation

```javascript
// Inline code when logic is non-trivial
const result = processInput(data);
if (result.valid) {
  writeOutput(result.data);
}
```

### Step 3: Checkpoint — [Gate Name]

> **GATE:** Do not proceed until all conditions are satisfied.

- [ ] Condition 1 verified
- [ ] Condition 2 verified
- [ ] Minimum threshold met

**If not satisfied:** Return to Step 2 and continue work

---

### Step 4: Process Items

General procedure for processing items.

#### Special Cases

**[Item Type A]:**
- Override behavior 1
- Special handling instructions

**[Item Type B]:**
- Different handling approach
- Specific requirements

### Step N: Completion

Final step and what success looks like.
```

#### Checkpoint Steps

Checkpoints are mid-process gates that pause execution until conditions are met:

```markdown
### Step N: Checkpoint — [Descriptive Name]

> **GATE:** Do not proceed until satisfied.

- [ ] Condition 1
- [ ] Condition 2

**If not satisfied:** [Recovery action - typically return to earlier step]
```

**Checkpoint characteristics:**
- Explicitly marked with "Checkpoint —" prefix
- Include blockquote with **GATE:** indicator
- List conditions as checkboxes
- Specify recovery action if conditions not met

#### Special Cases Subsection

When process steps have item-specific overrides:

```markdown
### Step N: Process Items

[General procedure description]

#### Special Cases

**[Item Type A]:**
- Override 1
- Override 2

**[Item Type B]:**
- Different handling
```

#### Common Step Subsection Patterns

Use these subsection headers within steps to organize implementation details:

| Subsection | Purpose | Example Content |
|------------|---------|-----------------|
| `#### Implementation` | Code that executes the step | JavaScript, Python, bash scripts |
| `#### Output Schema` | Structure of data produced | JSON schema, TypeScript interface |
| `#### Input Schema` | Structure of data consumed | JSON schema with validation rules |
| `#### Search Patterns` | Patterns for file/content discovery | Glob patterns, grep regex |
| `#### File Template` | Template for generated files | Markdown structure, config format |
| `#### API Request` | External API call details | Endpoint, headers, body |
| `#### Validation Rules` | Criteria the step must satisfy | Business rules, format requirements |

**Example step with implementation details:**

```markdown
### Step 3: Update Feature Registry

Update the feature status in the registry file.

#### Input Schema
```json
{
  "feature_name": "string (required)",
  "status": "pending | completed | failed"
}
```

#### Implementation
```bash
node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('registry.json', 'utf8'));
const feature = data.find(f => f.name === '${FEATURE_NAME}');
feature.status = 'completed';
feature.updated_at = new Date().toISOString();
fs.writeFileSync('registry.json', JSON.stringify(data, null, 2));
"
```

#### Validation Rules
- Feature must exist in registry before update
- Status must be one of: pending, completed, failed
- updated_at must be valid ISO8601 timestamp
```

---

### 7. Outputs

Specify all artifacts produced.

```markdown
## Outputs

### Directory Structure
```
output-folder/
├── file-1.ext     # Description
├── file-2.ext     # Description
└── subfolder/
    └── file-3.ext # Description
```

### File Schemas

#### file-1.ext
```json
{
  "schema": "definition"
}
```

### Console Output
Description of what gets printed/displayed.
```

---

### 8. Examples

Show concrete usage patterns.

```markdown
## Examples

### Example 1: Basic Usage
**Input:**
```
/command-name simple-argument
```

**Result:**
Description of outcome.

### Example 2: Complex Usage
**Input:**
```
/command-name {"complex": "json", "input": true}
```

**Result:**
```markdown
# Generated Output
Content here...
```

### Good vs Bad Examples

#### Good
```
/command-name correct-usage
```
**Why:** Explanation

#### Bad
```
/command-name incorrect-usage
```
**Why:** Explanation
```

---

### 9. Validation

Post-execution validation with support for fix-and-retry procedures. Validation runs AFTER the main process completes and BEFORE cleanup.

#### Format A: Simple Checks

For straightforward pass/fail validation:

```markdown
## Validation

- [ ] Output file exists
- [ ] JSON is well-formed
- [ ] Required fields present
- [ ] Values within expected ranges
```

#### Format B: Validation with Fix Procedures

For validations that include remediation workflows:

```markdown
## Validation

### Check 1: Schema Compliance

**Method:** Run `npx ajv-cli validate -s schema.json -d output.yaml`

**On success:** Proceed to next check

**On failure:**
1. Read error output to identify invalid fields
2. Use Edit tool to fix each violation
3. Re-run validation command
4. Repeat until validation passes

**Max retries:** Until success

---

### Check 2: Content Accuracy

**Method:** Cross-reference each output field against source data

**On success:** Proceed to Cleanup

**On failure:**
1. Identify discrepancy between output and source
2. Return to source, verify correct value
3. Update output with corrected value
4. Re-validate this check

**Max retries:** 3 (then flag for manual review)

---

### Check 3: Consistency

**Method:** Compare related outputs for contradictions

**On success:** Complete validation

**On failure:**
1. Identify contradicting statements
2. Determine authoritative source
3. Correct non-authoritative output
4. Re-validate
```

**Validation check structure:**
- **Method** — How to perform the check (command, manual review, comparison)
- **On success** — Next action (proceed to next check, proceed to cleanup, complete)
- **On failure** — Step-by-step fix procedure
- **Max retries** — How many fix attempts before escalation (optional)

**Key principles:**
- Validation is post-execution only (pre-execution checks belong in Prerequisites)
- Each check should have a clear fix procedure, not just pass/fail
- External tool validation (schema validators, linters) is supported
- Fix-and-retry loops continue until success or max retries reached

---

### 10. Cleanup

Resource cleanup after command execution. Runs after validation, regardless of success or failure.

```markdown
## Cleanup

**If [resource/tool was used]:**
1. Cleanup action 1
2. Cleanup action 2
3. Verify cleanup complete

**If [resource/tool was not used]:**
- No cleanup required
```

**Common cleanup patterns:**

```markdown
## Cleanup

**If Chrome MCP was used:**
1. Close all browser tabs opened during execution
2. Verify no tabs remain from this session

**If temporary files were created:**
1. Delete files in `/tmp/command-workspace/`
2. Remove empty directories

**If external connections were opened:**
1. Close database connections
2. Terminate API sessions
3. Release file locks

**If no resources require cleanup:**
- No cleanup required
```

**Key characteristics:**
- Cleanup runs AFTER validation completes
- Cleanup should execute regardless of command success/failure
- Conditional cleanup based on which execution paths were taken
- Verify cleanup actions completed successfully

---

### 11. Error Handling

Document failure modes and recovery. Use the appropriate format based on complexity.

```markdown
## Error Handling

### ERR-001: Target Not Found

**Symptoms:**
- Command reports "Target X not found"
- No output files generated

**Possible Causes:**
1. File path is incorrect or relative
2. Target was renamed or moved
3. Target exists but in unexpected location

**Resolution Steps:**
1. Verify the target path is absolute
2. Search for the target using glob patterns:
   ```bash
   find . -name "*target-name*"
   ```
3. Check recent git history for renames:
   ```bash
   git log --follow --name-only -- "*target*"
   ```
4. If found in new location, update input and retry

**Prevention:**
- Always use absolute paths
- Run `/verify-paths` before complex operations

### ERR-002: Validation Failure

**Symptoms:**
- Output generated but marked invalid
- Consistency check fails

**Diagnosis Checklist:**
- [ ] Source files unchanged since analysis started?
- [ ] All dependencies resolved?
- [ ] Output schema matches expected format?

**Resolution by Cause:**

**If source changed during execution:**
- Discard output
- Re-run command with fresh source state

**If dependency missing:**
- Identify missing dependency from error log
- Run prerequisite command first
- Retry original command

**If schema mismatch:**
- Compare output against schema definition
- Identify malformed sections
- Manually correct or regenerate affected sections

### ERR-003: Partial Completion

**Symptoms:**
- Some outputs generated, others missing
- Command terminated unexpectedly

**Recovery Procedure:**
1. Check which outputs exist:
   ```
   output/
   ├── file-1.md  ✓ (exists)
   ├── file-2.md  ✗ (missing)
   └── file-3.md  ✓ (exists)
   ```
2. Determine if partial outputs are usable
3. Options:
   - **Resume:** Re-run command (idempotent commands only)
   - **Complete manually:** Generate missing files individually
   - **Rollback:** Delete partial outputs, fix cause, restart

**Do NOT:**
- Assume partial outputs are complete
- Mix outputs from multiple runs without verification
```

---

### 12. References

Link related resources.

```markdown
## References

### Related Commands
- `/related-1` - Relationship description
- `/related-2` - Relationship description

### Dependencies
- `/prerequisite` - Must run before this command

### External Documentation
- [Link Text](url) - Description

### Source Files
- `path/to/implementation` - Purpose
```

---

## Command Type Templates

### Type A: Simple Action Command

```markdown
---
name: simple-action
description: Performs a single focused action
category: generation
input:
  expects: "Target to process"
  required: true
  format: free-text
---

# Simple Action

> Performs [action] on [target].

## Purpose

[One paragraph description]

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `$TARGET` | string | The target to process |

## Process

1. Read input
2. Execute action
3. Output result

## Outputs

- Single file or console output

## Examples

```
/simple-action my-target
```
```

---

### Type B: Delegation Command

```markdown
---
name: platform-specific
description: Delegates to base command with platform context
category: orchestration
requires: [base-command]
input:
  expects: "Arguments to pass to base command"
  required: true
  format: json
---

# Platform-Specific Command

> Executes base command with platform-specific configuration.

## Purpose

Wrapper that applies platform context to the base command.

## Configuration

| Setting | Value |
|---------|-------|
| Output folder | `platform/` |
| Source location | `source-path/` |

## Process

Execute `@.claude/commands/base-command.md` with:
1. Platform-specific output paths
2. Platform-specific source paths
3. All other base command instructions

## Inputs

Pass through: `$ARGUMENTS`

## Outputs

Same as base command, in platform-specific directory.
```

---

### Type C: Multi-Step Workflow

```markdown
---
name: workflow-command
description: Orchestrates multiple steps or commands
category: workflow
input:
  expects: "Optional workflow arguments"
  required: false
  format: free-text
---

# Workflow Command

> Orchestrates [workflow description].

## Purpose

Coordinates multiple steps/commands to achieve [goal].

## Process Overview

```
Step 1 ──► Step 2 ──► Step 3 ──► Complete
              │
              ▼
         [Parallel]
         /        \
    Step 2a    Step 2b
         \        /
          ──►──►──
```

## Process

### Step 1: Setup
[Description]

### Step 2: Parallel Execution
Launch simultaneously:
- **Task A:** Description
- **Task B:** Description

### Step 3: Aggregation
Combine results from parallel tasks.

### Step 4: Completion
Final actions and reporting.

## Error Handling

### Step Failures
- Step 1 fails: Abort workflow
- Step 2a fails: Continue with 2b, mark partial
- Step 3 fails: Retry once, then abort

## Status Tracking

| Status | Meaning |
|--------|---------|
| `pending` | Not started |
| `in_progress` | Currently executing |
| `completed` | Successfully finished |
| `failed` | Error occurred |
```

---

### Type D: Analysis/Report Command

```markdown
---
name: analysis-command
description: Analyzes target and produces report
category: analysis
input:
  expects: "Target to analyze"
  required: true
  format: free-text
---

# Analysis Command

> Analyzes [target] and produces [report type].

## Purpose

Performs comprehensive analysis of [target] to identify [findings].

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `$TARGET` | string | What to analyze |

## Analysis Scope

### Include
- Item type 1
- Item type 2

### Exclude
- Excluded item type 1

## Process

### Step 1: Discovery
Locate and enumerate targets.

### Step 2: Analysis
For each target:
- Check aspect 1
- Check aspect 2
- Record findings

### Step 3: Synthesis
Aggregate findings into report.

## Output Format

### Report Structure
```markdown
# Analysis Report: [Target]

## Summary
[Executive summary]

## Findings

### Category 1
| Finding | Severity | Location |
|---------|----------|----------|
| ... | ... | ... |

## Recommendations
[Prioritized recommendations]
```

## Validation

- [ ] All targets analyzed
- [ ] No false positives
- [ ] Recommendations actionable
```

---

### Type E: Documentation Generation

```markdown
---
name: doc-generator
description: Generates documentation from source analysis
category: documentation
input:
  expects: "Feature metadata object"
  required: true
  format: json
---

# Documentation Generator

> Generates comprehensive documentation for [target].

## Purpose

Analyzes source code and produces documentation artifacts.

## Inputs

### JSON Schema
```json
{
  "feature_name": "string (required)",
  "category": "string (required)",
  "evidence": ["array of file paths"]
}
```

## Process

### Step 1: Parse Input
Extract metadata from JSON input.

### Step 2: Resolve Evidence
Locate all referenced source files.

### Step 3: Analyze
Deep analysis of source code behavior.

### Step 4: Generate Artifacts
Create documentation files.

### Step 5: Validate
Cross-check artifacts for consistency.

## Outputs

### File Structure
```
${feature-name}/
├── ${feature-name}.spec.md      # Specification
├── ${feature-name}.diagram.mmd  # Visual diagram
└── ${feature-name}.notes.md     # Additional notes
```

### Artifact Specifications

#### spec.md
- Metadata section
- Overview
- Detailed scenarios
- References

#### diagram.mmd
- Mermaid syntax
- Color-coded paths
- All decision points

## Validation

### Consistency Checks
- [ ] All scenarios in spec have diagram paths
- [ ] All diagram paths match spec scenarios
- [ ] Evidence files resolved
- [ ] Syntax validated
```

---

## Best Practices

### Writing Style

**Principles:**
1. Structure conveys importance—all steps are required by default
2. Concise over verbose—every word must earn its place
3. Complete over brief—include all details, but no filler

**Conciseness guidelines:**

| Verbose (avoid) | Concise (prefer) |
|-----------------|------------------|
| "In order to accomplish this task, you will need to..." | "Run:" |
| "It is important to note that the system will..." | "The system..." |
| "The next step involves performing the action of..." | "Next:" |
| "Please ensure that you have completed..." | "Verify:" |
| "This particular feature is responsible for..." | "This feature..." |
| "At this point in time, the process will..." | "The process..." |

**Write like a reference manual, not a tutorial.** Assume the reader is competent. State facts. Omit preamble.

```markdown
❌ "Before we begin, it's worth mentioning that you'll want to make sure
    that all of your dependencies are properly installed and configured
    before attempting to run this command."

✓  "Prerequisite: Dependencies installed."
```

**Prohibited patterns:**
```markdown
❌ *** MANDATORY ***
❌ CRITICAL: You MUST do this
❌ IMPORTANT: Do not skip this step
❌ **NOTE:** This is essential
❌ WARNING: Required action
❌ !!! ATTENTION !!!
❌ [REQUIRED] Step description
❌ Step description (MUST DO)
```

**Correct approach:**
```markdown
✓ Step description                    # All steps are required by default
✓ (Optional) Step description         # Explicitly mark optional items
✓ > **GATE:** Do not proceed...       # Use schema-defined checkpoints for critical gates
✓ **If not satisfied:** Return to...  # Use structured conditions, not shouty warnings
```

**Rationale:**
- When everything is marked "CRITICAL," nothing stands out
- The schema's structure (Prerequisites, Checkpoints, Validation) already indicates importance
- Agents reading the command will follow ALL steps—emphasis markers add noise, not compliance
- Use `(Optional)` to mark non-required items rather than marking required items as required

**Allowed emphasis:**
- `> **GATE:**` blockquotes for mid-process checkpoints (schema-defined pattern)
- Bold for **structural labels** (Check:, Pass:, Fail:, Method:, etc.)
- Code formatting for `commands`, `paths`, and `values`
- Tables and structured formats for complex information

**Anti-pattern to avoid:**
- **Wrong:** "*** CRITICAL *** You MUST verify this step is complete before proceeding!!!"
- **Correct:** Document the step. Use a checkpoint if verification is needed before continuing.

### Naming Conventions
- Use `kebab-case` for command names
- Use `SCREAMING_SNAKE_CASE` for variables
- Use descriptive, action-oriented names

### Documentation Quality
- Lead with purpose—what and why
- Process steps should be actionable
- Include both success and failure paths
- Provide concrete examples
- Assume all steps are required—mark exceptions with `(Optional)`

### Maintainability
- Keep commands focused (single responsibility)
- Extract common logic to base commands
- Version your commands
- Document breaking changes

### User Experience
- Provide helpful error messages
- Show progress for long operations
- Support both simple and advanced usage
- Include "good vs bad" examples

---

## Migration Guide

To convert an existing command to this schema:

1. **Extract metadata** into frontmatter
2. **Identify sections** in existing content
3. **Reorganize** into schema sections
4. **Add missing sections** (error handling, validation)
5. **Standardize formatting** (tables, code blocks)
6. **Add examples** if missing
7. **Validate** against schema

---

## Changelog

### Version 1.3
- Added "Writing Style" section to Best Practices
- Established three principles: structure conveys importance, concise over verbose, complete over brief
- Added conciseness guidelines with verbose/concise comparison table
- Added guidance: "Write like a reference manual, not a tutorial"
- Defined prohibited emphasis patterns (MANDATORY, CRITICAL, IMPORTANT, etc.)
- Added guidance to mark optional items with `(Optional)` rather than marking required items as required
- Documented allowed emphasis patterns (GATE: blockquotes, structural labels, code formatting)

### Version 1.2
- Added `schema` frontmatter property for declaring schema compliance
- Added required visible schema notice after frontmatter (blockquote format)
- Schema reference ensures agents read and follow schema when modifying commands
- If schema file not found, agents must ask user for schema location
- Enhanced Process section with "Embedding Implementation Details" guidance
- Added explicit encouragement for bash commands, code snippets, and schemas within steps
- Added "Common Step Subsection Patterns" table (Implementation, Output Schema, Input Schema, Search Patterns, File Template, API Request, Validation Rules)
- Updated Complete Template with concrete implementation examples
- Added principle: "If an agent would need to guess HOW to implement a step, the step lacks sufficient detail"

### Version 1.1
- Added Key Principles section for documenting core philosophy and approach
- Added Prerequisites section for entry gates with early-exit support
- Added Cleanup section for resource management
- Extended Frontmatter with `model`, `tools`, `mcp_servers` properties
- Added Checkpoint step type for mid-process gates in Process section
- Added Special Cases subsection pattern for item-specific overrides
- Refactored Validation to focus on post-execution with fix procedures
- Removed pre-execution checks from Validation (moved to Prerequisites)
- Refactored Inputs section to be format-agnostic (free text, JSON, named params, none, conditional)
- Replaced rigid `variables` frontmatter with flexible `input` summary
- Removed Common Anti-Patterns from Error Handling (author's discretion)
- Renumbered sections to accommodate new additions (now 12 sections)

### Version 1.0
- Initial schema definition
- Five command type templates
- Section specifications
- Best practices guide
