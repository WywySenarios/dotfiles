# Formatters Setup

This project uses [OpenCode formatters](https://opencode.ai/docs/formatters/) to
auto-format files after every edit. Formatters are configured in
`.opencode/opencode.jsonc` and run automatically on write.

If a formatter's command is not available on your system, OpenCode skips it
silently — no errors. Install only what you need.

---

## Installation

Run any or all of the following:

```bash
# prettier — TypeScript, JavaScript, Markdown, JSON, YAML, CSS, HTML
npm install -g prettier

# shfmt — Shell scripts (.sh, .bash)
sudo apt install shfmt

# ruff — Python (.py, .pyi)
sudo apt install pipx           # if you don't have pipx yet
pipx ensurepath
pipx install ruff

# gofmt — Go (.go) — installs the full Go toolchain
sudo apt install golang-go

# rustfmt — Rust (.rs)
sudo apt install rustfmt cargo

# clang-format — C, C++ (.c, .cpp, .h, .hpp, .ino, …)
sudo apt install clang-format

# air — R (.R) — not in Debian repos, download from GitHub
curl -LO https://github.com/posit-dev/air/releases/latest/download/air-x86_64-unknown-linux-gnu
chmod +x air-x86_64-unknown-linux-gnu
sudo mv air-x86_64-unknown-linux-gnu /usr/local/bin/air
```

### Notes

- **prettier:** `.opencode/opencode.jsonc` uses `npx prettier`, so installing the package globally is not required.
- **ruff** can also be installed via `pip`:
  `sudo apt install python3-pip python3-venv && pip install --user ruff`
- **rustfmt** via rustup (alternative): `rustup component add rustfmt`
- **clang-format** needs a `.clang-format` config file to activate. Minimal
  example:

  ```yaml
  BasedOnStyle: LLVM
  IndentWidth: 4
  ```

---

## Verify

Confirm a formatter is available:

```bash
npx prettier --version   # prettier
shfmt --version          # shfmt
ruff --version           # ruff
gofmt --version          # gofmt
rustfmt --version        # rustfmt
clang-format --version   # clang-format
air --version            # air
```

OpenCode will run enabled formatters automatically after every file edit. To test, ask it to edit a file of the relevant type and check the result.
