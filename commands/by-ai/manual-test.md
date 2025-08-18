---
allowed-tools:
  [Read, Grep, Glob, Bash, TodoWrite, playwright, WebFetch, WebSearch]
description: "Analyzes merged commit changes from input and manual tests the related features on production with Playwright MCP"
---

# /by-ai:manual-test - Manual test change in production

## Purpose

This command allows you to manually test changes in production by reading merged commit changes and testing the related features on production using Playwright MCP.

## Usage

```
/by-ai:manual-test [production_url] [commit_hash]
```

## What This Command Does

1. Reads and Analyzes the changes to identify the features that need to be tested based on the provided **$commit_hash** changes.
   - Uses the `git diff` command to get the changes made in the specified commit only.
   - Identifies the files and functionalities that have been modified or added.
   - Constructs a list of features that need to be tested based on the commit changes.
   - Constructs a manual test plan based on the identified features. You MUST output the test plan in a structured format for the user to review before proceeding, ALWAYS ask for confirmation or modifications to proceed with the manual testing.
2. Opens the specified **$production_url** and follows the test plan created in the first step.
   - DO NOT write any code or scripts, this is a manual testing process.
   - Accept cookies and privacy policies if needed.
   - If in doubt or the application requires authentication (login), ask the user for clarification on how to proceed with the testing otherwise DO NOT wait for user to interact with the browser.
3. Outputs the results of the manual tests, including any issues, bugs, ux concerns found or confirmations of successful tests in a structured format.
   - If any issues were found, provide detailed information about the issue, including steps to reproduce, expected vs actual behavior.
   - If all tests pass, confirm that the features are functioning as expected.
