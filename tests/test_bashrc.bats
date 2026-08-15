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

@test "load_dir sources *.sh from a directory" {
	TMPDIR="$(mktemp -d)"
	mkdir -p "$TMPDIR/shell.d"
	echo 'echo "loaded-ok"' > "$TMPDIR/shell.d/00-test.sh"

	run bash -c '
		load_dir() {
			_d="$1"
			[ -d "$_d" ] || return 0
			for _f in "$_d"/*.sh "$_d"/*.env "$_d"/*/*.sh "$_d"/*/*.env; do
				[ -r "$_f" ] && . "$_f"
			done
			unset _d _f
		}
		load_dir "$1/shell.d"
	' -- "$TMPDIR"
	assert_output "loaded-ok"
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
