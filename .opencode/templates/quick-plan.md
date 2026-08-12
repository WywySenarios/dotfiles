# Quick Plan Template

Use for small-to-medium, single-repo tasks when the user explicitly asks for a plan. The quick-plan is **ephemeral**: write it, get approval, do the work, delete it. The durable record of the task is the code and the edit report — not this file. For full migrations, policies, or cross-repo changes, the `strategist` agent owns the plan.

File location and naming: `~/plans/quick-<name>.md`.

```md
---
name: <short-hyphenated-name>
type: quick
scope: <repo or area the task touches>
desc: <one-sentence description of the task>
created: <ISO-8601 timestamp with timezone>
last_updated: <ISO-8601 timestamp with timezone>
---

# <Short Task Title>

> Ephemeral: delete this file when the task completes. The durable record is the code and the edit report.

## Goal

<One or two sentences: what the task accomplishes and what "done" looks like.>

## Steps

1. <ordered action>
   - <detail if needed>
2. <ordered action>

## Files affected

- <path> — <what changes>
- <path> — <what changes>

## Verification

- <how to check the task is done>
- <command, script, or manual check>
```
