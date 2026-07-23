#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	DOTFILES="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "all install scripts have valid syntax" {
	while IFS= read -r -d '' f; do
		rel="${f#$DOTFILES/}"
		run bash -n "$f"
		if [ "$status" -ne 0 ]; then
			echo "SYNTAX ERROR in $rel:"
			echo "$output"
			return 1
		fi
	done < <(find "$DOTFILES/install" -name '*.sh' -print0)
}
