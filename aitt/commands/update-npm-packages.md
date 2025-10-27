---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite, Bash(npx), Bash(npm), Bash(git add .), Bash(git status), Bash(git commit), AskUserQuestion, WebSearch, WebFetch
argument-hint: '[--target <patch|minor|major>] [--package <name>] [--safe] [--skip <pkg1,pkg2,...>]'
description: 'Continuously updates NPM packages one at a time, verifies each update, and commits them until no more updates are available or user stops the process.'
---

# /update-npm-packages — Continuously update NPM packages one by one

## Purpose

Automate your "one-package-at-a-time" update flow with minimal risk. **Continuously** selects and applies eligible updates (preferring PATCH, then MINOR, optionally MAJOR), records changelog summaries, runs basic checks, and commits each update automatically. The process continues until no more updates are available or the user interrupts it.

## Usage

/update-npm-packages
/update-npm-packages --target patch
/update-npm-packages --target minor
/update-npm-packages --target major
/update-npm-packages --package <name>
/update-npm-packages --safe
/update-npm-packages --skip react,eslint,chalk
/update-npm-packages --audit-level high
/update-npm-packages --safe --audit-level critical

## Flags

--target <patch|minor|major> Specify update level: PATCH (default), MINOR, or MAJOR. Default behavior: patch→minor fallback (no major unless explicitly specified)
--package <name> Update ONLY this specific package and exit (no loop, no other packages)
--safe Enable interactive mode - pause before each update for user approval after showing changelog research
--skip <pkg1,pkg2,...> Comma-separated list of package names to skip (e.g., "react,eslint,chalk"). Packages in this list will be excluded from updates
--audit-level <low|moderate|high|critical> Set the audit severity threshold for blocking updates (default: moderate). Updates introducing vulnerabilities at or above this level will require user approval

## What This Command Does

**This command runs in a LOOP until no more updates are available or the user stops it.**

### Initial Setup (Once per run)

1. **Check git working directory**
   - Run `git status --porcelain` to check for uncommitted changes
   - **If working directory is NOT clean** (has uncommitted changes):
     - Display the current status to the user
     - Use `AskUserQuestion` to ask: "Your working directory has uncommitted changes. Would you like to: (1) stash changes and continue, (2) commit changes first, or (3) abort?"
     - Responses:
       - `stash` or `1` - Run `git stash push -m "Auto-stash before package updates"` and continue
       - `commit` or `2` - Stop and ask user to commit manually first
       - `abort` or `3` - Exit the command immediately
   - **If working directory is clean**: Proceed to next step

2. **Confirm auto-update mode (only if --safe flag is NOT present)**
   - **If `--safe` flag is NOT present**: Use `AskUserQuestion` tool to confirm automatic updates
   - Question: "This will automatically update packages without manual approval. Continue?"
   - Options: `["yes", "no"]`
   - Responses:
     - `yes` - Proceed with automatic updates
     - `no` - Exit the command immediately
   - **If `--safe` flag is present**: Skip this confirmation (user will approve each update individually)

3. **Determine ticket**
   - Try `.claude/scripts/find-ticket-from-branch.sh` to get ticket ID from branch

### For Each Package (Repeats automatically)

4. **Select ONE eligible update (STEP 1)**
   - **If `--package` is provided**: Use ONLY that specific package, ignore skip list, ignore target preference
     - After processing this package, **exit immediately** (do not continue loop)
     - If the package is not available for update, report this and exit
   - **Otherwise** (no `--package` flag):
     - **Apply skip list**: If `--skip` flag is provided, use that comma-separated list (e.g., `react,eslint,chalk`). Use `npx ncu --reject` with the skip list to exclude these packages
     - **If no `--skip` flag is provided**: No packages are skipped (no default skip list)
     - **If `--target major` is specified**: Run `npx ncu -t major` (with `--reject` if skip list exists). If none found, **exit loop**: "All updates completed"
     - **If `--target minor` is specified**: Run `npx ncu -t minor` (with `--reject` if skip list exists). If none found, **exit loop**: "All updates completed"
     - **If `--target patch` is specified or no target**: Run `npx ncu -t patch` (with `--reject` if skip list exists). If none found, run `npx ncu -t minor`. If none, **exit loop**: "All updates completed"
     - Choose exactly ONE package per iteration

5. **Quick research (STEP 2, ≤2 minutes)**
   - Look up the package changelog on npm/GitHub
   - **Always display** a short summary of key changes to the user (breaking changes, new features, bug fixes)
   - **Always append** the summary to `package-updates-changelog.md` at repo root (create if missing)
   - If info is hard to find within ~2 minutes, write/display a brief general note and proceed

6. **User approval (STEP 2a, only with --safe flag)**

- **If `--safe` flag is present**: Display the research findings to the user
- Show: package name, current version, target version, and changelog summary
- Use `AskUserQuestion` tool to ask: "Proceed with this update? (yes/no/skip-all)"
- Responses:
  - `yes` - Continue with this update
  - `no` - Skip this package and move to next one
  - `skip-all` - Stop the loop entirely
- **If `--safe` flag is NOT present**: Skip this step and proceed automatically

7. **Apply the update (STEP 3)**
   - **Always run**: `npm install <pkg>@<targetVersion>` (e.g., `npm install inquirer@12.6.3`)
   - No dry-run mode - this command actually applies updates

8. **Verify basics + Security audit (STEP 4)**
   - **Security audit check**:
     - Run `npm audit --audit-level=moderate --json` to check for vulnerabilities
     - Parse the JSON output to count vulnerabilities by severity (critical, high, moderate, low)
     - **If new critical or high vulnerabilities are introduced** (compare with pre-update baseline if available):
       - Display the vulnerability details to the user (package name, severity, description)
       - Use `AskUserQuestion` to ask: "This update introduces critical/high security vulnerabilities. Would you like to: (1) revert this update, (2) continue anyway, (3) try npm audit fix, or (4) view detailed audit report?"
       - Responses:
         - `revert` or `1` - Revert the update (`git reset --hard HEAD~1 && npm install`) and stop the loop
         - `continue` or `2` - Proceed with the update despite vulnerabilities (log warning in changelog)
         - `fix` or `3` - Run `npm audit fix` and re-verify, then ask for confirmation again if issues remain
         - `report` or `4` - Run `npm audit` (human-readable format) and display full report, then ask again
     - **If moderate or low vulnerabilities**: Log them in the changelog but continue (non-blocking)
   - Unless `--no-verify`, run:
     - `npm install && npx tsc --noEmit` (always, if TypeScript is present)
     - Conditionally run: `npm run storybook` / `npm run eslint` / `npm run test` / `npm run build` (only if relevant scripts exist in package.json)
   - **If verification scripts are not available or fail to run**: Use `AskUserQuestion` to ask the user:
     - "Verification script(s) not available or failed. Would you like to: (1) skip verification and continue, (2) suggest alternative verification steps, or (3) stop the update process?"
   - On errors: attempt quick fixes or **revert** (`git reset --hard HEAD~1 && npm install`) and stop the loop

9. **Commit the update (STEP 5)**
   - Stage: `git add package.json package-lock.json`
   - **Auto-commit** with conventional format:
     `<TICKET> chore: update <package> from <oldVersion> to <newVersion>`
   - Keep first line ≤72 chars; imperative mood; accurate, concise

10. **Continue to next package**
   - **If `--package` was specified**: Exit immediately after committing (single package mode)
   - **Otherwise**: Automatically return to STEP 1 and process the next package
   - Loop continues until no more updates or user interrupts

## Important Notes

- **Continuous operation**: Processes ALL available updates automatically, one package at a time (unless `--package` is specified)
- **Single package mode**: Use `--package <name>` to update only one specific package and exit immediately
- **Prefer PATCH over MINOR**: Default behavior checks patch updates first; only moves to minor if no patches available (unless specific `--target` is used)
- **MAJOR version updates**: Use `--target major` to explicitly enable MAJOR version updates. By default, MAJOR updates are NOT processed due to potential breaking changes
- **Custom skip list**: Use `--skip pkg1,pkg2,pkg3` to exclude specific packages from updates. No default skip list (unless `--package` is used - then skip list is ignored)
- **Security audit**: Each update is automatically checked for security vulnerabilities using `npm audit`. Critical/high vulnerabilities require user approval before proceeding
- **Audit level control**: Use `--audit-level <low|moderate|high|critical>` to set the severity threshold for blocking updates (default: moderate)
- **Auto-commit each update**: Every successful update gets its own commit immediately
- **Follow conventional commits**: Format is `TICKET chore: update <package> from <old> to <new>`
- **Stop on errors**: If verification fails, revert the update and stop the loop (don't continue to next package)
- **User can interrupt**: Press Ctrl+C or stop the command at any time to halt the process
- **Automatic changelog tracking**: All update summaries are automatically written to `package-updates-changelog.md`, including any security vulnerability notes
- **Safe mode**: Use `--safe` flag for interactive approval before each update - ideal for teams that want manual review
