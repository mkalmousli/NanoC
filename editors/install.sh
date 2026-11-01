#!/bin/sh
# Install or remove NanoC syntax highlighting for an editor.
#   sh editors/install.sh NAME [--uninstall]     NAME: see `sh editors/install.sh list`
set -eu
here=$(cd "$(dirname "$0")" && pwd)
cfg=${XDG_CONFIG_HOME:-$HOME/.config}
name=${1:-list}
mode=${2:-install}

put() { mkdir -p "$(dirname "$2")" && cp "$1" "$2" && echo "  + $2"; }
drop() { if [ -e "$1" ]; then rm -rf "$1" && echo "  - $1"; fi; }

vscode_dirs() {
    for d in "$HOME/.vscode" "$HOME/.vscode-oss" "$HOME/.cursor"; do
        [ -d "$d" ] && echo "$d/extensions/mkalmousli.nanoc-language-0.1.0"
    done
}

sublime_dir() {
    case "$(uname -s)" in
        Darwin) echo "$HOME/Library/Application Support/Sublime Text/Packages/User" ;;
        *) echo "$HOME/.config/sublime-text/Packages/User" ;;
    esac
}

emacs_dir() {
    if [ -d "$HOME/.emacs.d" ]; then echo "$HOME/.emacs.d/lisp"; else echo "$cfg/emacs/lisp"; fi
}

# Each editor: a list of "source:destination" pairs (destinations are computed here).
run() {
    case "$name" in
        list)
            echo "vscode   VS Code, VSCodium, Cursor (extension folder copy)"
            echo "vim      Vim (syntax + ftdetect)"
            echo "neovim   Neovim (syntax + ftdetect)"
            echo "emacs    GNU Emacs (nanoc-mode)"
            echo "micro    micro editor (syntax yaml)"
            echo "nano     GNU nano (nanorc)"
            echo "sublime  Sublime Text 4 (sublime-syntax)"
            return 0 ;;
        vscode)
            for d in $(vscode_dirs); do
                if [ "$mode" = --uninstall ]; then drop "$d"; else
                    mkdir -p "$d" && cp -R "$here/vscode/." "$d/" && echo "  + $d"
                fi
            done ;;
        vim)
            f=$HOME/.vim
            if [ "$mode" = --uninstall ]; then drop "$f/syntax/nanoc.vim"; drop "$f/ftdetect/nanoc.vim"; else
                put "$here/vim/nanoc.vim" "$f/syntax/nanoc.vim"
                put "$here/vim/ftdetect/nanoc.vim" "$f/ftdetect/nanoc.vim"
            fi ;;
        neovim)
            f=$cfg/nvim
            if [ "$mode" = --uninstall ]; then drop "$f/syntax/nanoc.vim"; drop "$f/ftdetect/nanoc.vim"; else
                put "$here/vim/nanoc.vim" "$f/syntax/nanoc.vim"
                put "$here/vim/ftdetect/nanoc.vim" "$f/ftdetect/nanoc.vim"
            fi ;;
        emacs)
            f=$(emacs_dir)/nanoc-mode.el
            if [ "$mode" = --uninstall ]; then drop "$f"; else
                put "$here/emacs/nanoc-mode.el" "$f"
                echo "Add to your init file:"
                echo "  (add-to-list 'load-path \"$(dirname "$f")\") (require 'nanoc-mode)"
            fi ;;
        micro)
            f=$cfg/micro/syntax/nanoc.yaml
            if [ "$mode" = --uninstall ]; then drop "$f"; else put "$here/micro/nanoc.yaml" "$f"; fi ;;
        nano)
            f=$HOME/.nano/nanoc.nanorc
            if [ "$mode" = --uninstall ]; then drop "$f"; else
                put "$here/nano/nanoc.nanorc" "$f"
                echo "Add this line to ~/.nanorc:"
                echo "  include \"$f\""
            fi ;;
        sublime)
            f=$(sublime_dir)/NanoC.sublime-syntax
            if [ "$mode" = --uninstall ]; then drop "$f"; else put "$here/sublime/NanoC.sublime-syntax" "$f"; fi ;;
        *) echo "unknown editor: $name (try: sh editors/install.sh list)" >&2; return 1 ;;
    esac
    [ "$name" = list ] || echo "Done: $name ($mode)."
}
run
