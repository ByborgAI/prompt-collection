# Claude's Native GitHub App Setup Instructions

https://docs.anthropic.com/en/docs/claude-code/github-actions

## Quick setup

### Install GitHub CLI and authenticate:

```bash
# Install GitHub CLI
brew install gh
# Authenticate with GitHub
gh auth login
```

### Run claude CLI and install the GitHub app:

```bash
claude "/install-github-app"
```

1. Install the GitHub app on your repository.
2. Follow the instructions to authenticate and authorize the app.
3. Select code review startegy (run with `@claude` command or automatically on PRs).
4. Open and merge the pull request created by the app - on this PR the workflow will fail, but after merging the PR, the workflow will be enabled for new PRs.

## Tips

### Performance

To optimizing performance create a `CLAUDE.md` file in your repository root. Make sure to define **code style guidelines, review criteria, project-specific rules, and preferred patterns**. You can initialize it claude CLI:

```bash
claude "/init"
```

### Usage

Mention `@claude` in PRs, issues, or comments to trigger Claude for **analyze your code, create pull requests, implement features, and fix bugs**. Ask for implementation suggestions, bug fixes, or code quality improvements.

Examples:

```markdown
@claude Please review this PR and suggest improvements.
@claude Can you help me refactor this function for better performance?
@claude Implement this feature based on the issue description.
@claude Fix the TypeError in the user dashboard component.
```
