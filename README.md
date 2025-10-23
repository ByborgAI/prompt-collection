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
