# Schema

```yaml
original_request: string
goal: string
complete: boolean
requirements:
  - category: architecture|dependencies|data|security|interface|implementation
    question: string
    answer: string? # optional
    details: [string]      # technical implications
    options: [string]
    status: pending|answered
constraints:
  - type: technical|business|security
    description: string
    impact: string
success_criteria: [string]
```

## Field Descriptions

- `original_request`: The original input from the User, without any changes
- `goal`: A high level description of what the goal is based on the user prompt
- `complete`: Indicates that the requirement gathering has been fully completed or not.
- `requirements`: array of questions and answers with their current status
  - `question`: The requirement question text
  - `answer`: Response to the question (optional, only present when status is "answered")
  - `details`: Technical implications and additional context
  - `options`: Available choices for the question
  - `category`: Question domain - "architecture", "dependencies", "data", "security", "interface", "implementation"
  - `status`: Current state - "pending" or "answered"
- `constraints`: Technical, business, or security limitations that affect implementation
  - `type`: Constraint category - "technical", "business", "security"
  - `description`: Clear description of the constraint
  - `impact`: How this constraint affects the implementation
- `success_criteria`: Simple array of success criteria descriptions that define project success

# Usage Guidelines

- Keep descriptions concise and clear
- Use arrays for lists to maintain order
- Mark individual requirement statuses as "pending" or "answered"
- Answered requirements must contain enough detail for future reference
- Focus on essentials, avoid feature creep