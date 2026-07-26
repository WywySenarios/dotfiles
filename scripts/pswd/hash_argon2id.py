#!/usr/bin/env python3
"""
Hash / verify a password with argon2id for htpasswd auth.

Usage:
  echo 'mypassword' | ./hash_argon2id.py                   # encrypt
  echo 'mypassword' | ./hash_argon2id.py --decrypt --hash '...'  # verify

Encrypt output:  user:<argon2id-hash>
Decrypt exit:    0 = match, 1 = mismatch
"""

import argparse
import sys


def _load_argon2():
    try:
        from argon2 import PasswordHasher, Type as Argon2Type
        return PasswordHasher, Argon2Type
    except ImportError:
        print("error: 'argon2-cffi' package not installed", file=sys.stderr)
        print("  pip install argon2-cffi", file=sys.stderr)
        sys.exit(1)


def encrypt(password: str,
            time_cost: int = 3,
            memory_cost: int = 65536,
            parallelism: int = 4,
            hash_len: int = 32) -> str:
    PasswordHasher, Argon2Type = _load_argon2()
    ph = PasswordHasher(
        time_cost=time_cost,
        memory_cost=memory_cost,
        parallelism=parallelism,
        hash_len=hash_len,
        type=Argon2Type.ID,
    )
    return ph.hash(password)


def verify(password: str, expected: str) -> bool:
    PasswordHasher, Argon2Type = _load_argon2()
    ph = PasswordHasher()
    try:
        return ph.verify(expected, password)
    except Exception:
        return False


def htpasswd_line(user: str, hash_str: str) -> str:
    return f"{user}:{hash_str}"


def main():
    parser = argparse.ArgumentParser(description="argon2id htpasswd tool")
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
