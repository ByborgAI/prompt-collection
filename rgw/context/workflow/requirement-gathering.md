# Requirement gathering

Read and follow communication standards described in `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/standards/communication-standards.md` 

Collaboratively discover comprehensive requirements with the User through efficient, iterative analysis.

IMPORTANT: output of this step is the sole input for task generation. IT MUST BE comprehensive and technically precise. 

## Workflow

1. Search repository for existing patterns, similar implementations, and architectural decisions
2. Think hard to determine complexity, approach (integration/implementation), and affected files
3. Collect a set of questions and put them in `requirements.yaml` (in project root) file based on `~/.claude/plugins/marketplaces/prompt-collection/rgw/context/syntaxes/requirements-syntax.md` 
4. Prioritize questions in this order:
   a. Architecture & Approach: Core technical decisions
   b. Dependencies & Integration: External systems, libraries, APIs, interfaces, types
   c. Data & State Management: Storage, persistence, state handling
   d. Security & Performance: Authentication, authorization, scalability requirements, handling sensitive data
   e. Interface & UX: User interactions, API contracts
   f. Implementation Details: Specific technical approaches
5. Iterate over the all of these questions ONE BY ONE with the User:
   a. Review existing answers for gaps and dependencies
   b. Focus on architectural/foundational decisions before implementation details
   c. ASK the User specific, relevant, concise questions ONE AT A TIME: 
      - number all options for easy answering
      - include technical context when relevant
      - suggest an answer based on the patterns and conventions identified
   d. Immediately update YAML with answer and refine the remaining questions. Add new questions if necessary!
   e. THINK HARD to determine if sufficient clarity exists for technical specification
6. After all questions has been discussed, verify if the output allows:
   - Unambiguous implementation approach
   - Complete dependency identification
   - Measurable success criteria
   - Risk/constraint awareness
   - Creation of clear, explicit technical tasks to achieve all aspects of the goal set by the User
   If any of these criteria are not met, go back to '2.'