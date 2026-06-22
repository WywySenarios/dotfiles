---
name: commit
description: Commit changes in a Wywy service repository. Use when the user asks to commit, save work, or make a commit.
---

# Commit changes

## Workflow

### 1. Stage and review

```bash
git add <files>
```

Bundle related changes together. Each commit should focus on exactly one modification. You are encouraged to make multiple commits to avoid bundling unrelated changes.

### 2. Commit

The message follows [Conventional Commits](https://www.conventionalcommits.org/):

- `<type>: <description>` — e.g. `feat: add login page`
- `<type>(<scope>): <description>` — e.g. `feat(auth): add login page`

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`.

```bash
git commit -m "<type>(<scope>): <description>"
```