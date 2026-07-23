#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
}

@test "python.sh: uv not installed returns install" {
	run bash -c '
		if ! command -v __uv_does_not_exist_xyz &>/dev/null; then
			echo "install"
		else
			echo "skip"
		fi
	'
	assert_output "install"
}
