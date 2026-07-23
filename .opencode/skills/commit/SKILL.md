---
name: commit
description: Commit changes in the project repository. Use when the user asks to commit, save work, or make a commit.
---

# Commit changes

## Workflow

### 0. Preflight — artifact check

Before staging any files, check whether the working tree contains untracked or modified files that look like build, test, or generated artifacts.

Run:

```bash
git status --porcelain | grep -qE '^\?\?.*(dist/|build/|\.next/|out/|target/|coverage/|\.nyc_output/|\.godot/|export/|\.terraform/|__pycache__/|\.pytest_cache/|node_modules/|\.log$|\.pyc$|\.tfstate|\.DS_Store|Thumbs\.db)'
```

- **If this exits 0** (match found): **STOP.** Report back to the user listing which artifact files were detected. Explain that artifacts should not be committed — ask whether they want to:
  - Add the relevant paths to `.gitignore`, **or**
  - Remove / clean the artifacts, **or**
  - Remove the offending files from the index if already staged, **or**
  - Override the check and proceed anyway.
    Do **not** continue until the user gives explicit guidance.

- **If this exits 1** (no match): proceed with the normal commit workflow below.

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
