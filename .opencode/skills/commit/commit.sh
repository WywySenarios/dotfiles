#!/bin/bash
# Commits staged changes in the current repository, with optional submodule recursion.
# Usage: commit.sh [-r] "<message>"
#   -r  Also commit inside each dirty submodule before committing the parent repo.
#
# NOTE: This script only runs git commit. Staging (git add) must be done beforehand.

set -euo pipefail

RECURSE=0

usage() {
	echo "Usage: commit.sh [-r] \"<message>\"" >&2
	exit 1
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-r | --recurse-submodules)
		RECURSE=1
		shift
		;;
	-*)
		echo "Unknown flag: $1" >&2
		usage
		;;
	*) break ;;
	esac
done

if [[ $# -lt 1 ]]; then
	usage
fi

message="$*"

if [[ "$RECURSE" -eq 1 ]]; then
	echo "=== Recurse into submodules ==="
	while IFS=' ' read -r _sub_hash sub_path _rest; do
		if [[ -z "$(git -C "$sub_path" status --porcelain)" ]]; then
			echo "Skipping $sub_path (clean)"
			continue
		fi
		echo "Committing in $sub_path"
		git -C "$sub_path" commit -m "$message" || echo "Warning: commit in $sub_path may have failed" >&2
	done < <(git submodule status --recursive 2>/dev/null || true)
fi

echo "=== Committing ==="
git commit -m "$message"
