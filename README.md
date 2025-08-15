# ByborgAI Prompt Collection

A curated collection of prompts, commands, and agents for Claude Code to enhance software development workflows with AI assistance.

## Overview

This repository provides a structured framework for AI-driven development using Claude Code, featuring:

- **Specialized Agents**: Focused AI assistants for specific development tasks
- **Command Templates**: Reusable prompts for common development operations
- **Core Principles**: Development guidelines following SOLID principles and best practices
- **Automation Scripts**: Session initialization and workflow automation

## Quick Start

### Installation

1. **Clone or add as submodule** to your project's `.claude` directory:
   ```bash
   git submodule add https://github.com/ByborgCopilot/byborgai-prompt-collection .claude
   ```

2. **GitHub Integration** (Optional): Follow [GITHUB.md](GITHUB.md) for Claude's native GitHub app setup

### Core Framework Files

- **[CLAUDE.md](CLAUDE.md)**: Entry point referencing core rules and principles
- **[RULES.md](RULES.md)**: Actionable operational rules for task management and execution
- **[PRINCIPLES.md](PRINCIPLES.md)**: Core development philosophy and decision-making frameworks
- **[GITHUB.md](GITHUB.md)**: GitHub integration setup instructions

## Available Commands

Commands are located in the `commands/by-ai/` directory and provide structured prompts for common development tasks:

### Code Quality & Testing
- **[code-review.md](commands/by-ai/code-review.md)**: Comprehensive code review guidelines
- **[write-unit-tests.md](commands/by-ai/write-unit-tests.md)**: Unit test generation and best practices
- **[commit.md](commands/by-ai/commit.md)**: Automated commit message generation and validation

### E2E Testing Workflow
- **[e2e-test/plan.md](commands/by-ai/e2e-test/plan.md)**: End-to-end test planning strategies
- **[e2e-test/write.md](commands/by-ai/e2e-test/write.md)**: E2E test implementation guidelines

## Available Agents

Specialized agents in the `agents/` directory provide focused assistance for specific domains:

### Testing Specialists
- **[e2e-test-planner.md](agents/e2e-test-planner.md)**: Strategic E2E test planning and architecture
- **[e2e-test-writer.md](agents/e2e-test-writer.md)**: E2E test implementation and execution
- **[e2e-test-qa.md](agents/e2e-test-qa.md)**: Quality assurance and test validation

### Development Automation
- **[auto-committer.md](agents/auto-committer.md)**: Automated commit generation with conventional commit standards

## Configuration

### Settings
The repository includes Claude Code configuration files:
- `settings.json`: Primary configuration with hooks and permissions
- `settings.local.json`: Local overrides (git-ignored)

### Session Initialization
The `scripts/session-init.sh` automatically runs on session start to:
- Check for configuration updates
- Notify about available submodule updates
- Provide update instructions

## Key Features

### Development Philosophy
- **Evidence-Based**: All decisions backed by measurable data
- **Task-First Approach**: Structure before execution (understand → plan → execute → validate)
- **Parallel Thinking**: Maximize efficiency through intelligent batching
- **Quality Gates**: Multi-step validation for all operations

### Operational Excellence
- **Systematic Codebase Changes**: Mandatory project-wide discovery before modifications
- **Security-First**: Always validate inputs and use secure practices
- **Framework Compliance**: Respect existing project patterns and conventions
- **Context Retention**: Maintain ≥90% context retention across operations

## Usage Patterns

### Basic Command Usage
Use commands by referencing them in your prompts:
```bash
claude "@commands/by-ai/code-review.md"
```

### Agent Invocation
Spawn specialized agents for focused tasks:
```bash
claude "/spawn @agents/e2e-test-planner.md"
```

### GitHub Integration
With the GitHub app installed, mention `@claude` in PRs and issues:
```markdown
@claude Please review this PR using the code review guidelines
@claude Generate unit tests for the new authentication module
```

## Best Practices

1. **Read Before Writing**: Always use Read tool before Write/Edit operations
2. **Batch Operations**: Use parallel tool calls when possible
3. **Validate Continuously**: Run lint/typecheck before marking tasks complete
4. **Follow Framework Patterns**: Respect existing project conventions
5. **Complete Discovery**: Perform comprehensive searches before codebase changes

## Contributing

This collection follows the established patterns and principles outlined in the core framework files. When adding new commands or agents:

1. Follow the existing file structure and naming conventions
2. Adhere to the principles in [PRINCIPLES.md](PRINCIPLES.md)
3. Apply the operational rules from [RULES.md](RULES.md)
4. Test with real development scenarios

## Support

For issues or questions:
- Check the [troubleshooting section](https://docs.anthropic.com/en/docs/claude-code/troubleshooting) in Claude Code docs
- Review existing command and agent patterns for similar use cases
- Ensure proper setup of GitHub integration if using collaborative features

## License

This collection is designed to enhance development workflows with Claude Code and follows Anthropic's usage guidelines for AI-assisted development.