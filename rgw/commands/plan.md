Based on user defined requirements gather questions to clarify.

## Variables
WORKFLOW_TASK_GENERATION: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/task-generation.md`
WORKFLOW_GATHERING: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/requirement-gathering.md`
WORKFLOW_REPLAN: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/workflow/replan.md`

## Workflow

### Phase 1: Prerequisites Check
- Tell the user in a clearly visible way, that you understand and are following this workflow.
- Check if `requirements.yaml` exists in the project root using a simple bash command, do not read it's content yet.
- If `requirements.yaml` EXISTS:
  - Use the AskUserQuestion tool to present these options:
    - **Option 1: Fresh Plan** - Create a new plan from scratch (will delete existing requirements.yaml and all task-*.yaml files)
    - **Option 2: Replan** - Update existing requirements by reviewing and adding new aspects (will regenerate all task files based on updated requirements)
  - Based on user's choice:
    - If **Fresh Plan**: Delete `requirements.yaml` and all `task-*.yaml` files, then proceed with normal planning
    - If **Replan**: Follow the REPLAN workflow as defined in <WORKFLOW_REPLAN>
- If `requirements.yaml` DOES NOT EXIST:
  - Proceed with normal planning workflow

### Phase 2: Planning Process
- Wait for the User to ask a question or give you an instruction!
- If this is a FRESH PLAN or NO EXISTING requirements:
  - Start by gathering requirements, as defined in <WORKFLOW_GATHERING>
  - Request approval from user on the requirements gathered
  - If user approves, update `requirements.yaml` (in project root) to represent the latest requirement-gathering state
- If this is a REPLAN:
  - Follow the replan workflow as defined in <WORKFLOW_REPLAN>
  - Iterate through existing requirements and gather additional/modified requirements
  - When replanning is complete, delete ALL existing `task-*.yaml` files
  - Update `requirements.yaml` with the enhanced requirements

### Phase 3: Task Generation
- Create a list of tasks, as defined in <WORKFLOW_TASK_GENERATION>
- After the task list is generated, your work is done. DO NOT start working on the tasks!