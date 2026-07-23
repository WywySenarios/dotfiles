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
case "${1:-help}" in
alnum)
	gen_alnum "${2:-}"
	;;
num)
	gen_num "${2:-}"
	;;
secure)
	gen_secure "${2:-}"
	;;
common)
	gen_common "${2:-}"
	;;
*)
	echo "Usage: pswd.sh <mode> [length]" >&2
	echo "" >&2
	echo "Modes:" >&2
	echo "  alnum    alphanumeric (a-zA-Z0-9)" >&2
	echo "  num      digits only (0-9)" >&2
	echo "  secure   alphanumeric + all punctuation" >&2
	echo "  common   alphanumeric + safe symbols only" >&2
	exit 1
	;;
esac
