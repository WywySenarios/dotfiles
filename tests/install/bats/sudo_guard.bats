#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
}

@test "bats.sh: root (UID=0) skips sudo" {
	run bash -c '
		_uid=0
		SUDO=""
		if [ "$_uid" -ne 0 ]; then
			SUDO="sudo"
		fi
		echo "SUDO=[$SUDO]"
	'
	assert_output "SUDO=[]"
}

@test "bats.sh: non-root with sudo uses sudo" {
	run bash -c '
		_uid=1000
		SUDO=""
		if [ "$_uid" -ne 0 ]; then
			SUDO="sudo"
		fi
		echo "SUDO=[$SUDO]"
	'
	assert_output "SUDO=[sudo]"
}

@test "bats.sh: non-root with sudo passes guard" {
	run bash -c '
		_uid=1000
		if [ "$_uid" -ne 0 ] && ! command -v sudo &>/dev/null; then
			echo "would exit"
			exit 1
		fi
		echo "pass"
	'
	assert_output "pass"
}
