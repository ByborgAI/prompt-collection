Based on user defined requirements gather questions to clarify.

- tell the user in a clearly visible way, that you understand and are following this workflow.
- wait for the User to ask a question and give you an instruction!
- start by gathering requirements, as defined in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/requirement-gathering.md`. if `requirements.yaml` (in project root) exists in project root and is relevant to the task, skip this part.
- request approval from user on the requirements gathered
    - if user approves update `requirements.yaml` (in project root) to represent latest version of the requirement gathering state
- create a list of tasks, as defined in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/task-generation.md`.
- after the task list is generated, your work is done. DO NOT start working on the tasks!
