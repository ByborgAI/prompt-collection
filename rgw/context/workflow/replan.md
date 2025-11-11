# Replanning Workflow

This workflow is used when updating an existing requirements.yaml file with additional or modified requirements.

## Variables
SYNTAX_REQUIREMENTS: `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/syntaxes/requirements-syntax.md`

## Workflow

### Phase 1: Review Existing Requirements
1. Load and analyze the existing `requirements.yaml` file
2. Display a summary of the current requirements to the user:
   - Original request/goal
   - Current requirement categories and their status
   - Existing constraints and success criteria

### Phase 2: Identify Areas for Enhancement
1. Ask the user what aspects they want to modify or expand:
   - Add new requirements in existing categories
   - Add entirely new requirement categories
   - Modify existing requirements
   - Update constraints or success criteria
   - Change the overall goal or scope

### Phase 3: Iterative Requirement Updates
1. For each area the user wants to enhance:
   a. If MODIFYING existing requirements:
      - Show the current requirement
      - Ask for specific changes
      - Update the requirement while preserving context

   b. If ADDING new requirements:
      - Follow the standard requirement gathering process for new items
      - Ensure new requirements align with existing ones
      - Check for conflicts or dependencies with existing requirements

   c. If EXPANDING categories:
      - Add new question categories as needed
      - Maintain consistency with existing requirement structure

2. For each modification or addition:
   - Number all options for easy answering
   - Include context from existing requirements when relevant
   - Suggest answers based on existing patterns and decisions
   - Update the YAML immediately with changes

### Phase 4: Consistency Check
1. After gathering all updates, review the entire requirements set for:
   - Conflicts between old and new requirements
   - Dependencies that may have changed
   - Completeness of the enhanced specification
   - Alignment with the updated goal

2. If conflicts or gaps are found:
   - Present them to the user for resolution
   - Update requirements based on user decisions

### Phase 5: Finalize Replanning
1. Present a summary of all changes made:
   - New requirements added
   - Requirements modified
   - Requirements removed (if any)
   - Updated constraints or success criteria

2. Request user approval for the updated requirements

3. Upon approval:
   - Save the updated `requirements.yaml`
   - Mark all existing requirements as `complete: true`
   - Prepare for task regeneration

### Important Notes
- Preserve all existing requirements unless explicitly modified
- Maintain the structure defined in <SYNTAX_REQUIREMENTS>
- Ensure backward compatibility where possible
- Document the reason for significant changes in requirement details
- Keep track of what changed to inform task regeneration