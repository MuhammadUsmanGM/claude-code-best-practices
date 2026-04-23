---
name: component-new
description: Scaffold a new React component with matching test file and consistent folder layout, following the project's conventions in src/features or src/components. Invoke when the user asks to create, scaffold, or add a new component.
allowed-tools: Read, Write, Glob, Grep
---

# Component New

Scaffold a new component. Ask once for name and placement if ambiguous; then
create the files without further prompting.

## Steps

1. **Pick a location.**
   - If the component is reusable and presentational → `src/components/<Name>/`.
   - If it belongs to a feature → `src/features/<feature>/components/<Name>/`.
   - If the project has neither folder, ask the user before creating new
     top-level structure.
2. **Read a sibling component** in the target folder to match its style
   (props pattern, default vs. named export, test shape, hooks placement).
   If no sibling exists, use the shape below.
3. **Create three files:**
   - `<Name>.tsx` — the component
   - `<Name>.test.tsx` — a failing-first test with one `toBeInTheDocument`
     assertion
   - `index.ts` — `export * from './<Name>';` (only if the folder contains one)
4. **Do not** add it to a barrel file in `src/` unless one already exists.
5. Report the paths created. Stop.

## Default shape (if no sibling to mirror)

```tsx
// src/components/<Name>/<Name>.tsx
import type { ReactNode } from 'react';

export interface <Name>Props {
  children?: ReactNode;
}

export function <Name>({ children }: <Name>Props) {
  return <div>{children}</div>;
}
```

```tsx
// src/components/<Name>/<Name>.test.tsx
import { render, screen } from '@testing-library/react';
import { <Name> } from './<Name>';

describe('<Name>', () => {
  it('renders children', () => {
    render(<<Name>>hello</<Name>>);
    expect(screen.getByText('hello')).toBeInTheDocument();
  });
});
```

## Rules

- Never default-export. Named export only (per project convention).
- No `any`. Use `unknown` or define the type.
- Don't add third-party dependencies.
- Don't wire the component into any routes or parent components — that's a
  follow-up prompt.
