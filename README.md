# dotfiles

Welcome to my dotfiles repo!

I run bare Debian at home, and this repo packages everything so I can take my personal dev environment wherever I go.

This repo contains submodules. Run `git submodule update --init --recursive` to install the submodules.

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
