---
allowed-tools: [Read, Grep, Glob, Bash, TodoWrite]
description: "Analyze code quality, security, performance, and architecture"
---

# /by-ai:code-review - Code Review


## Purpose
Execute comprehensive code analysis across quality, security, performance, and architecture domains.

## Usage
```
/by-ai:code-review [target] [--focus quality|security|performance|architecture] [--depth quick|deep]
```

## Arguments
- `target` - Files, directories, or project to analyze
- `--focus` - Analysis focus area (quality, security, performance, architecture)
- `--depth` - Analysis depth (quick, deep)
- `--format` - Output format (text, json, report)

## Execution
1. Discover and categorize files for analysis based on the diff between the current branch and development:
    - Use `git diff development...$(git branch --show-current)`
2. Apply appropriate analysis tools and techniques:
    - **Quality**: Code style, complexity, maintainability
    - **Security**: Vulnerability scanning, dependency checks
    - **Performance**: Profiling, bottleneck identification
    - **Architecture**: Design patterns, modularity, scalability
3. Generate findings with severity ratings
4. Create actionable recommendations with priorities, only if issues are found
    - High: Critical issues that must be addressed immediately
    - Medium: Important issues that should be resolved soon
    - Low: Minor issues that can be addressed later
    - List should be sorted by severity
    - Include file project root relative filepaths and line numbers for each issue
5. Present ONLY a nicely formatted compact markdown table of text-based analysis report nothing else
    - If you have positive findings, just add a tick mark next to the section that you used as a point to review
    - Start with the positive findings and then list the improvements at the end
    - Only include list of improvements
    - Include:
      - File paths in a following format: `./path/to/file.js:line_number` (DO NOT include ranges just where the issue
        is)
      - Issues found
      - Severity
      - Recommendations

DO NOT include any other text, explanations, or comments outside the markdown table.

## Claude Code Integration
- Uses Glob for systematic file discovery
- Leverages Grep for pattern-based analysis
- Applies Read for deep code inspection
- Maintains structured analysis reporting
