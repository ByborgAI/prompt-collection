---
allowed-tools: Read, Grep, Glob, Bash
description: "This command quickly summarizes current changes using git diff"
---

# /by-ai:summarize-changes - Summarizes current changes using git diff

## Purpose

This command analyzes the current changes in the git repository using `git diff HEAD` and provides a concise and short summary of the modifications, additions, and deletions. It helps developers quickly understand the scope and impact of their changes before committing.

## Usage

```bash
/by-ai:summarize-changes
```

For a shorter summary, use:

```bash
/by-ai:summarize-changes --short
```

## What This Command Does

1. Analyzes the changes with `git diff HEAD` to understand what is being changed. Quickly identify:
   - File types modified (components, tests, docs, config, etc.)
   - Nature of changes (new features, bug fixes, refactoring, breaking changes etc.)
   - Scope of impact (single feature, multiple areas, etc.)
2. Outputs a structured summary of the changes in a commit message style:
   - The first line MUST be a title of the overall changes.
   - If `--short` is not specified, use bullet points to organize the changes in a list format under the title and an empty line (max 5 bullet points).
   - Maximum line length is 72 characters for each line in the summary.
   - Use present tense, imperative mood.
   - Be specific but concise.
   - Prioritize speed - make quick, accurate assessments

## Important Notes

- Do NOT output any explanation on what you are doing, just the final summary.
- Do NOT ask any further questions, just provide the summary based on the changes.
- ONLY output the final summary, do NOT include any explanations, questions, next steps or additional text as the output will be used directly as a commit message.

Example Changes Summary Output:

```text
Add user authentication module

- Implement login and registration endpoints
- Add JWT-based authentication
- Update user model with password hashing
```

Example Short Changes Summary Output: "Add user authentication module with login, registration and JWT-based auth"
