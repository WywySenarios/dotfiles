# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed binary needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac

# Source modular configuration from .bashrc.d/
#   *.sh  files — bashrc section files
#   *.env files — environment variable declarations (exported automatically)
#
# Resolves the .bashrc.d directory. BASH_SOURCE[0] is unreliable during
# shell startup (empty, bare filename, or symlink), so multiple
# strategies are tried in order:
#
#   1. BASH_SOURCE[0] directory   — works when sourced via `.`
#   2. readlink on ~/.bashrc       — works when ~/.bashrc is a symlink
#   3. $PWD                        — covers --rcfile .bashrc
#   4. $HOME                       — generic fallback
#
bashrc_d=""
candidate="${BASH_SOURCE[0]%/*}"
if [ -n "$candidate" ] && [ "$candidate" != "${BASH_SOURCE[0]}" ]; then
  [ -d "$candidate/.bashrc.d" ] && bashrc_d="$candidate/.bashrc.d"
fi
if [ -z "$bashrc_d" ]; then
  candidate="$(dirname "$(readlink -f "$HOME/.bashrc" 2>/dev/null)")"
  [ -d "$candidate/.bashrc.d" ] && bashrc_d="$candidate/.bashrc.d"
fi
if [ -z "$bashrc_d" ]; then
  [ -d "$PWD/.bashrc.d" ] && bashrc_d="$PWD/.bashrc.d"
fi
if [ -z "$bashrc_d" ]; then
  [ -d "$HOME/.bashrc.d" ] && bashrc_d="$HOME/.bashrc.d"
fi
if [ -d "$bashrc_d" ]; then
  shopt -s globstar
  for file in "$bashrc_d"/**/*.sh; do
    [ -r "$file" ] && . "$file"
  done
  for file in "$bashrc_d"/**/*.env; do
    [ -r "$file" ] && . "$file"
  done
  shopt -u globstar
  unset file
fi
unset bashrc_d
export PATH=$PATH:/usr/local/go/bin
