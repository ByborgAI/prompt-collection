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

0. **Prerequisites**:

   - Request Byborg Enterprises Anthropic access if you don't have it yet
   - Install [Claude Code](https://docs.anthropic.com/en/docs/claude-code/setup) (create API key [here](https://console.anthropic.com/settings/keys))

1. **Setup ByborgAI Prompt Collection**:

   - Add as submodule to your project's `.claude` directory:

     ```bash
     git submodule add git@github.com:ByborgCopilot/byborgai-prompt-collection.git .claude
     ```

     OR add it to your home directory for global access:

     ```bash
     git clone git@github.com:ByborgCopilot/byborgai-prompt-collection.git ~/.claude
     ```

   - Init `CLAUDE.md` in your repository:

     ```bash
     claude "/init"
     ```

   - Reference ByborgAI Prompt Collection `CLAUDE.md` in projects `CLAUDE.md` understand the core principles and rules:

     For Submodule installation:

     ```bash
     echo '\n@.claude/CLAUDE.md' >> CLAUDE.md
     ```

     For Global installation:

     ```bash
     echo '\n@~/.claude/CLAUDE.md' >> CLAUDE.md
     ```

2. **Playwright MCP Setup** for browser interactions and testing: install by running the following commands in your terminal (you can leave out `--scope project` if you want to install it globally):

   ```bash
   # Add Playwright MCP to your project mcp config
   claude mcp add playwright npx @playwright/mcp@latest --scope project
   # Connect Playwright MCP
   claude "/mcp"
   ```

   Add `.playwright-mcp` to your `.gitignore` file to avoid committing the Playwright MCP testing screenshots and videos.

3. **GitHub Integration** (Optional): Follow [GITHUB.md](GITHUB.md) for Claude's native GitHub app setup

4. **Atlassian MCP Setup** (Optional): integrate with Atlassian products like Jira and Confluence by running the following commands in your terminal (you can leave out `--scope project` if you want to install it globally):

   ```bash
   # Add Atlassian MCP to your project mcp config
   claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse --scope project
   # Connect Atlassian MCP
   claude "/mcp"
   ```

   This will allow you to use the Atlassian MCP for tasks like reading Jira issues or Confluence pages. Example usage:

   ```bash
   claude "Fix the issue described here: [link-to-jira-issue]"
   ```

   You can also ask Claude to create, update, comment, or bulk edit Jira issues or Confluence pages using the Atlassian MCP.

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
- **[manual-test.md](commands/by-ai/manual-test.md)**: Manual testing of commit changes in production with Playwright MCP using chrome

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

## Pre-commit Hook Installation

This repository includes an automated pre-commit hook that runs code reviews before commits:

1. **Install the pre-commit hook**:

   ```bash
   ./scripts/install-pre-commit-hook.sh
   ```

2. **What it does**:
   - Automatically runs `/by-ai:code-review` on staged changes before each commit
   - Works with both regular repositories and submodule installations
   - Prompts for confirmation after showing review results
   - Can be bypassed with `git commit --no-verify` if needed
