---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite, Bash(git add .), Bash(scripts/find-ticket-from-branch.sh)
argument-hint: "[--breaking] [--type <type>] [--ticket <ticket>]"
description: "This command suggests a commit message for current changes without executing the commit and copies the commit command to clipboard"
---

# /aitt:commit-suggest - Suggests a commit message for current changes

## Purpose

This command suggests a well-formatted commit message with conventional commit messages based on the current changes in the repository.

## Usage

```bash
/aitt:commit-suggest
```

Force breaking change structure with:

```bash
/aitt:commit-suggest --breaking
```

Force commit type with:

```bash
/aitt:commit-suggest --type <type>
```

Where `<type>` is one of: feat, fix, docs, style, refactor, perf, test, chore

Force ticket ID with:

```bash
/aitt:commit-suggest --ticket <ticket>
```

## What This Command Does

1. Runs `.claude/scripts/find-ticket-from-branch.sh` script to extract a related ticket ID from the current branch name and include it in the commit message if found
   - If a `--ticket <ticket>` argument is provided, it MUST use that ticket ID instead of extracting from branch name
   - If no ticket ID is found you MUST prompt the user and wait to provide one before proceeding any steps further
2. Checks staged files with `git status`
   - If no files are staged, automatically adds all modified/new files with `git add .`
3. Analyzes the changes with `git diff --cached` to understand what is being committed. Quickly identify:
   - File types modified (components, tests, docs, config, etc.)
   - Nature of changes (new features, bug fixes, refactoring, etc.)
   - Scope of impact (single feature, multiple areas, etc.)
4. Suggests a conventional commit message that accurately reflects the changes being committed `[<JIRA ticket reference>] <type>: <description>`

   - Types: feat, fix, docs, style, refactor, perf, test, chore
   - Use present tense, imperative mood
   - Keep first line under 72 characters
   - Be specific but concise
   - Use multiple lines if necessary
   - Single-line example: `[PROJ-123] fix: resolve memory leak in rendering process`
   - Multi-line example:

     ```text
     [PROJ-123] feat: add user authentication module

     - Implement login and registration endpoints
     - Add JWT-based authentication
     - Update user model with password hashing
     ```

5. Outputs the suggested git commit command with the message: `git commit -m "<suggested message>"`
6. Copies the suggested git commit command to clipboard with `pbcopy`

## Important Notes

- Do NOT execute the commit, only suggest the commit message and copy the commit command to clipboard
- You MUST follow conventional commit standards when suggesting the commit message
- You MUST suggest a commit message that accurately reflects the changes being committed
- Prioritize speed - make quick, accurate assessments
- Follow conventional commit standards strictly
- Be decisive in commit type classification
- Ensure commit message accurately reflects the actual changes
- Handle edge cases gracefully (no changes, merge conflicts, etc.)
