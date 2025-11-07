# RGW - Requirement Gathering Workflow

A structured workflow plugin for Claude Code that systematically gathers requirements, generates tasks, and executes them with automated tracking.

## Prerequisites

Install required dependencies:
```bash
# macOS
brew install jq yq git

# Ubuntu/Debian
sudo apt-get install jq yq git

# Other systems - install via package manager:
# - jq: JSON processor
# - yq: YAML processor
# - git: Version control
```

## Installation

Install the plugin via Claude Code:
```bash
/plugin marketplace add ByborgAI/prompt-collection
/plugin install rgw@prompt-collection
```

## Commands

### `/rgw:plan [description]`
**Capability:** Interactive requirement gathering and task generation
- Asks clarifying questions about your project
- Creates `requirements.yaml` with structured specifications
- Generates `task-*.yaml` files for systematic execution
- Supports replanning to update existing requirements

**Usage:**
```bash
/rgw:plan create a React dashboard with user authentication
```

### `/rgw:execute [task-file]`
**Capability:** Systematic task execution with automated commits
- Executes all tasks sequentially (no argument)
- Executes specific task (with task file argument)
- Tracks file changes automatically
- Auto-commits on task completion
- Enforces review before marking tasks done

**Usage:**
```bash
/rgw:execute              # Execute all tasks
/rgw:execute task-001.yaml  # Execute specific task
```

## Workflow

1. **Plan** → Creates requirements and tasks
2. **Execute** → Implements tasks with tracking
3. **Review** → User approves changes
4. **Commit** → Auto-commits on completion

## Task Status Flow
`to do` → `in progress` → `under review` → `done`

## Features
- ✅ Structured requirement gathering
- ✅ Automatic task breakdown
- ✅ Status tracking and enforcement
- ✅ File change tracking
- ✅ Automated git commits
- ✅ Single task at a time enforcement
- ✅ Replan capability for requirement updates

## Files Created
- `requirements.yaml` - Project requirements
- `task-*.yaml` - Individual task files
- Modified code files tracked in tasks

## Tips
- Add to `.gitignore`: `task-*.yaml` and `requirements.yaml`
- Review changes before approving tasks
- Use single task execution for large projects
- Tasks auto-commit with proper messages

## Quick Start
```bash
# 1. Install dependencies
brew install jq yq

# 2. Install plugin
/plugin install rgw@prompt-collection

# 3. Plan your project
/rgw:plan build a todo app

# 4. Execute tasks
/rgw:execute
```