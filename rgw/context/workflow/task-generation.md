# Task generation

Convert the requirements into actionable, sequenced tasks that can be executed individually.

## VARIABLES
`SyntaxTask`: `${CLAUDE_PLUGIN_ROOT}/context/syntaxes/task-syntax.md`
`StandardsCoding`: `${CLAUDE_PLUGIN_ROOT}/context/standards/coding-standards.md`

## Steps
- **For REPLAN scenarios**: Delete all existing `task-*.yaml` files in the project root before generating new ones
- Read and analyze the `requirements.yaml` (in project root) file thoroughly
- Follow task syntax schema defined in <SyntaxTask>
- Identify phases and their prerequisites
- Identify component dependencies, map sequence diagrams to implementation order
- Start by checking if affected files have test coverage
- Check the commit messages in the repository and identify existing conventions
  - if the commit messages contain JIRA ticket numbers (ABCDEF-12345), infer the ticket number from the branch name
- Create tasks for all major phases: setup, integration, implementation, final validation
  - avoid fragmenting work into small tasks: a single file should be changed in a single tasks, unless absolutely necessary to split it up.
  - consider tasks like commits, each should make sense on it's own
  - each task that introduces code changes must contain steps to update or create test cases
- Generate `task-XXX.yaml` files for each individual task (XXX being an incremental counter). 
  - ensure the file is created with complete task breakdown ready for isolated execution and strictly matches the required syntax.
  - avoid referring to `requirements.yaml`
  - give proper context to the agent executing the task, by adding applicable standards to prerequisites:
  - write a clear, concise commit message for the changes, strictly adhering to existing standards in the repository

## Success criteria
- Task sequence respects dependencies and technical constraints
- Each task is immediately, individually executable without requiring additional clarification or context
- Each task is specific, actionable, and to the point. Avoid adding details that can be inferred from the codebase.
- Each task contains steps to run tests against the changes
- Each task must produce an output that does not break functionality and passes all tests.
