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

# Restart Claude Code to load the plugin
```

### Local Development

```bash
# Clone the repository
git clone https://github.com/ByborgAI/prompt-collection.git
cd prompt-collection

# Add as local marketplace
/plugin marketplace add .

# Install the plugin
/plugin install prompt-collection@prompt-collection
```

## Available Commands

### Code Quality & Review

#### `/prompt-collection:code-review [branch]`
Comprehensive code analysis across quality, security, performance, and architecture domains.

**Features:**
- Quality analysis (code style, complexity, maintainability)
- Security scanning (vulnerabilities, authentication flaws)
- Performance profiling (bottlenecks, resource usage)
- Architecture evaluation (design patterns, modularity)

**Usage:**
```bash
/prompt-collection:code-review
/prompt-collection:code-review main
```

### Git & Commit Management

#### `/prompt-collection:commit-suggest [--breaking] [--type <type>] [--ticket <ticket>]`
Suggests conventional commit messages based on current changes.

**Features:**
- Automatic ticket ID extraction from branch name
- Conventional commit format
- Copies command to clipboard

**Usage:**
```bash
/prompt-collection:commit-suggest
/prompt-collection:commit-suggest --type feat
/prompt-collection:commit-suggest --ticket PROJ-123
```

#### `/prompt-collection:summarize-changes [--short]`
Quick summary of current changes using git diff.

**Usage:**
```bash
/prompt-collection:summarize-changes
/prompt-collection:summarize-changes --short
```

### Testing

#### `/prompt-collection:write-unit-tests [file_to_test]`
Generate unit and integration tests for new or existing code.

**Features:**
- Automatic test framework detection
- Comprehensive test coverage
- Follows project conventions

**Usage:**
```bash
/prompt-collection:write-unit-tests
/prompt-collection:write-unit-tests src/utils/auth.ts
```

#### `/prompt-collection:manual-test [production_url] [commit_hash] [--no-verify]`
Manual testing of changes in production with Playwright MCP.

**Features:**
- Automated browser testing
- Chrome-based testing
- Test plan generation

**Usage:**
```bash
/prompt-collection:manual-test https://example.com abc123
/prompt-collection:manual-test https://example.com abc123 --no-verify
```

#### `/prompt-collection:e2e-test:plan`
Explore website and plan e2e test scenarios.

**Usage:**
```bash
/prompt-collection:e2e-test:plan https://example.com
```

#### `/prompt-collection:e2e-test:write [test_plan_section]`
Write e2e Playwright tests based on test plan.

**Usage:**
```bash
/prompt-collection:e2e-test:write
/prompt-collection:e2e-test:write "User Authentication"
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
