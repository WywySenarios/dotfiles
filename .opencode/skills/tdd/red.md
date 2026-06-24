# Stage 1: Red — Write the failing test

## Before writing

1. Identify the **seam** — where in the call chain can the test exercise the real change?
2. Find the **existing test file** or the right place to add one. Mirror the production module structure.
3. Decide the **test scope**: unit (fastest), integration (service boundary), or e2e (external contract).

## Write the test

- Name it to describe the expected behaviour: `test_<what>_<when>_<then>`.
- Use existing test fixtures, factories, and helpers. Do not invent new machinery yet.
- The test must exercise the **exact code path** the production code will use.
- Assert on the **specific outcome**, not on implementation details.

## Resolve imports — create stubs, not no-ops

Make sure the test does **not** fail because of a missing import or unresolved module.
If the test imports a function, component, or module that does not exist yet, create a
**stub** — a skeleton that resolves the import but fails with a clear signal, not a
silent no-op.

1. Create a **stub file** at the expected import path.
2. The stub MUST export the name the test imports, and its body **must raise
   `NotImplementedError`** with a descriptive message. This makes the import resolve
   while telling both the test runner and the Green phase exactly what is missing.
3. If the stub requires a third-party package that is not yet installed, add it to
   `package.json` and run the package manager's install command before proceeding.
4. Kill any other environment blockers (missing `window.matchMedia`, missing globals,
   etc.) via setup files or mocks so the test fails on *behaviour*, not environment.

### Examples

| Test imports | Doesn't exist | Action |
|---|---|---|
| `import { cn } from "../../lib/utils"` | `src/lib/utils.ts` | Create `src/lib/utils.ts` with `export function cn(...args: any[]) { throw new NotImplementedError("cn") }` |
| `import { Button } from "./button"` | Button lacks `asChild` | Existing file, but stub already resolves — no action |
| `import { ThemeProvider } from "next-themes"` | Package not installed | Add to `package.json`, run `npm install` |
| `window.matchMedia` unavailable | jsdom environment | Add mock to `tests/unit/setup.ts` |

### Why

- A test that fails with `Module not found` or `window.matchMedia is not a function`
  tells you nothing about the feature.
- A test that fails because `expect(theme).toBe("dark")` returned `undefined` tells you
  exactly what behaviour is missing.
- **`NotImplementedError` is better than a no-op** because:
  - The test fails loudly, not silently — no risk of a false positive.
  - The stack trace pinpoints exactly which function still needs implementation.
  - The Green phase receives a clear checklist of what to implement: every function that
    throws `NotImplementedError`.

## Run the test — confirm it fails for the right reason

```bash
/etc/Wywy-Website-Control/run.sh <service> test
```

- The failure must match the **missing feature or bug**. A wrong failure = wrong test. Fix the test.
- If the test passes without new code, the feature already exists or the test is not testing the right thing. Investigate.

---

### STOP. Report findings to user with [template](./template.md). Wait for approval.

