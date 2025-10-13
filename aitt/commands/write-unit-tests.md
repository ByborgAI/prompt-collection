---
allowed-tools: Read, Grep, Glob, Bash, TodoWrite
description: "Write unit and integration tests for new or existing code"
---

# /aitt:write-unit-tests - Write unit and integration tests

## Purpose

Generate unit and integration tests for newly added code or specified existing file to ensure functionality and reliability.

## Usage

For newly added code:

```bash
/aitt:write-unit-tests
```

Or for exisiting file:

```bash
/aitt:write-unit-tests [file_to_test]
```

## Execution

1. **Test Framework Detection**

   - Identify the testing framework in use (Jest, Vitest, Mocha, PyTest, RSpec, etc.)
   - Review existing test structure and conventions
   - Check test configuration files and setup
   - Understand project-specific testing patterns

2. **Code Analysis for Testing**

   - If `[file_to_test]` is provided, analyze the specified file for testing.
   - If `[file_to_test]` is NOT provided, identify the newly added code by comparing the current branch with the development branch
     - Checks which files are staged with `git status`
     - If 0 files are staged, automatically adds all modified and new files with `git add`
     - Use `git diff` to analyze changes, compare to master/main or branch name given from arguments: **$ARGUMENTS**
   - Analyze the code that needs testing, ONLY create tests for newly added code or `[file_to_test]` if provided.
   - Identify public interfaces and critical business logic
   - Map out dependencies and external interactions
   - Understand error conditions and edge cases

3. **Test Strategy Planning**

   - Determine test levels needed:
     - Unit tests for individual functions/methods
     - Integration tests for component interactions
   - Plan test coverage goals and priorities
   - Identify mock and stub requirements

4. **Unit Test Implementation**

   - Test individual functions and methods in isolation
   - Cover happy path scenarios first
   - Test edge cases and boundary conditions
   - Test error conditions and exception handling
   - Use proper assertions and expectations

5. **Test Structure and Organization**

   - Follow the AAA pattern (Arrange, Act, Assert)
   - Use descriptive test names that explain the scenario
   - Group related tests using test suites/describe blocks
   - Keep tests focused and atomic

6. **Mocking and Stubbing**

   - Mock external dependencies and services
   - Stub complex operations for unit tests
   - Use proper isolation for reliable tests
   - Avoid over-mocking that makes tests brittle

7. **Data Setup and Teardown**

   - Create test fixtures and sample data
   - Set up and tear down test environments cleanly
   - Use factories or builders for complex test data
   - Ensure tests don't interfere with each other

8. **Integration Test Writing**

   - Test component interactions and data flow
   - Test API endpoints with various scenarios
   - Test database operations and transactions
   - Test external service integrations

9. **Error and Exception Testing**

   - Test all error conditions and exception paths
   - Verify proper error messages and codes
   - Test error recovery and fallback mechanisms
   - Test validation and security scenarios

10. **Security Testing**

    - Test authentication and authorization
    - Test input validation and sanitization
    - Test for common security vulnerabilities
    - Test access control and permissions

11. **Test Utilities and Helpers**
    - Create reusable test utilities and helpers
    - Build test data factories and builders
    - Create custom matchers and assertions
    - Set up common test setup and teardown functions

## Output and Important Notes

- The output is a set of unit and integration tests formatted for the appropriate testing framework.
- Include comments where necessary to explain complex logic or edge cases.
- Make sure every function or component has corresponding tests.
- DO NOT modify, update, or refactor any implementation (non-test) code under any circumstances.
- If a test is failing due to a mismatch with the implementation, update ONLY the test code to accurately reflect the current implementation, unless explicitly instructed otherwise.
- If you believe the implementation is incorrect, DO NOT change it; instead, leave a comment in the test file describing the suspected issue for human review.
- Run linter and formatter on the test files to ensure they adhere to the project's coding standards.
- After linter issue fixes rerun the tests to ensure they still pass, fix any issues that arise after the linter changes. DO NOT stop fixing until all tests pass.
