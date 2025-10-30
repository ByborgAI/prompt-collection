Executes the previously created tasklist.

- follow the task execution workflow as described in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/task-execution.md`
- tell the user in a clearly visible way, that you understand and are following this workflow, and list all the arguments received
- IF an argument was received, read $1 and execute strictly following the execution workflow
- IF no arguments were given, list all tasks (`task-XXX.yaml` files, relative to project root), and their statuses.
  - if there are no tasks found, stop here and suggest the User to plan first.
  - execute ONE task at a time strictly following the execution workflow
  - IMPORTANT: After each task file is marked as "done", STOP and ask for user approval before proceeding to the next task file.
