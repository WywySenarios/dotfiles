#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
	DOTFILES="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
	ARGON2="$DOTFILES/scripts/pswd/hash_argon2id.py"
}

@test "hash_argon2id.py exists and is executable" {
	[ -x "$ARGON2" ]
}

# --- Encrypt ---

@test "--encrypt outputs user:argon2id format" {
	run bash -c "printf '%s\n' testpass | ${ARGON2@Q} --encrypt"
	assert_success
	[[ "$output" == admin:\$argon2id\$* ]]
}

@test "--encrypt custom user" {
	run bash -c "printf '%s\n' testpass | ${ARGON2@Q} --encrypt --user registry"
	assert_success
	[[ "$output" == registry:\$argon2id\$* ]]
}

# --- Decrypt ---

@test "--decrypt matches correct password" {
	hash=$(printf '%s\n' testpass | "$ARGON2" --encrypt)
	hash_only="${hash#*:}"
	run bash -c "printf '%s\n' testpass | ${ARGON2@Q} --decrypt --hash ${hash_only@Q}"
	assert_success
	assert_output "OK"
}

@test "--decrypt rejects wrong password" {
	hash=$(printf '%s\n' testpass | "$ARGON2" --encrypt)
	hash_only="${hash#*:}"
	run bash -c "printf '%s\n' wrongpass | ${ARGON2@Q} --decrypt --hash ${hash_only@Q}"
	assert_failure
	assert_output "MISMATCH"
}

@test "--decrypt accepts htpasswd format (user:hash)" {
	hash=$(printf '%s\n' testpass | "$ARGON2" --encrypt)
	run bash -c "printf '%s\n' testpass | ${ARGON2@Q} --decrypt --hash ${hash@Q}"
	assert_success
	assert_output "OK"
}

@test "--decrypt without --hash fails" {
	run bash -c "printf '%s\n' testpass | ${ARGON2@Q} --decrypt"
	assert_failure
}

# --- Error handling ---

@test "empty password is rejected" {
	run bash -c "printf '' | ${ARGON2@Q} --encrypt"
	assert_failure
	[[ "$output" == *"password cannot be empty"* ]]
}

@test "empty password for --decrypt is rejected" {
	run bash -c "printf '' | ${ARGON2@Q} --decrypt --hash 'anything'"
	assert_failure
	[[ "$output" == *"password cannot be empty"* ]]
}

@test "no stdin fails with error" {
	run "$ARGON2"
	assert_failure
}
