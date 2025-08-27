## Usage

```bash
/by-ai:e2e-test:write
```

Or, to focus on a specific section of the test plan:

```bash
/by-ai:e2e-test:write [test_plan_section]
```

## Execution

1. Read the @test_plan.md in the project root directory and create e2e playwright test scenarios based on unmarked items and prompted plan sections `[test_plan_section]` with e2e-test-writer subagent.
2. After finishing creating the tests, update the @test_plan.md file by marking the completed items with a checkmark.
