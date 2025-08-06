---
allowed-tools: [Read, Grep, Glob, Bash, TodoWrite]
description: "Analyze code quality, security, performance, and architecture"
---

# /by-ai:code-review - Code Review


## Purpose
Execute comprehensive code analysis across quality, security, performance, and architecture domains.

## Usage
```
/by-ai:code-review [branch] [--focus quality|security|performance|architecture] [--depth quick|deep]
```

## Arguments
- `branch` - Target branch to compare against current branch (defaults to 'master')
- `--focus` - Analysis focus area (quality, security, performance, architecture)
- `--depth` - Analysis depth (quick, deep)
- `--format` - Output format (text, json, report)

## Execution
1. Discover and categorize files for analysis based on the diff between the current branch and the target branch:
    - Use `git diff {branch_argument}...$(git branch --show-current)` where `{branch_argument}` is the first argument (defaults to 'master' if not provided)
2. Apply appropriate analysis tools and techniques:
    - **Quality**: Code style, complexity, maintainability, technical debt assessment, SOLID principles compliance, error handling patterns
    - **Security**: Vulnerability scanning, dependency checks, threat modeling, authentication/authorization flaws, data exposure risks, input validation
    - **Performance**: Profiling, bottleneck identification, resource usage analysis, scalability assessment, Core Web Vitals (frontend), memory management (leaks, dangling pointers, buffer overflows)
    - **Architecture**: Design patterns, modularity, scalability, coupling analysis, separation of concerns, future-proofing evaluation
    - **Testing**: Test quality, edge case handling, test pyramid compliance (DO NOT run tests, just analyze test
    - **Maintainability**: Code readability, documentation quality, code comments, naming conventions, modularity
      coverage and quality)
    - Based on an initial quick analysis, add additional checks if necessary
3. Generate findings with severity ratings
4. Create actionable recommendations with priorities, only if issues are found
    - Severity levels:
        - High: Critical issues that must be addressed immediately
        - Medium: Important issues that should be resolved soon
        - Low: Minor issues that can be addressed later
    - List should be sorted by severity
    - Include file project root relative filepaths and line numbers for each issue
    - Focus on changes and the effects of those changes, not the entire file
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

### Example Output
```
  | Category       | Assessment | Notes                                                 |
  |----------------|------------|-------------------------------------------------------|
  | Quality ✓      | Good       | Clean JWT implementation following best practices     |
  | Security ⚠️    | Poor       | Critical JWT verification vulnerability present       |
  | Performance ✓  | Good       | Efficient key caching and library migration           |
  | Architecture ✓ | Good       | Well-structured auth system with feature flag support |

  Improvements Needed

  | File                                        | Issue                                    | Severity | Recommendation                                                      |
  |---------------------------------------------|------------------------------------------|----------|---------------------------------------------------------------------|
  | ./src/util/jwt-token.ts:26                  | Incorrect key selection for verification | High     | Use publicKey instead of checking privateKey for token verification |
  | ./src/middlewares/auth-middleware.ts:68     | Hardcoded httpOnly setting               | Medium   | Use consistent auth v2 flag check like in login route               |
  | ./src/app/portal/api/user/login/route.ts:82 | Age verification expiry inconsistency    | Low      | Consider using consistent expiry calculation method                 |
```

DO NOT include any other text, explanations, or comments outside the markdown table.

## Claude Code Integration
- Uses Glob for systematic file discovery
- Leverages Grep for pattern-based analysis
- Applies Read for deep code inspection
- Maintains structured analysis reporting
