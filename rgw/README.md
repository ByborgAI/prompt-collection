# Requirement Gathering Workflow (RGW) Plugin

A structured workflow plugin for Claude Code that helps gather requirements, generate tasks, and execute them systematically.

## Overview

This plugin provides a comprehensive workflow for software development projects:

1. **Requirement Gathering**: Interactive process to capture all project requirements
2. **Task Generation**: Automatic breakdown of requirements into actionable tasks
3. **Task Execution**: Systematic execution with status tracking and automated commits

## Installation

### Prerequisites

- Claude Code installed
- `jq` - JSON processor (install via `brew install jq` on macOS)
- `yq` - YAML processor (install via `brew install yq` on macOS)
- Git repository initialized in your project

### Install the Plugin

1. Install the plugin via Claude Code CLI:
   ```bash
   claude plugins install path/to/rgw
   ```

   Or via Claude Code by referencing the plugin directory.

2. (Optional) Add file permissions to your project's `.claude/settings.json` if you want to restrict access:
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

3. Add the following to your `.gitignore`:
   ```
   task-*.yaml
   requirements.yaml
   ```

The plugin's hooks will automatically activate when the plugin is enabled.

## Usage

### Planning Phase

Start the planning phase by invoking:
```
/rgw:plan
```

Claude will:
1. Ask what you want to accomplish
2. Gather all requirements interactively
3. Generate a `requirements.yaml` file for review
4. Once approved, generate `task-*.yaml` files for each step

**Important**: If Claude tries to continue to execution automatically, stop it. The planning phase should end after task generation.

You can resume planning at any time by invoking `/rgw:plan` again.

### Execution Phase

Execute tasks in two ways:

1. **Sequential execution** (all tasks):
   ```
   /rgw:execute
   ```

2. **Single task execution**:
   ```
   /rgw:execute task-001.yaml
   ```

During execution, Claude will:
- Set task status to "in progress"
- Make necessary code changes
- Track all modified files
- Request review before marking complete
- Automatically commit changes when task is marked "done"

### Task Status Workflow

Tasks follow this status progression:
- `to do` → `in progress` → `under review` → `done`

The workflow enforces:
- Only one task can be "in progress" at a time
- No code modifications when no task is "in progress"
- Automatic git commits when tasks are completed

## Plugin Structure

```
rgw/
├── .claude-plugin/
│   └── plugin.json                # Plugin manifest
├── commands/                      # Slash commands
│   ├── plan.md                   # /rgw:plan command
│   └── execute.md                # /rgw:execute command
├── ~/.claude/plugins/marketplaces/prompt-collection/rgw/context/                       # Workflow documentation & standards
│   ├── workflow/
│   │   ├── requirement-gathering.md
│   │   ├── task-generation.md
│   │   └── task-execution.md
│   ├── syntaxes/
│   │   ├── requirements-syntax.md
│   │   └── task-syntax.md
│   ├── standards/
│   │   ├── coding-standards.md
│   │   ├── typescript-standards.md
│   │   ├── javascript-standards.md
│   │   └── communication-standards.md
│   ├── verify-requirements.md
│   └── verify-task.md
└── hooks/                         # Workflow enforcement hooks
    ├── hooks.json                # Hook configuration
    ├── pre-tool-use.sh           # Validates task status transitions
    └── post-tool-use.sh          # Tracks changes and auto-commits
```

## Hooks

The plugin includes two hooks that enforce the workflow:

### pre-tool-use.sh
- Prevents code modifications when no task is "in progress"
- Validates task status transitions
- Prepares for auto-commit when task is marked "done"

### post-tool-use.sh
- Tracks all file changes in the active task
- Verifies requirements.yaml when complete
- Validates task structure
- Runs linting (eslint for JS, yq for YAML)

## Tips

- **Context Management**: For large projects, use single task execution to avoid context overflow
- **Review Changes**: Always review Claude's changes before approving task completion
- **Resume Anytime**: You can interrupt and resume at any phase
- **Task Dependencies**: Plan tasks in dependency order during the planning phase

## Troubleshooting

### Hook Errors

If hooks fail, check:
- `jq` and `yq` are installed
- Hook scripts have execute permissions (should be set automatically)
- The `CLAUDE_PLUGIN_ROOT` environment variable is available to the hooks

### Task Status Issues

If you need to manually fix task status:
- Edit the task YAML file directly
- Ensure status follows the valid progression
- Only one task should have "status: in progress" at a time

## License

Part of the Byborg AI toolkit for development automation.
