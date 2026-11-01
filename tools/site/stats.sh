#!/bin/sh
# Regenerate docs/stats.json: NanoC source vs the C it expands to, measured on the compiler itself.
# Counts non-blank lines and bytes. Usage: sh tools/site/stats.sh [path/to/nanoc]
set -eu
cd "$(dirname "$0")/../.."
nanoc=${1:-build/nanoc}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
find src -name '*.nc' | sort | while read -r f; do
    out="$tmp/c.c"
    "$nanoc" "$f" -o "$out" >/dev/null 2>&1 || { echo "stats: $f failed" >&2; exit 1; }
    printf '%s %s %s %s %s\n' "$f" "$(grep -c . "$f")" "$(wc -c <"$f")" \
        "$(grep -c . "$out")" "$(wc -c <"$out")"
done > "$tmp/rows"
awk -v today="$(date -u +%Y-%m-%d)" '
  { split($1, p, "/"); dir = (p[2] == "" ? "src" : p[2])
    n++; nl += $2; nb += $3; cl += $4; cb += $5
    dl[dir] += $2; db[dir] += $3; cdl[dir] += $4; cdb[dir] += $5; dn[dir]++ }
  END {
    printf "{\n  \"generated\": \"%s\",\n", today
    printf "  \"files\": %d,\n", n
    printf "  \"nc\": {\"lines\": %d, \"bytes\": %d},\n", nl, nb
    printf "  \"c\": {\"lines\": %d, \"bytes\": %d},\n", cl, cb
    printf "  \"areas\": [\n"
    k = 0; for (d in dl) keys[++k] = d
    for (i = 1; i <= k; i++) { d = keys[i]
      printf "    {\"name\": \"%s\", \"files\": %d, \"nc\": %d, \"c\": %d}%s\n", d, dn[d], dl[d], cdl[d], (i < k ? "," : "") }
    printf "  ]\n}\n"
  }' "$tmp/rows" > docs/stats.json
cat docs/stats.json
