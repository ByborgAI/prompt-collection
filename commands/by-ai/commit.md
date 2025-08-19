---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite
description: "Creator commit message for current changes"
---

# /by-ai:commit - Creator commit message for current changes

## Purpose

This command helps you create well-formatted commits with conventional commit messages.

## Usage

```bash
/by-ai:commit
```

Or with options:

```bash
/by-ai:commit --no-verify
```

## What This Command Does

1. Unless specified with `--no-verify`, automatically runs pre-commit checks
2. Checks which files are staged with `git status`
3. If 0 files are staged, automatically adds all modified and new files with `git add`
4. Performs a `git diff` to understand what changes are being committed
