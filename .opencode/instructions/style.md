# General style guide

## Comments

Comments provide value when the reader understands the code faster, and useless comments hurt when they crowd out valuable ones. A comment is noise if a reader could delete it, read the code, and reconstruct everything important.

Comments justify decisions, not mechanics. They explain _why_ the code exists. They should never narrate what the code does or how you implemented it.

### Don't repeat after yourself

A common antipattern is narrating your own work inside comments. For example, this comment restates the loop it sits above and carries zero information:

```sh
# Accept --bcrypt/--argon2id before or after the mode/length args.
# Normalize into a positional list plus a hash_mode flag.
for arg in "$@"; do
  ...
done
```

The comment below is a example of a good comment, one that carries information the code itself does not intuitively reveal:

```python
@pytest.mark.skip(
    reason="Mutates process-level env vars — a testing-config antipattern; "
    "will be replaced by a fixture-based approach next week."
)
def test_populate_env():
    ...
```

Before leaving a comment, run the deletion test: if the code loses nothing without it, delete it. Keep a comment only for a non-obvious decision, a behavioral contract, or an invariant a future refactor could silently break.
