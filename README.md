# WywySenarios dotfiles

## Plugins

### [opencode-rbash](plugins/opencode-rbash)

Restricted bash plugin for opencode with a three-layer defense (allowlist, pipe validation, rbash).

### Installation

```bash
# 1. Clone with submodules (or init if already cloned)
git clone --recurse-submodules https://github.com/WywySenarios/WywySenarios.git
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
