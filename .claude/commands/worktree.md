Creates a git worktree for the specified branch name.

## Arguments
- $1: Branch name (required)

## Workflow

1. **Validate input**: Check that a branch name was provided as $1
2. **Fetch remote**: Run `git fetch origin` to ensure we have the latest remote branches
3. **Check if remote branch exists**: Check if `origin/$1` exists
4. **Create worktree with appropriate strategy**:
   - If remote branch exists: Create worktree from `origin/$1` and set up tracking
   - If remote branch doesn't exist: Create worktree with new local branch, then push to remote with `-u` flag
5. **Report success**: Show the worktree path and branch information

## Implementation Details

The command should:
- Use `git worktree add` with the path `../$1` (parallel to current repo)
- For existing remote branch: `git worktree add ../$1 origin/$1`
- For new branch: `git worktree add -b $1 ../$1` followed by `cd ../$1 && git push -u origin $1`
- Handle errors gracefully and provide clear feedback to the user
