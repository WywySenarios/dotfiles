# Digest — Shared Report Formats

This is the shared specification for the canonical report formats used across
all agents. It is referenced by AGENTS.md and every agent that reports results,
so that reports look the same regardless of which agent produced them. When any
agent reports the result of a phase, an edit, or a cycle, it reads this file and
uses these formats exactly.

## Canonical tables

### Files changed

```md
**Files changed:**

| File     | Change                                |
| -------- | ------------------------------------- |
| `<path>` | `<line>` — (one-sentence description) |
```

### Test results

```md
**Test results:**

| Result  | Count |
| ------- | ----- |
| Passed  | N     |
| Failed  | N     |
| Skipped | N     |
```

## Phase report — RED / GREEN / REFACTOR

Used when a TDD phase completes. The header names the phase. `Next` states what follows after user approval.

```md
## <PHASE> — done

**Files changed:**

| File     | Change                                |
| -------- | ------------------------------------- |
| `<path>` | `<line>` — (one-sentence description) |

**Test results:**

| Result  | Count |
| ------- | ----- |
| Passed  | N     |
| Failed  | N     |
| Skipped | N     |

**Notes:** <what was done and why>
**Next:** <next phase or action>
```

Phase-specific Notes/Next text — use the matching variant for the phase you completed:

| Phase    | Notes                                                           | Next                                             |
| -------- | --------------------------------------------------------------- | ------------------------------------------------ |
| RED      | What the test demands. Why it fails for the right reason.       | Green phase (green agent writes implementation). |
| GREEN    | What production code was written and why it satisfies the test. | Refactor phase.                                  |
| REFACTOR | What was cleaned up and why. No behaviour changed.              | (user approval or next cycle)                    |

## Cycle report — CYCLE — <PHASE> done (one plan item)

Used when a single plan item finishes a phase, so the user can trace which item the report refers to. The header is `## CYCLE — <PHASE> done` where `<PHASE>` is RED, GREEN, or REFACTOR.

```md
## CYCLE — <PHASE> done

**Plan item:** `<item text>`

**Files changed:**

| File     | Change                                |
| -------- | ------------------------------------- |
| `<path>` | `<line>` — (one-sentence description) |

**Test results:**

| Result  | Count |
| ------- | ----- |
| Passed  | N     |
| Failed  | N     |
| Skipped | N     |

**Notes:** <what was done and why>
**Next item** (after approval): <next phase or action>
```

Phase-specific Notes/Next item text — use the matching variant for the phase you completed:

| Phase    | Notes                                                     | Next item (after approval) |
| -------- | --------------------------------------------------------- | -------------------------- |
| RED      | What the test demands. Why it fails for the right reason. | Green phase.               |
| GREEN    | What production code was written.                         | Refactor phase.            |
| REFACTOR | What was cleaned up and why. No behaviour changed.        | Next plan item.            |

## Cycle report — plan complete

Used when the last plan item has finished all phases. When the cycle agent ran adversary validation at exhaustion, append the **Adversary validation** block below the total test results. Omit the block when validation could not run.

```md
## CYCLE — plan complete

**Plan exhausted.** All items completed:

| #   | Item     | Red | Green | Refactor | Ephemeral    |
| --- | -------- | --- | ----- | -------- | ------------ |
| 1   | `<item>` | ✅  | ✅    | ✅       | ❌           |
| 2   | `<item>` | ✅  | ✅    | ✅       | ✅ (cleaned) |

**Total test results (final suite):**

| Result  | Count |
| ------- | ----- |
| Passed  | N     |
| Failed  | N     |
| Skipped | N     |

**Adversary validation:**

| Verdict | Score  | Report                                          |
| ------- | ------ | ----------------------------------------------- |
| Revise  | 6.5/10 | `~/plans/adversary/<plan-name>-<YYYY-MM-DD>.md` |
```

The adversary's full report is relayed alongside this digest using the conversational format from the `adversary-report` template.

## Test edit report

Used when a test edit request completes.

```md
## TEST EDIT — done

**Files changed:**

| File     | Change                                |
| -------- | ------------------------------------- |
| `<path>` | `<line>` — (one-sentence description) |

**Test results:**

| Result  | Count |
| ------- | ----- |
| Passed  | N     |
| Failed  | N     |
| Skipped | N     |

**Edit type:** `<correction | refactor | specification-change>`
**Notes:** What was changed and why.
```

## Edit report — general

Used by general-purpose agents (e.g. Scribe) when an edit completes without a TDD phase context.

```md
**Files changed:**

| File     | Change                                |
| -------- | ------------------------------------- |
| `<path>` | `<line>` — (one-sentence description) |
```
