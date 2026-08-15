# ~/.zshrc: executed by zsh for interactive shells.

# Root of the dotfiles repo. Override to relocate.
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Tolerate unmatched globs — load_dir relies on this; zsh errors by default.
setopt NULL_GLOB

# Source a directory of modular shell snippets.
# Loads *.sh and *.env at the top level and one directory deep.
load_dir() {
    _d="$1"
    [ -d "$_d" ] || return 0
    for _f in "$_d"/*.sh "$_d"/*.env "$_d"/*/*.sh "$_d"/*/*.env; do
        [ -r "$_f" ] && . "$_f"
    done
    unset _d _f
}

# Shared environment (PATH, opencode config, nvm, go) — sourced by all shells.
load_dir "$DOTFILES/shell.d"

# zsh-specific configuration (history, prompt, aliases, completion).
load_dir "$DOTFILES/.zshrc.d"
