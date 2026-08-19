# dotfiles

Welcome to my dotfiles repo!

I run bare Debian (bash) on my dev machine and macOS (zsh) on my laptop. This repo packages everything so I can take my personal dev environment wherever I go.

This repo contains submodules. Run `git submodule update --init --recursive` to install the submodules.

## Shell configuration

Shell config is split three ways so bash and zsh share environment but keep their own behaviour:

| Path                     | Contents                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| `shell.d/`               | Shared environment (POSIX-sh): `PATH`, opencode config, nvm, go. Sourced by both shells. |
| `.bashrc` → `.bashrc.d/` | bash-only: history, prompt, aliases, completion.                                         |
| `.zshrc` → `.zshrc.d/`   | zsh-only: history, prompt, aliases, completion.                                          |

The loaders in `.bashrc`/`.zshrc` source `*.sh` and `*.env` from a directory (top level and one level deep) and are portable — no `globstar`, no `readlink -f` — so they run on macOS's bash 3.2 and zsh alike.

Install with the deploy scripts (or symlink manually):

```bash
# Debian (bash)
install/.bashrc.sh

# macOS (zsh)
install/.zsh.sh
```

Both scripts are idempotent: existing non-symlinks are backed up to `*.bak` before linking, and re-running replaces stale symlinks.

`~/.zprofile` handles Homebrew on macOS. nvm is loaded from `shell.d/nvm.sh`, so no nvm block belongs in `~/.zprofile`.

## Installation Scripts

Scripts under `install` install software (obviously!). Not all of them are idempotent. Treat them as a list of commands that I've previously used rather than executeables that should just "work": in my experience, once the package distributor changes links or EOL hits, links will invalidate and the script will break. You might need to edit a couple of words to get it to work!

## Plugins

### [opencode-rbash](plugins/opencode-rbash)

Restricted bash plugin for opencode with a three-layer defense (allowlist, pipe validation, rbash).

### Installation

```bash
# 1. Clone with submodules (or init if already cloned)
git clone --recurse-submodules <your-repo-url>
# or: git submodule update --init --recursive

# 2. Install plugin dependencies
cd plugins/opencode-rbash && npm install

# 3. Register the plugin in .opencode/opencode.jsonc
```

Add to `.opencode/opencode.jsonc`:

```jsonc
{
  "plugins": {
    "rbash": {
      "path": "plugins/opencode-rbash"
    }
  }
}
```

See the [plugin README](plugins/opencode-rbash/README.md) for configuration details.
