# Task execution

IMPORTANT: tasks files must have an up-to date status field. always make sure that they are updates as task execution progresses!

## VARIABLES
SYNTAX_TASK: `${CLAUDE_PLUGIN_ROOT}/context/syntaxes/task-syntax.md`

## Workflow
- Read and strictly follow task syntax schema defined in <SYNTAX_TASK>
- Read and make sure all prerequsites are met
- Update the task file status to indicate progress, review and completed states
- If an under review task was found, ask the user to approve the changes before proceeding
- Execute each step in sequence, one by one
- After each step, validate your work by checking it against the step's acceptance criteria
- After all steps are completed, always stop and wait for user approval before marking the task as done. The changes MUST FULFILL requirements described in the `validation` array.
  - IF the `validation` requirements are not fulfilled, undo the changes and start over
  - IF the `validation` requirements are fulfilled:
    - Ask the User to review the changes, and wait for their acceptance
    - NEVER mark the task as "done" until the User EXPLICITLY accepts the changes!
    - Only after the user explicitly approved the changes mark the task file as "done".
    - When the task is marked as "done", a preToolUse hook will try to commit the changes.
      In case it fails, you must fix the errors, but DO NOT commit the changes yourself!
- IMPORTANT: After a task file is marked as "done", STOP and ask for user approval before proceeding to the next task file (if executing multiple tasks).

