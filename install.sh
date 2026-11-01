#!/bin/sh
# NanoC installer for any POSIX host with a C11 compiler.
#
#   curl -fsSL https://raw.githubusercontent.com/mkalmousli/NanoC/main/install.sh | sh
#   sh install.sh install   [--prefix DIR]      build and install nanoc (default ~/.local)
#   sh install.sh uninstall [--prefix DIR]      remove exactly the files NanoC installed
#   sh install.sh editor NAME [--uninstall]     editor syntax support (see: sh install.sh editors)
#   sh install.sh editors                       list editor names
set -eu

REPO_URL="https://github.com/mkalmousli/NanoC.git"
ARCHIVE_URL="https://github.com/mkalmousli/NanoC/archive/refs/heads/main.tar.gz"

die() { printf 'nanoc install: %s\n' "$*" >&2; exit 1; }

action=${1:-install}
[ $# -gt 0 ] && shift
prefix=""
editor=""
extra=""
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) [ $# -ge 2 ] || die "--prefix needs a directory"; prefix=$2; shift ;;
        --uninstall) extra="--uninstall" ;;
        -h|--help) sed -n '2,9p' "$0" 2>/dev/null || true; exit 0 ;;
        *) [ -z "$editor" ] && [ "$action" = editor ] && editor=$1 || die "unknown argument: $1" ;;
    esac
    shift
done

# Locate a source checkout: this script's directory, or a fresh download.
here=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || here=""
if [ -z "$here" ] || [ ! -f "$here/build.c" ]; then
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/nanoc.XXXXXX") || die "cannot create temp directory"
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 -q "$REPO_URL" "$tmp/NanoC" || die "git clone failed"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$tmp" || die "download failed"
        mv "$tmp"/NanoC-* "$tmp/NanoC"
    else
        die "need git or curl"
    fi
    here="$tmp/NanoC"
fi
cd "$here"

case "$action" in
    editors)
        exec sh editors/install.sh list ;;
    editor)
        [ -n "$editor" ] || die "usage: install.sh editor NAME [--uninstall]"
        exec sh editors/install.sh "$editor" $extra ;;
    install|uninstall) ;;
    *) die "unknown action: $action (use install, uninstall, editor, editors)" ;;
esac

# Pick a C compiler: $CC, then the common names.
if [ -z "${CC:-}" ]; then
    for c in cc gcc clang; do
        if command -v "$c" >/dev/null 2>&1; then CC=$c; break; fi
    done
fi
[ -n "${CC:-}" ] || die "no C compiler found; install gcc or clang, or set CC"
export CC

"$CC" -std=c11 -O2 build.c -o builder || die "bootstrap build failed"
if [ -n "$prefix" ]; then
    ./builder "$action" --prefix "$prefix"
else
    ./builder "$action"
fi

if [ "$action" = install ]; then
    bin=${prefix:-$HOME/.local}/bin
    case ":$PATH:" in
        *":$bin:"*) ;;
        *) printf 'Add %s to PATH to use nanoc.\n' "$bin" ;;
    esac
fi
