#!/bin/sh
# Regenerate docs/files.json, the file index the website's source explorer reads.
set -eu
cd "$(dirname "$0")/../.."
{
    printf '['
    git ls-files | grep -E '\.(nc|c|h|cc|cpp|md|vim|el|yaml|nanorc|sublime-syntax|json|sh|js|html|css|svg)$' |
        grep -v '^tests/corpus/' | grep -v '^docs/files.json$' |
        sed 's/.*/"&"/' | paste -sd, -
    printf ']\n'
} > docs/files.json
