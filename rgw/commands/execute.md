Executes the previously created tasklist.

## Variables
WORKFLOW_TASK_EXECUTION: `${CLAUDE_PLUGIN_ROOT}/context/workflow/task-execution.md`

## Workflow
- follow the task execution workflow as described in <WORKFLOW_TASK_EXECUTION>
- tell the user in a clearly visible way, that you understand and are following this workflow, and list all the arguments received
- IF an argument was received, read $1 and execute strictly following the execution workflow
- IF no arguments were given, list all tasks (`task-XXX.yaml` files, relative to project root), and their statuses.
  - if there are no tasks found, stop here and suggest the User to plan first.
  - execute each task sequentially strictly following the execution workflow
