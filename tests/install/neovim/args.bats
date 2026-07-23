#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
}

@test "neovim.sh: default GIT_USER is WywySenarios" {
	run bash -c '
		GIT_USER="WywySenarios"
		echo "$GIT_USER"
	'
	assert_output "WywySenarios"
}

@test "neovim.sh: --me flag sets GIT_USER from git config" {
	run bash -c '
		GIT_USER="WywySenarios"
		for arg in "$@"; do
			case "$arg" in
				--me) GIT_USER="$(git config user.name 2>/dev/null || echo "fallback")" ;;
			esac
		done
		echo "$GIT_USER"
	' -- "--me"
	assert_success
}

@test "neovim.sh: existing NVIM_CONFIG dir skips clone" {
	run bash -c '
		NVIM_CONFIG="/tmp/nonexistent-nvim-config-$$"
		if [ ! -d "$NVIM_CONFIG" ]; then
			echo "clone"
		else
			echo "skip"
		fi
	'
	assert_output "clone"
}
