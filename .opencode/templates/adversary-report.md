# Adversary Report — Shared Rubric & Format

This is the shared specification for adversary reports. It is loaded into every
agent's context so that all agents know what an adversary report looks like and
can read, produce, or interpret one. The adversary agents (`plan-adversary`,
`adversary`) follow this exactly; every other agent can rely on reports
matching this format.

## Severity & Priority Scale

All issues found by an adversary agent must be classified with both a severity and a priority.

### Severity: SEV-1 through SEV-5

| Level | Label        | Definition                                                      |
| ----- | ------------ | --------------------------------------------------------------- |
| SEV-1 | **Critical** | Causes data loss, corruption, security breach, or total outage. |
| SEV-2 | **High**     | Major feature broken, no acceptable workaround.                 |
| SEV-3 | **Medium**   | Feature partially broken, has a workaround.                     |
| SEV-4 | **Low**      | Minor issue, cosmetic, or non-functional defect.                |
| SEV-5 | **Cosmetic** | Nitpick: style, naming, documentation typo, minor polish.       |

An individual agent may add anchors specific to its review target (e.g. plan-text defects, speculative risks). They extend this table; they do not replace it.

### Priority: P0 through P3

| Level | Label         | Definition                                                     |
| ----- | ------------- | -------------------------------------------------------------- |
| P0    | **Immediate** | Must be fixed before anything else — blocks all progress.      |
| P1    | **High**      | Should be fixed in this cycle/PR — important but not blocking. |
| P2    | **Medium**    | Fix when convenient — can be deferred without major risk.      |
| P3    | **Low**       | Nice-to-have — address if time permits.                        |

## Holistic Score

The holistic score is an **objective, issue-derived health score** from 0.0 to 10.0. It measures the _materiality_ of the defects found, not the verdict. A clean target with no issues scores 10.0. The score informs, but never decides, the verdict.

### Computation

Start at **10.0**. Apply deductions:

1. **Group issues by root cause.** If multiple issues share one root cause, group them and apply the single worst penalty of the group once. Do not double-count.
2. **Deduct the larger of the severity penalty and the priority penalty — never both.** Severity and priority measure the same "how bad is this" dimension; charging both inflates the damage.
3. **Cap non-blocking noise.** The combined deduction from issues that are **SEV-4/SEV-5 and P2/P3** (cosmetic/low nits that do not block `Pass`) is capped at **-1.0** total. A pile of nits can never drag a target below "Fair".
4. Floor the result at **0.0**.

Penalty table (single deduction = max of the two rows):

| Severity | Penalty | Priority | Penalty |
| -------- | ------- | -------- | ------- |
| SEV-1    | -3.0    | P0       | -1.5    |
| SEV-2    | -2.0    | P1       | -1.0    |
| SEV-3    | -1.0    | P2       | -0.5    |
| SEV-4    | -0.4    | P3       | -0.2    |
| SEV-5    | -0.2    |          |         |

Example: a single SEV-2/P1 issue deducts `max(-2.0, -1.0)` = **-2.0**, not -3.0. A SEV-5/P3 nit deducts `max(-0.2, -0.2)` = **-0.2**. Five SEV-5 nits deduct **-0.2 × 5 = -1.0**, floored by the cap, never more.

### Score interpretation

| Range | Label        | Meaning                                           |
| ----- | ------------ | ------------------------------------------------- |
| 9-10  | **Healthy**  | No material issues. Ship with confidence.         |
| 7-8.9 | **Fair**     | Minor issues. Fix before shipping.                |
| 4-6.9 | **Risky**    | Significant issues. Must resolve before proceed.  |
| 1-3.9 | **Broken**   | Major defects. Do not proceed without a redesign. |
| 0     | **Redesign** | Redesign required.                                |

The **score is not the verdict**. A 0.0 score does not imply `Block`: `Block` requires a SEV-1 issue. If the score floors with no SEV-1, still render `Revise`. The score measures materiality; the verdict decides whether the target may proceed.

### Verdict thresholds

The verdict is derived deterministically from the issues found (severity and priority), **not** from the score. Apply the first matching row from top to bottom:

| Verdict    | Trigger                                                                              |
| ---------- | ------------------------------------------------------------------------------------ |
| **Block**  | Any SEV-1 issue.                                                                     |
| **Revise** | Any SEV-2 or SEV-3 issue, any P0 or P1 issue.                                        |
| **Pass**   | No SEV-1/2/3 issues and no P0/P1 issues. The holistic score is not a pass criterion. |

The review target is not ready until the verdict is **Pass**. A `Revise` report must
list exactly what must change to reach `Pass`; a `Block` report ends the audit.

## Report file

Every review report is **persisted to disk** so the history of verdicts, scores, and issues is queryable over time. Write the report to: `<plan-storage>/adversary/<report-name>.md`, where `<plan-storage>` is the `$PLAN_STORAGE_PATH` environment variable (default: `$HOME/plans/`).

The `adversary/` subdirectory is the **default and only** report location. Create it if it does not exist. Do **not** write reports to the top level of `<plan-storage>` (e.g. `$HOME/plans/`) or to the reviewed plan's own directory — those are reserved for plans themselves.

### Report naming by mode

- `mode: plan-review` → `<plan-name>.md`
- `mode: code-review` → `<input-base>-<YYYY-MM-DD>.md` (the input's basename without extension, date-stamped; no "adversary" or "code-review" in the filename)

### Frontmatter

Reports must have a YAML frontmatter.

```yaml
timestamp: <ISO-8601 with timezone>
mode: plan-review | code-review
input: <name or path of what was reviewed>
verdict: pass | revise | block
holistic_score: <X.X out of 10.0>
issue_count: <N>
sev1_count: <N>
sev2_count: <N>
sev3_count: <N>
sev4_count: <N>
sev5_count: <N>
p0_count: <N>
p1_count: <N>
p2_count: <N>
p3_count: <N>
invoked_by: <agent_name> | user
```

## Report Body

The full report content goes after the frontmatter.

## Report discipline

- **At most 8 issues**, listed **highest severity first** (ties: highest priority first). Drop or merge findings beyond the 8 most material.
- **Description cells ≤ 200 characters.** Move detail to the corresponding failure-proof row.
- **One finding, once.** Each finding appears in the Issues table; the failure proof gives evidence; the Summary states the bottom line. Do not restate a finding's full description in more than one section.
- **One Suggested Action per issue**, highest severity first. Do not restate the issue description in the action.

### Unified report body template

```md
### Issues Found

| #   | Target     | Severity | Priority | Description          |
| --- | ---------- | -------- | -------- | -------------------- |
| 1   | `<target>` | SEV-2    | P1       | `<what, where, why>` |

`<target>` is a cycle/phase for plan reviews; a `file:line` for code/design reviews.

### Failure proofs

| #   | Proof type | Location     | Detail                             |
| --- | ---------- | ------------ | ---------------------------------- |
| 1   | Static     | `file:line`  | `This will crash when X because Y` |
| 2   | Test       | `test suite` | `Running tests shows Z fails`      |

### Holistic Score

**Score:** `<X.X/10>` — `<Label>`

### Summary

<2-4 sentences. Sentence 1: verdict and score. Sentence 2: what must change. Sentence 3: what is acceptable as-is. Lead with the bottom line.>

### Suggested Actions

1. <one action per issue, highest severity first>
```

## Conversational Output

When the report is delivered in-chat rather than persisted, use this variant:

```md
## ADVERSARY REPORT

**Target:** `<plan-name or file(s)/area>`

**Verdict:** `Pass` | `Revise` | `Block`

### Issues Found

| #   | Target     | Severity | Priority | Description          |
| --- | ---------- | -------- | -------- | -------------------- |
| 1   | `<target>` | SEV-2    | P1       | `<what, where, why>` |

### Failure proofs

| #   | Proof type | Location     | Detail                             |
| --- | ---------- | ------------ | ---------------------------------- |
| 1   | Static     | `file:line`  | `This will crash when X because Y` |
| 2   | Test       | `test suite` | `Running tests shows Z fails`      |

### Holistic Score

**Score:** `<X.X/10>` — `<Label>`

### Summary

<2-4 sentences. Sentence 1: verdict and score. Sentence 2: what must change. Sentence 3: what is acceptable as-is. Lead with the bottom line.>

### Suggested Actions

1. <one action per issue, highest severity first>
```
