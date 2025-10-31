# Verifying task generation output

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
- verify if the task fulfills the following criteria
  - prerequisites mention explicitly to read and follow to at least one standards file
  - there is no reference to `requirements.yaml`
  - each task fulfills the "Success criteria" defined in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/task-generation.md`
- in case of validation failed, provide information in the output remarks section