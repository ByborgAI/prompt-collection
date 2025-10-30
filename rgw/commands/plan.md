Gather requirements from the user and generate requirements.yaml for approval.

- tell the user in a clearly visible way, that you understand and are following this workflow.
- wait for the User to ask a question and give you an instruction!
- if `requirements.yaml` exists in project root and is relevant to the task, skip this part.
    - start by gathering requirements, as defined in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/requirement-gathering.md`. 
- otherwise
  - request approval from user on the requirements gathered
  - if user approves, update `requirements.yaml` (in project root) to represent the latest requirement-gathering state
- after requirements.yaml is generated and approved, your work is done. DO NOT create tasks or start working on implementation!