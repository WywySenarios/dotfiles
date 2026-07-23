#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	DOTFILES="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
	# Save shell options before sourcing (pswd.sh sets -euo pipefail)
	__pswd_opts="$(set +o)"
	source "$DOTFILES/scripts/pswd.sh"
	eval "$__pswd_opts"
	unset __pswd_opts
}

# --- Generator functions ---

@test "gen_alnum is defined" {
	declare -f gen_alnum
}

@test "gen_num is defined" {
	declare -f gen_num
}

@test "gen_secure is defined" {
	declare -f gen_secure
}

@test "gen_common is defined" {
	declare -f gen_common
}

@test "gen_alnum default length is 24" {
	run gen_alnum
	assert_success
	[ ${#output} -eq 24 ]
}

@test "gen_num default length is 24" {
	run gen_num
	assert_success
	[ ${#output} -eq 24 ]
}

@test "gen_secure default length is 24" {
	run gen_secure
	assert_success
	[ ${#output} -eq 24 ]
}

@test "gen_common default length is 24" {
	run gen_common
	assert_success
	[ ${#output} -eq 24 ]
}

@test "gen_alnum custom length 8" {
	run gen_alnum 8
	[ ${#output} -eq 8 ]
}

@test "gen_alnum custom length 32" {
	run gen_alnum 32
	[ ${#output} -eq 32 ]
}

@test "gen_alnum custom length 64" {
	run gen_alnum 64
	[ ${#output} -eq 64 ]
}

@test "gen_alnum custom length 0" {
	run gen_alnum 0
	[ ${#output} -eq 0 ]
}

@test "gen_alnum produces only alphanumeric characters" {
	run gen_alnum 200
	assert_success
	[[ "$output" =~ ^[a-zA-Z0-9]+$ ]]
}

@test "gen_num produces only digits" {
	run gen_num 200
	assert_success
	[[ "$output" =~ ^[0-9]+$ ]]
}

@test "gen_secure includes punctuation characters" {
	run gen_secure 200
	assert_success
	[[ "$output" =~ [[:punct:]] ]]
}

# --- CLI mode ---

@test "CLI: alnum default produces 24 chars" {
	run "$DOTFILES/scripts/pswd.sh" alnum
	assert_success
	[ ${#output} -eq 24 ]
}

@test "CLI: num 8 produces 8 digits" {
	run "$DOTFILES/scripts/pswd.sh" num 8
	assert_success
	[[ "$output" =~ ^[0-9]{8}$ ]]
}

@test "CLI: invalid mode exits with error" {
	run "$DOTFILES/scripts/pswd.sh" nonexistent
	[ "$status" -ne 0 ]
}

@test "CLI: no args prints usage" {
	run "$DOTFILES/scripts/pswd.sh"
	assert_output --partial "Usage"
}
