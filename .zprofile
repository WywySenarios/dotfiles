# ~/.zprofile: executed by zsh for login shells (before .zshrc).
# Homebrew on macOS — set PATH before interactive config loads.
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi
