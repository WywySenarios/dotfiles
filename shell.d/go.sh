# Go toolchain (Linux tarball install path).
# Homebrew's Go (/opt/homebrew/bin) is already on PATH via `brew shellenv`.
if [ -d /usr/local/go/bin ]; then
    export PATH="$PATH:/usr/local/go/bin"
fi
