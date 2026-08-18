#!/usr/bin/env bash
#
# pswd — sample /dev/urandom for passwords
#
# Usage: pswd.sh <mode> [length]
#
# Modes:
#   alnum    alphanumeric (a-zA-Z0-9)
#   num      digits only (0-9)
#   secure   alphanumeric + all punctuation (may contain weird chars)
#   common   alphanumeric + safe symbols only (no backtick, quotes, backslash)
#
# If sourced, the functions gen_alnum, gen_num, gen_secure, gen_common are available.

set -euo pipefail

DEFAULT_LENGTH=24

gen_alnum() {
	local len="${1:-$DEFAULT_LENGTH}"
	</dev/urandom tr -dc '[:alnum:]' | head -c "$len"
	echo
}

gen_num() {
	local len="${1:-$DEFAULT_LENGTH}"
	</dev/urandom tr -dc '[:digit:]' | head -c "$len"
	echo
}

gen_secure() {
	local len="${1:-$DEFAULT_LENGTH}"
	# Common printable symbols excluding whitespace and ambiguous chars (backtick, quotes)
	</dev/urandom tr -dc '[:alnum:][:punct:]' | head -c "$len"
	echo
}

gen_common() {
	local len="${1:-$DEFAULT_LENGTH}"
	# Widely-accepted symbols — no backtick, quotes, backslash, or shell-reserved chars
	</dev/urandom tr -dc '[:alnum:]!@#$%^&*()_+-={},.<>?/~' | head -c "$len"
	echo
}

# If sourced, just define the functions and return
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
	return 0
fi

# CLI mode
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

usage() {
	echo "Usage: pswd.sh <mode> [length] [--bcrypt|--argon2id]" >&2
	echo "       pswd.sh --bcrypt [mode] [length]" >&2
	echo "       pswd.sh --argon2id [mode] [length]" >&2
	echo "" >&2
	echo "Modes:" >&2
	echo "  alnum    alphanumeric (a-zA-Z0-9)" >&2
	echo "  num      digits only (0-9)" >&2
	echo "  secure   alphanumeric + all punctuation" >&2
	echo "  common   alphanumeric + safe symbols only" >&2
	echo "  --bcrypt [mode] [length]   generate password + bcrypt hash" >&2
	echo "  --argon2id [mode] [length] generate password + argon2id hash" >&2
}

hash_mode=""
positional=()
for arg in "$@"; do
	case "$arg" in
	--bcrypt | --argon2id)
		hash_mode="${arg#--}"
		;;
	*)
		positional+=("$arg")
		;;
	esac
done
set -- "${positional[@]}"

mode="${1:-}"
len="${2:-}"

if [[ -z "$mode" ]]; then
	# e.g. `pswd.sh --bcrypt` → default to common mode
	if [[ -n "$hash_mode" ]]; then
		mode="common"
	else
		usage
		exit 1
	fi
elif [[ ! "$mode" =~ ^(alnum|num|secure|common)$ ]]; then
	# e.g. `pswd.sh --bcrypt 32` → treat 32 as the length in common mode
	if [[ -n "$hash_mode" ]]; then
		len="$mode"
		mode="common"
	else
		usage
		exit 1
	fi
fi

password="$(gen_"$mode" "$len")"
if [[ -n "$hash_mode" ]]; then
	echo "# Password: $password" >&2
	echo "$password" | "$SCRIPT_DIR/hash_${hash_mode}.py"
else
	echo "$password"
fi
