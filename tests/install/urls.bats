#!/usr/bin/env bats

setup() {
	load '/usr/lib/bats/bats-support/load.bash'
	load '/usr/lib/bats/bats-assert/load.bash'
}

@test "firefox.sh signing key URL is reachable" {
	run curl -fsSLI --max-time 10 "https://packages.mozilla.org/apt/repo-signing-key.gpg"
	assert_success
}

@test "vscode.sh signing key URL is reachable" {
	run curl -fsSLI --max-time 10 "https://packages.microsoft.com/keys/microsoft.asc"
	assert_success
}

@test "nerd-fonts release page is reachable" {
	run curl -fsSLI --max-time 10 "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
	assert_success
}

@test "neovim release page is reachable" {
	run curl -fsSLI --max-time 10 "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
	assert_success
}
