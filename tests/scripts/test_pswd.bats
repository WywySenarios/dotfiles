#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	DOTFILES="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
	# Save shell options before sourcing (pswd.sh sets -euo pipefail)
	__pswd_opts="$(set +o)"
	source "$DOTFILES/scripts/pswd/pswd.sh"
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
	run "$DOTFILES/scripts/pswd/pswd.sh" alnum
	assert_success
	[ ${#output} -eq 24 ]
}

@test "CLI: num 8 produces 8 digits" {
	run "$DOTFILES/scripts/pswd/pswd.sh" num 8
	assert_success
	[[ "$output" =~ ^[0-9]{8}$ ]]
}

@test "CLI: invalid mode exits with error" {
	run "$DOTFILES/scripts/pswd/pswd.sh" nonexistent
	[ "$status" -ne 0 ]
}

@test "CLI: no args prints usage" {
	run "$DOTFILES/scripts/pswd/pswd.sh"
	assert_output --partial "Usage"
}

@test "CLI: --bcrypt outputs bcrypt hash (default common 24)" {
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --bcrypt 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$2[abxy]\$10\$* ]]
}

@test "CLI: --argon2id outputs argon2id hash (default common 24)" {
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --argon2id 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$argon2id\$* ]]
}

@test "CLI: --bcrypt stderr contains password" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt 2>&1 1>/dev/null )
	[[ "$err" == "# Password: "* ]]
}

@test "CLI: --argon2id stderr contains password" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --argon2id 2>&1 1>/dev/null )
	[[ "$err" == "# Password: "* ]]
}

# --- --bcrypt / --argon2id mode + length combinations ---

@test "CLI: --bcrypt secure uses gen_secure (contains punctuation)" {
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --bcrypt secure 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$2[abxy]\$10\$* ]]
	# Verify stderr password contains punctuation
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt secure 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ [[:punct:]] ]]
}

@test "CLI: --bcrypt alnum produces only alphanumeric" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt alnum 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ ^[[:alnum:]]+$ ]]
	# Also verify length is 24 (default)
	[[ ${#pwd} -eq 24 ]]
}

@test "CLI: --bcrypt alnum 32 produces 32-char password" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt alnum 32 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ ^[[:alnum:]]+$ ]]
	[[ ${#pwd} -eq 32 ]]
}

@test "CLI: --bcrypt num 12 produces 12 digits" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt num 12 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ ^[0-9]{12}$ ]]
}

@test "CLI: --bcrypt 16 uses common mode with length 16" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --bcrypt 16 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ ${#pwd} -eq 16 ]]
}

@test "CLI: --argon2id secure uses gen_secure" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --argon2id secure 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ [[:punct:]] ]]
	# Verify argon2id hash on stdout
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --argon2id secure 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$argon2id\$* ]]
}

@test "CLI: --argon2id num 8 produces 8 digits" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --argon2id num 8 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ "$pwd" =~ ^[0-9]{8}$ ]]
}

@test "CLI: --argon2id 32 uses common mode with length 32" {
	err=$( "$DOTFILES/scripts/pswd/pswd.sh" --argon2id 32 2>&1 1>/dev/null )
	pwd="${err#\# Password: }"
	[[ ${#pwd} -eq 32 ]]
}

@test "CLI: --bcrypt with invalid mode falls back to common" {
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --bcrypt invalid 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$2[abxy]\$10\$* ]]
}

@test "CLI: --argon2id with invalid mode falls back to common" {
	run bash -c "${DOTFILES@Q}/scripts/pswd/pswd.sh --argon2id invalid 2>/dev/null"
	assert_success
	[[ "$output" == admin:\$argon2id\$* ]]
}
