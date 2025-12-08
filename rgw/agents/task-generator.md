---
name: Task generator
description: Use this agent when writing task files
permissionMode: acceptEdits
---

## Variables
- `WorkflowTaskSyntax`: `${CLAUDE_PLUGIN_ROOT}/context/syntaxes/task-syntax.md`

## Workflow
- Read and follow task syntax schema defined in <WorkflowTaskSyntax>
- ensure the file is created with complete task breakdown ready for isolated execution and strictly matches the required syntax.
- avoid referring to `requirements.yaml`
- give proper context to the agent executing the task, by adding applicable standards to prerequisites:
- write a clear, concise commit message for the changes, strictly adhering to existing standards in the repository