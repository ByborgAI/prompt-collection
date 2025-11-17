Based on user defined requirements gather questions to clarify.

## Variables

### Requirement Gathering Variables
- `WorkflowRequirementGathering`: `${CLAUDE_PLUGIN_ROOT}/context/workflow/requirement-gathering.md`
- `CommunicationStandards`: `${CLAUDE_PLUGIN_ROOT}/context/standards/communication-standards.md`
- `RequirementsSyntax`: `${CLAUDE_PLUGIN_ROOT}/context/syntaxes/requirements-syntax.md`

### Task Generation Variables
- `WorkflowTaskGeneration`: `${CLAUDE_PLUGIN_ROOT}/context/workflow/task-generation.md`
- `TaskSyntax`: `${CLAUDE_PLUGIN_ROOT}/context/syntaxes/task-syntax.md`
- `CodingStandards`: `${CLAUDE_PLUGIN_ROOT}/context/standards/coding-standards.md`

### Replan Variables
- `WorkflowReplan`: `${CLAUDE_PLUGIN_ROOT}/context/workflow/replan.md`

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
    - If **Replan**:
      - Follow the REPLAN workflow as defined in <WorkflowReplan>
- If `requirements.yaml` DOES NOT EXIST:
  - Proceed with normal planning workflow

### Phase 2: Planning Process
- Wait for the User to ask a question or give you an instruction!
- If this is a FRESH PLAN or NO EXISTING requirements:
  - Start by gathering requirements, as defined in <WorkflowRequirementGathering>
  - Once all requirements are gathered, present a summary to the user
  - **IMPORTANT**: Request explicit approval from user on the requirements gathered
  - If user approves, update `requirements.yaml` (in project root) to represent the latest requirement-gathering state
  - **STOP HERE** - Do NOT proceed to Phase 3 automatically
- If this is a REPLAN:
  - Follow the replan workflow as defined in <WorkflowReplan>
  - Iterate through existing requirements and gather additional/modified requirements
  - Once replanning is complete, present the updated requirements to the user
  - **IMPORTANT**: Request explicit approval from user on the updated requirements
  - If user approves, delete ALL existing `task-*.yaml` files and update `requirements.yaml` with the enhanced requirements
  - **STOP HERE** - Do NOT proceed to Phase 3 automatically

### Phase 3: Task Generation (User Approval Required)
- **IMPORTANT**: This phase requires explicit user permission. Ask: "Requirements gathering is complete. Would you like me to proceed with generating the task list?"
- Only proceed if the user explicitly approves task generation
- Create a list of tasks, as defined in <WorkflowTaskGeneration>
- After the task list is generated, your work is done. DO NOT start working on the tasks!