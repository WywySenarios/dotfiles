# OpenCode Conversation Database Schema Reference

**Database:** `~/.local/share/opencode/opencode.db`  
**Engine:** SQLite 3

All timestamps are Unix millisecond epoch (`INTEGER`). All IDs are auto-generated text keys.

---

## `session` — top-level conversations

| Column               | Type                     | Description                                         |
| -------------------- | ------------------------ | --------------------------------------------------- |
| `id`                 | `TEXT PK`                | Session ID (`ses_*`)                                |
| `project_id`         | `TEXT FK → project.id`   | Owning project                                      |
| `workspace_id`       | `TEXT FK → workspace.id` | Workspace branch context                            |
| `parent_id`          | `TEXT`                   | Parent session (for forks/continuations)            |
| `slug`               | `TEXT NOT NULL`          | Human-readable slug (e.g. `proud-otter`)            |
| `directory`          | `TEXT NOT NULL`          | Working directory                                   |
| `path`               | `TEXT`                   | Sub-path within the project                         |
| `title`              | `TEXT NOT NULL`          | Session title                                       |
| `version`            | `TEXT NOT NULL`          | App version                                         |
| `share_url`          | `TEXT`                   | Shared session URL                                  |
| `summary_additions`  | `INTEGER`                | Lines added                                         |
| `summary_deletions`  | `INTEGER`                | Lines deleted                                       |
| `summary_files`      | `INTEGER`                | Files changed                                       |
| `summary_diffs`      | `TEXT`                   | JSON array of diff summaries                        |
| `metadata`           | `TEXT`                   | Arbitrary JSON metadata                             |
| `cost`               | `REAL DEFAULT 0`         | Total cost in USD                                   |
| `tokens_input`       | `INTEGER DEFAULT 0`      | Total input tokens                                  |
| `tokens_output`      | `INTEGER DEFAULT 0`      | Total output tokens                                 |
| `tokens_reasoning`   | `INTEGER DEFAULT 0`      | Total reasoning tokens                              |
| `tokens_cache_read`  | `INTEGER DEFAULT 0`      | Cache read tokens                                   |
| `tokens_cache_write` | `INTEGER DEFAULT 0`      | Cache write tokens                                  |
| `revert`             | `TEXT`                   | Revert snapshot info                                |
| `permission`         | `TEXT`                   | Permission mode used                                |
| `agent`              | `TEXT`                   | Agent type (scribe, explore, green, refactor, etc.) |
| `model`              | `TEXT`                   | JSON object with `id` and `providerID`              |
| `time_created`       | `INTEGER NOT NULL`       | Session start                                       |
| `time_updated`       | `INTEGER NOT NULL`       | Last update                                         |
| `time_compacting`    | `INTEGER`                | Last compaction                                     |
| `time_archived`      | `INTEGER`                | Archive timestamp                                   |

**Indexes:** `session_project_idx`, `session_workspace_idx`, `session_parent_idx`

---

## `message` — messages within a session

| Column         | Type                   | Description          |
| -------------- | ---------------------- | -------------------- |
| `id`           | `TEXT PK`              | Message ID (`msg_*`) |
| `session_id`   | `TEXT FK → session.id` | Parent session       |
| `time_created` | `INTEGER NOT NULL`     | Creation time        |
| `time_updated` | `INTEGER NOT NULL`     | Last update          |
| `data`         | `TEXT NOT NULL`        | **JSON** — see below |

### `data` JSON structure

```json
{
  "role": "user" | "assistant",
  "agent": "scribe" | "explore" | "green" | ...,
  "model": { "providerID": "...", "modelID": "..." },
  "time": { "created": 1234567890000 },
  "summary": {
    "diffs": [ { "file": "...", "additions": N, "deletions": N } ]
  }
}
```

---

## `part` — individual content blocks within a message

| Column         | Type                   | Description                   |
| -------------- | ---------------------- | ----------------------------- |
| `id`           | `TEXT PK`              | Part ID (`prt_*`)             |
| `message_id`   | `TEXT FK → message.id` | Parent message                |
| `session_id`   | `TEXT FK → session.id` | Parent session (denormalized) |
| `time_created` | `INTEGER NOT NULL`     | Creation time                 |
| `time_updated` | `INTEGER NOT NULL`     | Last update                   |
| `data`         | `TEXT NOT NULL`        | **JSON** — see below          |

### `data` JSON structure by `type`

**`text`** — Natural language output

```json
{ "type": "text", "text": "..." }
```

**`reasoning`** — Model chain-of-thought

```json
{
  "type": "reasoning",
  "text": "...",
  "time": { "start": 1234567890000, "end": 1234567895000 }
}
```

**`tool`** — Tool call (input + output)

```json
{
  "type": "tool",
  "tool": "read" | "edit" | "grep" | "webfetch" | "bash" | "glob" | "task" | ...,
  "callID": "call_*",
  "state": {
    "status": "completed" | "error",
    "input": { /* tool-specific arguments */ },
    "output": "string result",
    "metadata": { /* optional extra info */ }
  }
}
```

**`step-start`** — Marks beginning of a model step

```json
{ "type": "step-start", "snapshot": "<git sha>" }
```

**`step-finish`** — Marks completion of a model step

```json
{
  "type": "step-finish",
  "reason": "tool-calls" | "stop" | ...,
  "snapshot": "<git sha>",
  "tokens": {
    "total": N, "input": N, "output": N,
    "reasoning": N,
    "cache": { "write": N, "read": N }
  },
  "cost": 0.0
}
```

**`compaction`** — Context window compaction event

```json
{
  "type": "compaction",
  "auto": true,
  "overflow": false,
  "tail_start_id": "msg_*"
}
```

**`patch`** — File edits applied

```json
{
  "type": "patch",
  "hash": "<git sha of resulting tree>",
  "files": ["path/to/file1", "path/to/file2"]
}
```

---

## `session_input` — user prompts delivered to a session

| Column         | Type                   | Description               |
| -------------- | ---------------------- | ------------------------- |
| `id`           | `TEXT PK`              | Input ID                  |
| `session_id`   | `TEXT FK → session.id` | Target session            |
| `prompt`       | `TEXT NOT NULL`        | The full user prompt text |
| `delivery`     | `TEXT NOT NULL`        | Delivery mechanism        |
| `admitted_seq` | `INTEGER NOT NULL`     | Sequence when admitted    |
| `promoted_seq` | `INTEGER`              | Sequence when promoted    |
| `time_created` | `INTEGER NOT NULL`     | Creation time             |

---

## `todo` — task items within a session

| Column         | Type                   | Description                                           |
| -------------- | ---------------------- | ----------------------------------------------------- |
| `session_id`   | `TEXT FK → session.id` | Parent session                                        |
| `content`      | `TEXT NOT NULL`        | Task description                                      |
| `status`       | `TEXT NOT NULL`        | `pending` / `in_progress` / `completed` / `cancelled` |
| `priority`     | `TEXT NOT NULL`        | `high` / `medium` / `low`                             |
| `position`     | `INTEGER`              | Sort order (composite PK with session_id)             |
| `time_created` | `INTEGER NOT NULL`     | Creation time                                         |
| `time_updated` | `INTEGER NOT NULL`     | Last update                                           |

---

## `event` / `event_sequence` — event-sourcing log

```sql
event_sequence (aggregate_id PK, seq, owner_id)
event           (id PK, aggregate_id FK, seq, type, data)
```

Used internally for sync and replay. Not typically needed for conversation analysis.

---

## `project` — registered projects

| Column                          | Type            | Description   |
| ------------------------------- | --------------- | ------------- |
| `id`                            | `TEXT PK`       | Project ID    |
| `worktree`                      | `TEXT NOT NULL` | Absolute path |
| `name`                          | `TEXT`          | Display name  |
| `time_created` / `time_updated` | `INTEGER`       | Timestamps    |

---

## Useful query patterns

### Latest N sessions with message/token counts

```sql
SELECT s.id, s.title, s.agent, s.cost, s.tokens_input, s.tokens_output,
       s.time_created, s.time_updated,
       (SELECT COUNT(*) FROM message m WHERE m.session_id = s.id) AS msg_count,
       (SELECT COUNT(*) FROM part p WHERE p.session_id = s.id) AS part_count
FROM session s
ORDER BY s.time_created DESC
LIMIT 20;
```

### Tool calls in the last N sessions

```sql
SELECT p.id, p.session_id,
       json_extract(p.data, '$.tool') AS tool_name,
       json_extract(p.data, '$.state.status') AS status,
       json_extract(p.data, '$.callID') AS call_id,
       p.time_created
FROM part p
WHERE json_extract(p.data, '$.type') = 'tool'
  AND p.session_id IN (SELECT id FROM session ORDER BY time_created DESC LIMIT 10)
ORDER BY p.time_created DESC;
```

### Token usage per agent type

```sql
SELECT agent,
       SUM(tokens_input) AS total_input,
       SUM(tokens_output) AS total_output,
       SUM(tokens_reasoning) AS total_reasoning,
       SUM(cost) AS total_cost,
       COUNT(*) AS session_count
FROM session
GROUP BY agent
ORDER BY total_cost DESC;
```

### Unresolved TODOs across recent sessions

```sql
SELECT t.session_id, s.title, t.content, t.status, t.priority
FROM todo t
JOIN session s ON s.id = t.session_id
WHERE t.status IN ('pending', 'in_progress')
  AND s.time_created > (strftime('%s', 'now') - 86400) * 1000
ORDER BY t.priority, t.time_created;
```
