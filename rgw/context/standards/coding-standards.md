# Core Principles

## Project-First Adaptation
  - ALWAYS analyze existing codebase patterns before writing new code
  - Match existing naming conventions, file structure, and architectural patterns
  - Maintain consistency with established coding style (indentation, formatting, etc.)
  - Respect existing dependency management and tooling choices

## Naming & Structure
  - Use clear, descriptive names for variables, functions, and classes
  - Follow language-specific naming conventions (camelCase, snake_case, etc.)
  - Organize code logically with appropriate separation of concerns
  - Keep functions small and focused on single responsibilities

## Error Handling
  - Implement proper error handling with specific, actionable error messages
  - Use appropriate error handling patterns for the language/framework
  - Never suppress errors silently
  - Validate inputs and handle edge cases

## Documentation
  - Write self-documenting code with clear variable and function names
  - Add comments only when code intent isn't obvious
  - Include JSDoc/docstrings for public APIs and complex functions
  - Update existing documentation when modifying functionality

## Programming Principles & Best Practices
  - apply the following principles:
    - SOLID
    - DRY
    - YAGNI
    - KISS
    - Composition over Inheritance
  - Write tests before implementation when appropriate
  - Validate inputs and assume external systems may fail
  - Separate different aspects of functionality into distinct sections

## Security
  - Validate and sanitize all inputs
  - Use parameterized queries for database operations
  - Implement proper authentication/authorization checks
  - Follow OWASP guidelines for web applications

## Performance
  - Avoid unnecessary loops and complex operations
  - Use appropriate data structures for the task
  - Implement caching where beneficial
  - Consider memory usage for large data operations

## Testing
  - Write unit tests for new functions/classes
  - Test edge cases and error conditions
  - Mock external dependencies properly
  - Maintain test coverage for critical paths
  - Avoid using literal values in test, always generate random values that suit the case

## Reliability
  - Handle async operations properly
  - Implement retry logic for network calls
  - Use proper logging for debugging and monitoring
  - Ensure graceful degradation for non-critical features

# Implementation Guidelines

## Before Writing Code
  - Analyze existing codebase structure and patterns
  - Identify similar implementations to follow as templates
  - Understand the project's architectural decisions
  - Check for existing utilities/helpers to reuse

## During Implementation
  - Start with the simplest working solution
  - Refactor for clarity and maintainability
  - Add proper error handling and validation
  - Write tests as you implement features

## After Implementation
  - Review code for consistency with project standards
  - Ensure all error paths are handled
  - Verify tests pass and provide good coverage
  - Check for potential security vulnerabilities

## Code Comments
  - When commenting, explain "why" instead of "what"
  - Document complex business logic and algorithms
  - Note any workarounds or temporary solutions
  - Reference tickets/issues for context when relevant

## Dependencies & Libraries
  - Prefer existing project dependencies over adding new ones
  - Use well-maintained, popular libraries when adding dependencies
  - Keep dependencies up to date for security
  - Avoid introducing breaking changes to existing APIs

# Code Review

Before considering code complete, verify:
  - Follows existing project patterns and conventions
  - Includes proper error handling
  - Maintains backward compatibility where required
  - Uses clear, descriptive naming
  - Handles edge cases appropriately
  - Follows security best practices
  - Has appropriate tests (if testing framework exists)
  - Is properly documented
