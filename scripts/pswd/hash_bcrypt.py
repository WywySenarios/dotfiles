#!/usr/bin/env python3
"""
Hash / verify a password with bcrypt for htpasswd auth.

Usage:
  echo 'mypassword' | ./hash_bcrypt.py                     # encrypt
  echo 'mypassword' | ./hash_bcrypt.py --decrypt --hash '...'  # verify

Encrypt output:  user:<bcrypt-hash>
Decrypt exit:    0 = match, 1 = mismatch
"""

import argparse
import sys


def _load_bcrypt():
    try:
        import bcrypt as _bcrypt
        return _bcrypt
    except ImportError:
        print("error: 'bcrypt' package not installed", file=sys.stderr)
        print("  pip install bcrypt", file=sys.stderr)
        sys.exit(1)


def encrypt(password: str, rounds: int = 10) -> str:
    bcrypt = _load_bcrypt()
    salt = bcrypt.gensalt(rounds=rounds)
    return bcrypt.hashpw(password.encode(), salt).decode()


def verify(password: str, expected: str) -> bool:
    bcrypt = _load_bcrypt()
    try:
        return bcrypt.checkpw(password.encode(), expected.encode())
    except ValueError:
        return False


def htpasswd_line(user: str, hash_str: str) -> str:
    return f"{user}:{hash_str}"


def main():
    parser = argparse.ArgumentParser(description="bcrypt htpasswd tool")
    parser.add_argument("--user", default="admin", help="username (default: admin)")

    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--encrypt", action="store_true", help="hash password (default)")
    mode.add_argument("--decrypt", action="store_true", help="verify password against hash")
    parser.add_argument("--hash", help="hash to verify against (for --decrypt)")

    args = parser.parse_args()

    if args.decrypt:
        if not args.hash:
            parser.error("--decrypt requires --hash <hash>")
        if sys.stdin.isatty():
            parser.error("pipe a password to stdin")
        password = sys.stdin.read().strip()
        if not password:
            parser.error("password cannot be empty")
        hash_str = args.hash.split(":", 1)[-1] if ":" in args.hash else args.hash
        if verify(password, hash_str):
            print("OK")
            sys.exit(0)
        else:
            print("MISMATCH")
            sys.exit(1)

    # Encrypt mode (default)
    if sys.stdin.isatty():
        parser.error("pipe a password to stdin")
    password = sys.stdin.read().strip()
    if not password:
        parser.error("password cannot be empty")

    print(htpasswd_line(args.user, encrypt(password)))


if __name__ == "__main__":
    main()
