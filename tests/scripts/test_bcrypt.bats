#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	DOTFILES="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
	BCRYPT="$DOTFILES/scripts/pswd/hash_bcrypt.py"
}

@test "hash_bcrypt.py exists and is executable" {
	[ -x "$BCRYPT" ]
}

# --- Encrypt ---

@test "--encrypt outputs user:hash format" {
	run bash -c "printf '%s\n' testpass | ${BCRYPT@Q} --encrypt"
	assert_success
	[[ "$output" == admin:\$2[abxy]\$10\$* ]]
}

@test "--encrypt custom user" {
	run bash -c "printf '%s\n' testpass | ${BCRYPT@Q} --encrypt --user registry"
	assert_success
	[[ "$output" == registry:\$2[abxy]\$10\$* ]]
}

# --- Decrypt ---

@test "--decrypt matches correct password" {
	hash=$(printf '%s\n' testpass | "$BCRYPT" --encrypt)
	hash_only="${hash#*:}"
	run bash -c "printf '%s\n' testpass | ${BCRYPT@Q} --decrypt --hash ${hash_only@Q}"
	assert_success
	assert_output "OK"
}

@test "--decrypt rejects wrong password" {
	hash=$(printf '%s\n' testpass | "$BCRYPT" --encrypt)
	hash_only="${hash#*:}"
	run bash -c "printf '%s\n' wrongpass | ${BCRYPT@Q} --decrypt --hash ${hash_only@Q}"
	assert_failure
	assert_output "MISMATCH"
}

@test "--decrypt accepts htpasswd format (user:hash)" {
	hash=$(printf '%s\n' testpass | "$BCRYPT" --encrypt)
	run bash -c "printf '%s\n' testpass | ${BCRYPT@Q} --decrypt --hash ${hash@Q}"
	assert_success
	assert_output "OK"
}

@test "--decrypt without --hash fails" {
	run bash -c "printf '%s\n' testpass | ${BCRYPT@Q} --decrypt"
	assert_failure
}

# --- Error handling ---

@test "empty password is rejected" {
	run bash -c "printf '' | ${BCRYPT@Q} --encrypt"
	assert_failure
	[[ "$output" == *"password cannot be empty"* ]]
}

@test "empty password for --decrypt is rejected" {
	run bash -c "printf '' | ${BCRYPT@Q} --decrypt --hash 'anything'"
	assert_failure
	[[ "$output" == *"password cannot be empty"* ]]
}

@test "no stdin fails with error" {
	run "$BCRYPT"
	assert_failure
}
