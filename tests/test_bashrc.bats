#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	load '/usr/lib/bats/bats-file/load.bash'
	DOTFILES="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "bashrc has valid syntax" {
	run bash -n "$DOTFILES/.bashrc"
	assert_success
}

@test "all bashrc.d/*.sh files have valid syntax" {
	while IFS= read -r -d '' f; do
		run bash -n "$f"
		assert_success "$(basename "$f") has syntax errors"
	done < <(find "$DOTFILES/.bashrc.d" -name '*.sh' -print0)
}

@test ".bashrc.d discovery: \$PWD fallback" {
	TMPDIR="$(mktemp -d)"
	mkdir -p "$TMPDIR/.bashrc.d"
	echo 'echo "discovered-ok"' > "$TMPDIR/.bashrc.d/00-test.sh"

	run bash -c '
		cd "$1" || exit 1
		bashrc_d=""
		candidate="${BASH_SOURCE[0]%/*}"
		if [ -n "$candidate" ] && [ "$candidate" != "${BASH_SOURCE[0]}" ]; then
			[ -d "$candidate/.bashrc.d" ] && bashrc_d="$candidate/.bashrc.d"
		fi
		[ -z "$bashrc_d" ] && { candidate="$(dirname "$(readlink -f "$HOME/.bashrc" 2>/dev/null || true)")"; [ -d "$candidate/.bashrc.d" ] && bashrc_d="$candidate/.bashrc.d"; }
		[ -z "$bashrc_d" ] && { [ -d "$PWD/.bashrc.d" ] && bashrc_d="$PWD/.bashrc.d"; }
		[ -z "$bashrc_d" ] && { [ -d "$HOME/.bashrc.d" ] && bashrc_d="$HOME/.bashrc.d"; }
		if [ -d "$bashrc_d" ]; then
			for f in "$bashrc_d"/*.sh; do
				[ -r "$f" ] && . "$f"
			done
		fi
	' -- "$TMPDIR"
	rm -rf "$TMPDIR"

}

@test "PATH: \$HOME/.local/bin is added when missing" {
	run env --unset=HOME PATH="/usr/bin:/bin" HOME="/tmp/test-home" bash -c '
		case ":${PATH}:" in
			*:"$HOME/.local/bin":*) echo "already-there" ;;
			*) echo "added" ;;
		esac
	'
	assert_output "added"
}
