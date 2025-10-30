# Prompt Collection

AI-driven development toolkit for Claude Code with commands and agents for testing, code review, and commit management.

## Installation

### Prerequisites

Before installing this plugin, you must be authenticated with GitHub in your environment where you run Claude Code.

**GitHub Authentication Required:**
- Ensure you have configured your GitHub credentials
- If you haven't set up an SSH key yet, follow GitHub's guide: [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- Test your SSH connection: `ssh -T git@github.com`

### Via Claude Code Plugin System

```bash
# Add the marketplace and install the plugin
/plugin marketplace add ByborgAI/prompt-collection
/plugin install aitt@prompt-collection

# Restart Claude Code to load the plugin
```

## Available Commands

### Code Quality & Review

#### `/aitt:code-review [branch]`
Comprehensive code analysis across quality, security, performance, and architecture domains.

**Features:**
- Quality analysis (code style, complexity, maintainability)
- Security scanning (vulnerabilities, authentication flaws)
- Performance profiling (bottlenecks, resource usage)
- Architecture evaluation (design patterns, modularity)

**Usage:**
```bash
/aitt:code-review
/aitt:code-review main
```

### Git & Commit Management

#### `/aitt:commit-suggest [--breaking] [--type <type>] [--ticket <ticket>]`
Suggests conventional commit messages based on current changes.

**Features:**
- Automatic ticket ID extraction from branch name
- Conventional commit format
- Copies command to clipboard

**Usage:**
```bash
/aitt:commit-suggest
/aitt:commit-suggest --type feat
/aitt:commit-suggest --ticket PROJ-123
```

#### `/aitt:summarize-changes [--short]`
Quick summary of current changes using git diff.

**Usage:**
```bash
/aitt:summarize-changes
/aitt:summarize-changes --short
```

#### `/aitt:update-npm-packages [--target <patch|minor|major>] [--package <name>] [--safe] [--skip <pkg1,pkg2,...>] [--audit-level <low|moderate|high|critical>]`
Continuously updates NPM packages one at a time, verifies each update, and commits them automatically.

**Features:**
- Automated one-package-at-a-time update workflow
- Changelog research and documentation
- Security audit checks with configurable thresholds
- Automatic verification (TypeScript, tests, build)
- Individual git commits per update
- Safe mode for manual approval

**Usage:**
```bash
/aitt:update-npm-packages
/aitt:update-npm-packages --target patch
/aitt:update-npm-packages --target minor
/aitt:update-npm-packages --package react
/aitt:update-npm-packages --safe
/aitt:update-npm-packages --skip react,eslint,chalk
/aitt:update-npm-packages --audit-level high
```

### Testing

#### `/aitt:write-unit-tests [file_to_test]`
Generate unit and integration tests for new or existing code.

**Features:**
- Automatic test framework detection
- Comprehensive test coverage
- Follows project conventions

**Usage:**
```bash
/aitt:write-unit-tests
/aitt:write-unit-tests src/utils/auth.ts
```

#### `/aitt:manual-test [production_url] [commit_hash] [--no-verify]`
Manual testing of changes in production with Playwright MCP.

**Features:**
- Automated browser testing
- Chrome-based testing
- Test plan generation

**Usage:**
```bash
/aitt:manual-test https://example.com abc123
/aitt:manual-test https://example.com abc123 --no-verify
```

#### `/aitt:e2e-test:plan`
Explore website and plan e2e test scenarios.

**Usage:**
```bash
/aitt:e2e-test:plan https://example.com
```

#### `/aitt:e2e-test:write [test_plan_section]`
Write e2e Playwright tests based on test plan.

**Usage:**
```bash
/aitt:e2e-test:write
/aitt:e2e-test:write "User Authentication"
```

### Requirement Gathering Workflow

The RGW plugin provides a structured three-phase workflow for software development projects. Use the commands in this sequence:

#### 1. `/rgw:plan` - Requirement Gathering
Interactive requirement gathering to capture project requirements and generate requirements.yaml.

**What it does:**
- Asks clarifying questions about your project
- Captures all functional and technical requirements
- Generates `requirements.yaml` file for your review and approval
- Stops after requirements are approved (does NOT create tasks)

**Usage:**
```bash
/rgw:plan
```

#### 2. `/rgw:task-creation` - Task Generation
Converts requirements.yaml into actionable task files without executing them.

**What it does:**
- Reads approved `requirements.yaml`
- Breaks down requirements into sequential tasks
- Creates `task-XXX.yaml` files in project root
- Plans task dependencies and execution order
- Stops after tasks are generated (does NOT execute)

**Usage:**
```bash
/rgw:task-creation
```

#### 3. `/rgw:execute [task_file]` - Task Execution
Execute generated tasks with status tracking and auto-commit.

**What it does:**
- Executes tasks one by one or all sequentially
- Updates task status (to do → in progress → under review → done)
- Tracks all file changes per task
- Requests user review before marking complete
- Auto-commits changes when task is marked "done"
- Enforces workflow rules via hooks

**Usage:**
```bash
# Execute all tasks sequentially
/rgw:execute

# Execute a specific task
/rgw:execute task-001.yaml
```

**Prerequisites:**
- `jq` - JSON processor (install via `brew install jq` on macOS)
- `yq` - YAML processor (install via `brew install yq` on macOS)

## Available Agents

The plugin includes specialized agents for complex workflows:

- **auto-committer** - Automated commit management
- **e2e-test-planner** - E2E test scenario planning
- **e2e-test-qa** - Website exploration and analysis
- **e2e-test-writer** - Playwright test implementation

## Requirements

- Claude Code CLI
- Git (for commit and review commands)
- Playwright MCP (for manual-test and e2e-test commands)

## Configuration

The plugin respects your project's existing configuration:

- Testing frameworks (Jest, Vitest, PyTest, etc.)
- Commit message conventions
- Code style and linting rules

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT

## Author

Byborg
