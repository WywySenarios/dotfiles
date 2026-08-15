# Prompt: user@host:dir %
autoload -Uz colors && colors
# Expand $fg[...] / $reset_color (and $(...), $var) in PROMPT at display time.
setopt PROMPT_SUBST
PROMPT='%{$fg[green]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}%# '
