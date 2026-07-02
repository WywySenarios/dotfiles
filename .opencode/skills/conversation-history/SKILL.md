---
name: conversation-history
description: Analyze recent opencode conversations by querying the local SQLite database (~/.local/share/opencode/opencode.db). Use when asked about past sessions, agent activity, usage stats, or tool-call history.
---

# Conversation History Analyzer

Query `~/.local/share/opencode/opencode.db` — no pip dependencies, uses Python 3's built-in `sqlite3`.

## Script

```bash
python3 .opencode/skills/conversation-history/analyze <command> [options]
```

## Commands

| Command           | Description                                                             |
| ----------------- | ----------------------------------------------------------------------- |
| `recent`          | Latest 20 sessions with message/part/token counts                       |
| `search <kw>`     | Find sessions by keyword in title or slug                               |
| `transcript <id>` | Full session with every part typed (text, reasoning, tool, patch, step) |
| `tools`           | All tool calls across recent sessions                                   |
| `top-tools`       | Most-used tools overall                                                 |
| `errors`          | Failed/errored tool calls                                               |
| `usage`           | Token/cost totals by agent type                                         |
| `daily`           | Daily session/cost/token summary (last 14 days)                         |
| `models`          | Model usage breakdown                                                   |
| `todos`           | Recent todo items                                                       |
| `list`            | Show full help text                                                     |

## Options

| Flag          | Default      | Description                 |
| ------------- | ------------ | --------------------------- |
| `--limit N`   | 20           | Row limit                   |
| `--days N`    | 14           | Days for `daily` command    |
| `--full-text` | off          | Full text in transcripts    |
| `--db <path>` | default path | Alternate database location |

## Examples

```bash
python3 .opencode/skills/conversation-history/analyze recent --limit 5
python3 .opencode/skills/conversation-history/analyze search preseed
python3 .opencode/skills/conversation-history/analyze transcript ses_0df734734ffetLdCWrxxJzxIwX
python3 .opencode/skills/conversation-history/analyze errors
```

## Schema reference

See `SCHEMA.md` in this directory for table schemas, column descriptions, and JSON data formats.

## Notes

- DB path: `~/.local/share/opencode/opencode.db`
- Timestamps are **Unix epoch milliseconds** (script converts to ISO dates)
- IDs: `ses_*` (sessions), `msg_*` (messages), `prt_*` (parts)
- Part `data` is JSON with types: `text`, `reasoning`, `tool`, `step-start`, `step-finish`, `compaction`, `patch`
- Tool call `state.input` / `state.output` are included in the `tools` and `transcript` commands
- The `tools` command shows a preview of `state.output` (first 100 chars)
