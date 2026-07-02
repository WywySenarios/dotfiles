# packages.d — dev machine packages

Every package and tool that this dotfiles repo and the Wywy-Website-Control
infrastructure depend on, organized by package manager.

Each `.txt` file maps to a single install command — run the whole file, or
pick individual sections.

## Quick install

```bash
# Helper: extract package names, stripping comments and blank lines
pkgs() { awk '!/^#/ && !/^$/ {print $1}' "packages.d/$1"; }

# Apt — system core, languages/formatters, deployment
sudo apt install -y $(pkgs apt.txt)

# npm global tools
npm install -g $(pkgs npm.txt)

# pipx
pipx install $(pkgs pipx.txt)

# pip
pip install $(pkgs pip.txt)

# Go modules
awk '!/^#/ && !/^$/ {print $1}' packages.d/go.txt | xargs -n1 go get
```

Tools listed in `manual.txt` must be installed by hand (see inline commands).

Or use the wrapper script:

```bash
./install.sh apt.txt                       # apt (default)
./install.sh --npm npm.txt                 # npm
./install.sh --pipx pipx.txt               # pipx
./install.sh --pip pip.txt                 # pip
./install.sh --go go.txt                   # go get
```

## File inventory

| File         | Package manager | What's inside                                |
| ------------ | --------------- | -------------------------------------------- |
| `apt.txt`    | apt             | System core, language toolchains, deployment |
| `npm.txt`    | npm             | Global tools + Astro app project deps        |
| `pipx.txt`   | pipx            | Python CLI tools (ruff)                      |
| `pip.txt`    | pip             | Python libraries (kubernetes)                |
| `go.txt`     | go get          | Go modules (sqlite, websocket)               |
| `manual.txt` | —               | Manual downloads (Go binary, nvm, air)       |
| `install.sh` | —               | Wrapper script for all of the above          |

## Sources scanned

- `dotfiles/` — `.bashrc`, `.bashrc.d/`, `docs/FORMATTERS.md`, `README.md`
- `/etc/Wywy-Website-Control/` — `install.sh`, `scripts/install/*`, `docs/`, `k8s/`
- Service repos: Wywy-Website-Cache, Wywy-Website, Wywy-Website-Backup,
  Wywy-Website-Master-Database, Wywy-Codes, Wywy-CI

## Adding a new package

1. Add a line to the correct `*.txt` file (by package manager).
2. Include a comment with the source reference (file:line).
3. If a new package manager is needed, create a new `.txt` file.
