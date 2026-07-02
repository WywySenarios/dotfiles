
## Conventions

### Running tests

When running tests, use the following command:

```bash
/etc/Wywy-Website-Control/run.sh <service> test
```

If a bash command is denied (e.g. `npm install`, `pip`, `python`, `docker`, `git`), **STOP** and ask the user to run it for you or to grant the necessary permission. Do not attempt to work around the restriction.

### Report output format

When reporting the results of any phase or edit, use these canonical table formats:

**Files changed:**
| File | Change |
|------|--------|
| `<path>` | `<line>` — (one-sentence description) |

**Test results:**
| Result | Count |
|--------|-------|
| Passed | N |
| Failed | N |
| Skipped | N |

## Code References

When referencing specific functions or pieces of code include the pattern `file_path:line_number` to allow the user to easily navigate to the source code location.

<example>
user: Where are errors from the client handled?
assistant: Clients are marked as failed in the `connectToServer` function in src/services/process.ts:712.
</example>
