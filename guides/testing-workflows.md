# Testing Workflows

Claude Code can write tests, run them, fix failures, and help you maintain a healthy test suite. This guide covers strategies for test-driven development, generating test coverage, and keeping tests reliable.

## Writing Tests with Claude

The simplest approach — ask Claude to write tests for existing code:

```bash
claude "Write unit tests for src/utils/validation.ts. Cover edge cases like empty strings, special characters, and very long input."
```

Claude reads the source file, understands the function signatures and logic, then generates tests that cover normal paths, edge cases, and error conditions.

### Be Specific About What to Test

Vague requests produce vague tests. Tell Claude exactly what concerns you:

```bash
# Good: specific coverage goals
claude "Write tests for the checkout flow. Make sure to test: applying discount codes, out-of-stock items, and partial refunds."

# Less effective: open-ended
claude "Write tests for the checkout"
```

## Test-Driven Development (TDD)

Claude works well in a TDD workflow where you write the test first, then implement the feature:

### Step 1: Write the Test

```bash
claude "Write a failing test for a new function called calculateShipping that takes a cart weight in kg and a destination country code, and returns the shipping cost in cents. US orders under 5kg ship for 500 cents, over 5kg for 1200 cents. International is 2500 cents flat."
```

### Step 2: Implement to Pass

```bash
claude "Now implement calculateShipping to make the tests pass."
```

### Step 3: Refactor

```bash
claude "Refactor calculateShipping for clarity. Make sure all tests still pass."
```

This loop keeps Claude focused and produces well-tested code from the start.

## Running Tests

Ask Claude to run your test suite directly:

```bash
claude "Run the tests and fix any failures"
```

Claude executes your test command (detected from `package.json`, `pytest.ini`, `Makefile`, or your CLAUDE.md), reads the output, and fixes failing tests or the underlying code.

### Specify the Test Runner

If Claude picks the wrong test command, be explicit:

```bash
claude "Run tests with: npm run test:unit -- --reporter verbose"
```

Or add it to your CLAUDE.md:

```markdown
## Testing
- Unit tests: `npm run test:unit`
- Integration tests: `npm run test:integration`
- Run all: `npm test`
```

## Generating Test Coverage

Ask Claude to fill gaps in your test suite:

```bash
claude "Check which functions in src/services/ have no test coverage and write tests for them"
```

Or target a coverage report:

```bash
claude "Run the coverage report and write tests to bring src/utils/ above 80% coverage"
```

## Testing Patterns

### Testing API Endpoints

```bash
claude "Write integration tests for the POST /api/users endpoint. Test successful creation, duplicate email handling, missing required fields, and invalid email format."
```

### Testing with Mocks

```bash
claude "Write tests for the EmailService class. Mock the SMTP client so tests don't send real emails. Verify the correct template is used for each email type."
```

### Snapshot and Approval Tests

```bash
claude "Add snapshot tests for the Dashboard component. If snapshots already exist, update them to reflect the current output."
```

### Testing Error Handling

```bash
claude "Write tests that verify our API returns proper error responses: 400 for bad input, 401 for missing auth, 403 for wrong permissions, 404 for missing resources."
```

## Fixing Flaky Tests

Flaky tests are a great use case for Claude:

```bash
claude "This test fails intermittently: test/integration/websocket.test.ts. Investigate why and fix the flakiness."
```

Common causes Claude can identify and fix:
- Race conditions and missing `await` calls
- Hardcoded ports or timestamps
- Test order dependencies
- Uncleared state between tests

## Maintaining Test Quality

### Review Generated Tests

Always review tests Claude generates. Watch for:

- **Tests that just mirror the implementation** instead of testing behavior
- **Missing edge cases** that you know about from domain knowledge
- **Overly brittle assertions** that break on irrelevant changes

### Keep Tests Focused

```bash
claude "This test file has grown to 500 lines. Split it into logical groups and make sure each test file covers one concern."
```

### Update Tests When Code Changes

```bash
claude "I refactored the auth module. Update the existing tests to match the new API while preserving the same coverage."
```

## CI Integration

Add test runs to your Claude Code workflow with hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "if echo \"$CLAUDE_COMMAND\" | grep -q 'git commit'; then npm test; fi",
        "description": "Run tests before committing"
      }
    ]
  }
}
```

Or use headless mode in CI pipelines:

```bash
cat failing-test-output.log | claude -p "Analyze this test failure and suggest a fix"
```

## See Also

- [Debugging](debugging.md) -- Debugging workflows that pair well with testing
- [Workflow Patterns](workflow-patterns.md) -- General development workflows
- [CI and Automation](ci-and-automation.md) -- Running tests in CI with Claude
- [Hooks](hooks.md) -- Automating test runs with hooks
