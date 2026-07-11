# packages.d — dev machine packages

Every package, tool, and repository this dotfiles repo depends on, organized by
package manager and purpose.

## Structure

```
packages.d/
├── apt/
│   ├── core            # git, build-essential, curl, ...
│   ├── languages       # shfmt, golang-go, rustfmt, nodejs, ...
│   ├── utils           # vim
│   └── deployment      # containerd, docker.io, kubectl, ...
├── npm/
│   ├── global          # prettier
│   └── opencode        # bun, opencode-ai
├── pip/
│   └── default         # kubernetes
├── pipx/
│   └── default         # ruff
├── go/
│   └── default         # modernc.org/sqlite, github.com/coder/websocket
├── manual/
│   └── default         # Tools requiring manual install (no package manager)
├── repos/
│   ├── kubernetes/     # GPG key + apt source for pkgs.k8s.io
│   ├── docker/         # GPG key + apt source for download.docker.com
│   └── proxmox/        # GPG key + apt source for Proxmox VE
├── install.sh          # Installer script
└── README.md
```

Each file contains **only package names** — one per line. The folder path is the
documentation: `apt/core` tells you these are core apt packages without needing
any comments.

## Quick install

```bash
# Install specific sections
./install.sh apt/core apt/languages

# Install all apt packages
./install.sh apt/*

# Install all npm packages
./install.sh npm/*

# Mix and match
./install.sh apt/core npm/opencode pipx/default
```

## Repos

The `repos/` directory manages third-party APT repositories. Each repo has:

- `key.url` — URL to fetch the GPG signing key from
- `source` — the deb source line (written to `/etc/apt/sources.list.d/`)

Placeholder variables in `source` files are expanded at install time:

| Placeholder | Replaced with                  |
| ----------- | ------------------------------ |
| `$DISTRO`   | `$(lsb_release -cs)`           |
| `$ARCH`     | `$(dpkg --print-architecture)` |

```bash
# Setup all repos (GPG keys + sources + apt update)
./install.sh --repos

# Setup specific repos only
./install.sh --repos kubernetes docker
```

## Adding a new package

1. Add a line to the appropriate section file (e.g., `apt/core`).
2. One package name per line. No comments needed — the directory path is the context.

## Adding a new APT repository

1. Create a directory under `repos/` (e.g., `repos/myrepo/`).
2. Add `key.url` with the GPG key URL.
3. Add `source` with the deb source line (use `$DISTRO` / `$ARCH` as needed).
4. Run `./install.sh --repos myrepo`.

## Manual tools

Tools listed in `manual/default` have no package manager. They must be installed
by hand — see the inline instructions in that file.
