# Requirement Gathering Workflow (RGW) Plugin - Complete Guide

## Overview

The Requirement Gathering Workflow (RGW) is a structured workflow plugin for Claude Code that transforms ad-hoc development into a disciplined, predictable process. It ensures requirements are thoroughly understood before implementation begins and that implementation follows best practices with proper tracking and validation.

## Core Concept

RGW enforces a three-phase workflow for software development:

1. **Requirement Gathering** - Interactive discovery of comprehensive project requirements
2. **Task Generation** - Automatic breakdown into actionable, sequenced tasks
3. **Task Execution** - Systematic implementation with status tracking and auto-commits

## Installation

### Prerequisites

- Claude Code installed
- `jq` - JSON processor (install via `brew install jq` on macOS)
- `yq` - YAML processor (install via `brew install yq` on macOS)
- Git repository initialized in your project

### Install Steps

1. Install the plugin via Claude Code CLI:
   ```bash
   /plugin marketplace add ByborgAI/prompt-collection
   /plugin install rgw@prompt-collection
   ```

2. (Optional) Add file permissions to `.claude/settings.json`:
   ```json
   {
     "permissions": {
       "allow": [
         "Read(requirements.yaml)",
         "Write(requirements.yaml)",
         "Read(task-*.yaml)",
         "Write(task-*.yaml)"
       ]
     }
   }
   ```

3. Add to `.gitignore`:
   ```
   task-*.yaml
   requirements.yaml
   ```

## Workflow Phases

### Phase 1: Planning (`/rgw:plan`)

The planning phase begins with:
```
/rgw:plan
```

#### What Happens:

1. **Prerequisite Check**
   - Claude checks if `requirements.yaml` already exists
   - If it exists, offers two options:
     - **Fresh Plan**: Start from scratch (deletes existing requirements and tasks)
     - **Replan**: Update existing requirements and regenerate tasks

2. **Codebase Analysis**
   - Claude searches for existing patterns and architectural decisions
   - Identifies similar implementations to use as templates
   - Determines complexity and affected files

3. **Interactive Requirement Gathering**
   - For Fresh Plan: Questions asked ONE BY ONE in priority order:
     - **Architecture & Approach**: Core technical decisions
     - **Dependencies & Integration**: External systems, libraries, APIs
     - **Data & State Management**: Storage, persistence, state handling
     - **Security & Performance**: Authentication, authorization, scalability
     - **Interface & UX**: User interactions, API contracts
     - **Implementation Details**: Specific technical approaches
   - For Replan: Reviews existing requirements and asks for updates/additions

4. **Requirements Documentation**
   - Generates/updates `requirements.yaml` with structured requirements
   - Waits for user approval before proceeding

5. **Task Generation**
   - For Replan: First deletes all existing `task-*.yaml` files
   - Creates individual `task-XXX.yaml` files for each implementation step
   - Each task is self-contained and individually executable
   - Tasks include testing requirements and commit messages

**Important**: The planning phase ends after task generation. If Claude tries to continue to execution automatically, stop it.

### Phase 2: Execution (`/rgw:execute`)

Execute tasks in two ways:

1. **All tasks sequentially**:
   ```
   /rgw:execute
   ```

2. **Single task**:
   ```
   /rgw:execute task-001.yaml
   ```

#### Execution Workflow:

1. Task status changes: `to do` → `in progress`
2. Claude implements the required changes
3. All modified files are tracked
4. Status changes to `under review`
5. User reviews and approves changes
6. Upon approval, status becomes `done`
7. Automatic git commit with predefined message

#### Key Constraints:

- Only ONE task can be "in progress" at a time
- No code modifications allowed without an active task
- User approval required before marking tasks "done"
- Automatic commits when tasks complete

## File Formats

### requirements.yaml Structure

```yaml
original_request: string              # User's original input
goal: string                          # High-level goal description
complete: boolean                     # Requirement gathering status
requirements:
  - category: architecture|dependencies|data|security|interface|implementation
    question: string                  # The requirement question
    answer: string                    # Response (when answered)
    details: [string]                 # Technical implications
    options: [string]                 # Available choices
    status: pending|answered          # Current state
constraints:
  - type: technical|business|security
    description: string               # Constraint description
    impact: string                    # Implementation impact
success_criteria: [string]            # Criteria defining success
```

### task-XXX.yaml Structure

```yaml
name: string                          # Concise task name
status: to do|in progress|under review|done
description: string                   # Detailed task description
commit_message: string                # Git commit message
prerequisites:                        # Requirements before starting
  - string
steps:                               # Sequential implementation steps
  - name: string
    description: string
    acceptance:                      # Step completion criteria
      - string
validation:                          # Task completion criteria
  - string
changed_files: []                    # Filled by hooks
```

## Workflow Enforcement

### Hooks

The plugin uses three hooks to enforce workflow discipline:

#### session-start.sh
- Verifies dependencies (jq, yq) are installed
- Sets up environment for workflow execution

#### pre-tool-use.sh
- Validates task status transitions
- Prevents code modifications without active task
- Prepares for auto-commit when task marked "done"
- Ensures only one task is "in progress"

#### post-tool-use.sh
- Tracks all file changes in active task
- Validates requirements.yaml structure
- Validates task YAML syntax
- Runs linting on modified files

## Coding Standards

The workflow enforces these principles:

### Core Principles
- **SOLID** - Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion
- **DRY** - Don't Repeat Yourself
- **YAGNI** - You Aren't Gonna Need It
- **KISS** - Keep It Simple, Stupid
- **Composition over Inheritance**

### Project-First Adaptation
- Always analyze existing codebase patterns first
- Match existing naming conventions and file structure
- Maintain consistency with established coding style
- Respect existing dependency management

### Quality Requirements
- Proper error handling with specific messages
- Input validation and edge case handling
- Self-documenting code with clear naming
- Test coverage for new functionality
- Security best practices (OWASP guidelines)

## Communication Standards

During requirement gathering, Claude follows these principles:

- **Direct and Concise** - No unnecessary preambles
- **Structured Format** - Bullet points over paragraphs
- **Technical Precision** - Exact file paths, line numbers, error messages
- **Proactive Analysis** - Check existing code before asking
- **Numbered Options** - Easy reference for answers
- **Context Inclusion** - Technical background when relevant

## Plugin Structure

```
rgw/
├── .claude-plugin/
│   └── plugin.json                  # Plugin manifest
├── commands/                        # Slash commands
│   ├── plan.md                     # /rgw:plan command
│   └── execute.md                  # /rgw:execute command
├── context/                         # Workflow documentation
│   ├── workflow/
│   │   ├── requirement-gathering.md
│   │   ├── task-generation.md
│   │   └── task-execution.md
│   ├── syntaxes/
│   │   ├── requirements-syntax.md
│   │   └── task-syntax.md
│   ├── standards/
│   │   ├── coding-standards.md
│   │   └── communication-standards.md
│   ├── verify-requirements.md
│   └── verify-task.md
└── hooks/                           # Enforcement hooks
    ├── hooks.json                  # Hook configuration
    ├── session-start.sh
    ├── pre-tool-use.sh
    └── post-tool-use.sh
```

## Best Practices

### During Planning
- Be thorough in requirement gathering - it's the foundation
- Don't skip architectural questions
- Consider edge cases and error scenarios
- Think about testing requirements upfront

### During Replanning
- Use the Replan option when requirements change mid-project
- Review all existing requirements before adding new ones
- Check for conflicts between old and new requirements
- All tasks will be regenerated - ensure work in progress is committed

### During Execution
- Review each task's changes before approving
- Don't modify task files manually unless fixing issues
- Let the auto-commit feature handle git operations
- For large projects, execute tasks one at a time to manage context

### Task Management
- Keep tasks focused and single-purpose
- Ensure dependencies are properly ordered
- Include validation criteria for each task
- Always include test coverage requirements

## Troubleshooting

### Common Issues

#### Hook Failures
- Verify `jq` and `yq` are installed: `which jq yq`
- Check hook permissions: `ls -la rgw/hooks/*.sh`
- Ensure `CLAUDE_PLUGIN_ROOT` environment variable is set

#### Task Status Issues
- Only one task should have `status: in progress`
- Follow valid progression: `to do` → `in progress` → `under review` → `done`
- Edit task YAML directly if manual fix needed

#### Context Overflow
- Execute tasks individually rather than all at once
- Break large tasks into smaller subtasks
- Use `/rgw:plan` to regenerate tasks if needed

## Workflow Benefits

1. **Prevents Scope Creep** - Structured requirement gathering keeps focus
2. **Ensures Completeness** - Comprehensive questioning catches edge cases
3. **Maintains Quality** - Enforced standards and testing requirements
4. **Provides Traceability** - Auto-commits create clear history
5. **Reduces Context Switching** - Focused, isolated tasks
6. **Improves Predictability** - Consistent process across projects
7. **Facilitates Review** - Clear task boundaries and validation

## Tips for Success

- **Interrupt and Resume**: You can stop at any phase and continue later
- **Review Requirements**: Always review `requirements.yaml` before task generation
- **Single Task Focus**: Complete one task fully before starting another
- **Commit Messages**: Follow repository conventions captured during planning
- **Test Coverage**: Ensure each task includes test implementation steps

## Summary

The RGW plugin transforms development from reactive coding to proactive planning. By enforcing a structured workflow, it ensures:

- Requirements are thoroughly understood before coding
- Implementation follows established patterns and standards
- Changes are tracked, tested, and properly committed
- Development progress is visible and predictable

This disciplined approach reduces bugs, improves code quality, and creates a clear audit trail of development decisions and implementations.