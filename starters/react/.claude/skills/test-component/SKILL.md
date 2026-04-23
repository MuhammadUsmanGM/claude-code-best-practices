---
name: test-component
description: Write React Testing Library tests for an existing component, following the project's RTL conventions (prefer role/label queries, mock at network boundary, no act()). Invoke when the user asks to test, add tests for, or cover a component.
allowed-tools: Read, Write, Glob, Grep
---

# Test Component

Write tests for an existing component following the project's conventions.

## Steps

1. **Read the component file.** Note its props, any hooks it calls, and
   whether it fetches data.
2. **Read one existing test file in the same area** and mirror its style —
   imports, render helpers, matcher choices, mock setup.
3. **Plan 3–5 assertions**, in this priority order:
   - Renders the expected role/label on mount.
   - Responds to user interaction (click, type) with a visible result.
   - Handles loading / empty / error states if the component has them.
   - Calls the right callback with the right args (if props include callbacks).
4. **Mock at the network boundary.** If the component fetches via a shared
   client in `src/api/`, add an MSW handler in `src/test/msw/` — don't mock
   the component's internal hooks.
5. Write the test file next to the component. Name: `<Name>.test.tsx`.
6. Run `npm test -- <Name>` once and report pass/fail. Do not fix the
   component to make the test pass — if a test reveals a bug, stop and tell
   the user.

## Query priority (enforced)

Use in this order, only falling back when the higher option genuinely doesn't
apply:

1. `getByRole` with an accessible name
2. `getByLabelText`
3. `getByPlaceholderText`
4. `getByText`
5. `getByTestId` — last resort

## Rules

- Never call `act()` manually. If a test "needs" it, you're testing
  implementation — rewrite the assertion.
- Never `await new Promise(...)` to wait for state. Use `findBy*` or
  `waitFor`.
- No snapshot tests unless the component has a stable, small render surface
  (icons, formatted strings). Component snapshots rot fast.
- Don't edit the component under test. This skill writes tests only.
