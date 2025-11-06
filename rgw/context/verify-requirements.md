# Verifying requirements gathering output

## Variables
WORKFLOW_GATHERING: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/requirement-gathering.md`

## Response format

```yaml
passed: boolean
remarks:
  - string
```

the output MUST BE EXACTLY in this format!

DO NOT provide comments, feedback or response other than the yaml. AVOID talking about your task or the steps required.

the output must be plain text in YAML format. do not use markdown framing.

## Workflow
- read the `requirements.yaml` file 
- verify if `goal` covers `original_request`
- verify if the items in `requirements` cover all technical aspects of `original_request`. it must fulfill the following criteria:
  - must be technically thorough, explicit
  - there must not be any ambiguity
  - must fulfill the "Output Quality Check" section of <WORKFLOW_GATHERING> 
