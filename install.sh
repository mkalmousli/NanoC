#!/bin/sh
# NanoC installer: install, update, uninstall. Works on any POSIX host with a C11 compiler.
#
#   curl -fsSL https://raw.githubusercontent.com/mkalmousli/NanoC/main/install.sh | sh
#   sh install.sh [install|update|uninstall] [--prefix DIR] [--no-editors] [--yes]
#
# After install, manage NanoC with the compiler itself:
#   nanoc editor list | install [NAME|--all] | remove NAME|--all
#   nanoc update
#   nanoc uninstall [--yes]
set -eu

REPO_URL="https://github.com/mkalmousli/NanoC.git"
ARCHIVE_URL="https://github.com/mkalmousli/NanoC/archive/refs/heads/main.tar.gz"

action=install
case "${1:-}" in
    install|update|uninstall) action=$1; shift ;;
    -h|--help) sed -n '2,11p' "$0" 2>/dev/null; exit 0 ;;
esac
prefix="${HOME:-/tmp}/.local"
editors=1
yes=""
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) [ $# -ge 2 ] || { echo "--prefix needs a directory" >&2; exit 2; }; prefix=$2; shift ;;
        --no-editors) editors=0 ;;
        --yes|-y) yes="--yes" ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
    shift
done

# ---- output -----------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    B='\033[1m'; D='\033[2m'; G='\033[32m'; R='\033[31m'; Y='\033[33m'; C='\033[36m'; N='\033[0m'
    TTY=1
else
    B=''; D=''; G=''; R=''; Y=''; C=''; N=''; TTY=0
fi
TOTAL=2
STEP=0
bar() {
    filled=$(( STEP * 20 / TOTAL )); out=""; i=0
    while [ $i -lt 20 ]; do
        if [ $i -lt $filled ]; then out="$out█"; else out="$out░"; fi
        i=$(( i + 1 ))
    done
    printf '%s' "$out"
}
header() {
    printf '\n%b  NanoC installer%b  %b%s%b\n' "$B" "$N" "$D" "$action" "$N"
    printf '%b  %s%b\n\n' "$D" "$prefix" "$N"
}
ok() { printf '  %b✓%b %s\n' "$G" "$N" "$*"; }
warn() { printf '  %b!%b %s\n' "$Y" "$N" "$*"; }
die() { printf '  %b✗%b %s\n' "$R" "$N" "$*" >&2; exit 1; }
spin_char() {
    case $(( $1 % 4 )) in 0) echo '|';; 1) echo '/';; 2) echo '-';; *) echo '\\';; esac
}
# step "label" command...: runs command with a spinner; shows its log on failure.
step() {
    STEP=$(( STEP + 1 ))
    label=$1; shift
    log=$(mktemp "${TMPDIR:-/tmp}/nanoc-log.XXXXXX")
    "$@" >"$log" 2>&1 &
    pid=$!
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        if [ "$TTY" = 1 ]; then
            printf '\r  %b%s%b [%s] %s %s' "$C" "$(spin_char $i)" "$N" "$(bar)" "$label" "$D…$N"
        fi
        i=$(( i + 1 )); sleep 0.1
    done
    if wait "$pid"; then
        [ "$TTY" = 1 ] && printf '\r\033[K'
        printf '  %b✓%b [%s] %s\n' "$G" "$N" "$(bar)" "$label"
        rm -f "$log"
    else
        [ "$TTY" = 1 ] && printf '\r\033[K'
        printf '  %b✗%b [%s] %s\n' "$R" "$N" "$(bar)" "$label" >&2
        sed 's/^/    /' "$log" >&2
        rm -f "$log"
        exit 1
    fi
}

# ---- source -----------------------------------------------------------------
fetch_source() {
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 -q "$REPO_URL" "$1/NanoC"
    else
        curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$1" && mv "$1"/NanoC-* "$1/NanoC"
    fi
}
here=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || here=""
tmp=""
cleanup() { [ -n "$tmp" ] && rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

header
if [ "$action" = uninstall ]; then
    nanoc="$prefix/bin/nanoc"
    [ -x "$nanoc" ] || die "no NanoC found at $prefix"
    exec "$nanoc" uninstall $yes
fi

if [ -n "$here" ] && [ -f "$here/build.c" ] && [ "$action" = install ]; then
    src=$here
else
    command -v git >/dev/null 2>&1 || command -v curl >/dev/null 2>&1 || die "need git or curl"
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/nanoc.XXXXXX")
    TOTAL=$(( TOTAL + 1 ))
    step "Fetching the latest NanoC" fetch_source "$tmp"
    src="$tmp/NanoC"
fi
cd "$src"

# ---- toolchain --------------------------------------------------------------
if [ -z "${CC:-}" ]; then
    for c in cc gcc clang; do
        if command -v "$c" >/dev/null 2>&1; then CC=$c; break; fi
    done
fi
[ -n "${CC:-}" ] || die "no C compiler found (install gcc or clang, or set CC)"
export CC
ok "C compiler: $("$CC" --version 2>/dev/null | head -n 1)"

# ---- build and install ------------------------------------------------------
[ "$editors" = 1 ] && TOTAL=$(( TOTAL + 1 ))
step "Building the compiler" sh -c '"$CC" -std=c11 -O2 build.c -o builder && ./builder build'
step "Installing to $prefix" ./builder install --prefix "$prefix"
if [ "$editors" = 1 ]; then
    step "Setting up detected editors" "$prefix/bin/nanoc" editor install
fi

version=$("$prefix/bin/nanoc" --version 2>/dev/null || echo nanoc)
printf '\n  %b%s installed.%b\n' "$B" "$version" "$N"
case ":$PATH:" in
    *":$prefix/bin:"*) ;;
    *) warn "add $prefix/bin to your PATH:  export PATH=\"$prefix/bin:\$PATH\"" ;;
esac
printf '  %bTry:%b nanoc --help   %b·%b  nanoc editor list   %b·%b  nanoc update\n\n' "$C" "$N" "$D" "$N" "$D" "$N"
