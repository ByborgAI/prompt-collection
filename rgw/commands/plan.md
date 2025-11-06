Based on user defined requirements gather questions to clarify.

## Variables
WORKFLOW_TASK_GENERATION: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/task-generation.md`
WORKFLOW_GATHERING: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/requirement-gathering.md`

## Workflow
- tell the user in a clearly visible way, that you understand and are following this workflow.
- wait for the User to ask a question and give you an instruction!
- if `requirements.yaml` exists in project root and is relevant to the task, skip this part.
    - start by gathering requirements, as defined in <WORKFLOW_GATHERING>.
- otherwise
  - request approval from user on the requirements gathered
  - if user approves, update `requirements.yaml` (in project root) to represent the latest requirement-gathering state
- create a list of tasks, as defined in <WORKFLOW_TASK_GENERATION>
- after the task list is generated, your work is done. DO NOT start working on the tasks!