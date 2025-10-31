# Task generation

Convert the requirements into actionable, sequenced tasks that can be executed individually.

## Steps
- Read and analyze the `requirements.yaml` (in project root) file thoroughly
- Follow task syntax schema defined in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/syntaxes/task-syntax.md` .
- Identify phases and their prerequisites
- Identify component dependencies, map sequence diagrams to implementation order
- Start by checking if affected files have test coverage
- Check the commit messages in the repository and identify existing conventions
  - if the commit messages contain JIRA ticket numbers (ABCDEF-12345), infer the ticket number from the branch name
- Create tasks for all major phases: setup, integration, implementation, final validation
  - each task that introduces code changes must contain steps to update or create test cases
- Generate `task-XXX.yaml` files for each individual task (XXX being an incremental counter). 
  - ensure the file is created with complete task breakdown ready for isolated execution and strictly matches the required syntax.
  - avoid referring to `requirements.yaml`
  - give proper context to the agent executing the task, by adding applicable standards to prerequisites:
    - all coding tasks must require `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/standards/coding-standards.md`  to be read and strictly followed (be explicit about this)
  - write a clear, concise commit message for the changes, strictly adhering to existing standards in the repository

## Success criteria
- Task sequence respects dependencies and technical constraints
- Each task is immediately, individually executable without additional clarification or context
- Each task is specific, actionable, and technically detailed
- Each task contains steps to run tests against the changes
  
