# Enable zsh completion.
autoload -Uz compinit && compinit

# uv completion (generated on the fly).
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
fi
