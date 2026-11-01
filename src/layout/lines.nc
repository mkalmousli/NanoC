// Splits tokens into logical lines.
#include "nanoc/nanoc.h"
// Reads one logical line.
@f nc_logical_line(NcCursor *c) NcLayoutLine
  size_t whitespace = c->pos
  nc_skip(c)
  if c->pos == c->ts.n
    nc_fail(c->ctx, nc_line(c), "expected a logical line")
  NcLayoutLine out = {.indent = c->ts.v[c->pos].column - 1,
    .line = nc_line(c)}
  for size_t i = whitespace; i < c->pos; ++i
    NcToken t = c->ts.v[i]
    size_t tail = t.n
    while tail && t.s[tail - 1] != '\n'
      --tail
    if memchr(t.s + tail, '\t', t.n - tail)
      nc_fail(c->ctx, out.line,
        "use spaces for indentation")
  NcStrings stack = {0}
  while c->pos < c->ts.n
    NcToken t = c->ts.v[c->pos]
    if (!stack.n && t.kind == NC_SPACE
      && memchr(t.s, '\n', t.n))
      break
    if !stack.n && t.kind == NC_DIRECTIVE
      if out.ts.n
        nc_fail(c->ctx, t.line,
          "directive must start its own line")
      NC_PUSH(c->ctx, out.ts, t)
      ++c->pos
      break
    ++c->pos
    NC_PUSH(c->ctx, out.ts, t)
    if t.kind != NC_PUNCT
      continue
    const char *end = (nc_is(t, "(") ? ")" : nc_is(t, "[")
      ? "]" : nc_is(t, "{") ? "}" : NULL)
    if end
      NC_PUSH(c->ctx, stack, (char *)end)
    elif nc_is(t, ")") || nc_is(t, "]") || nc_is(t, "}")
      if !stack.n || !nc_is(t, stack.v[stack.n - 1])
        nc_fail(c->ctx, t.line, "mismatched delimiter")
      --stack.n
  if stack.n
    nc_fail(c->ctx, out.line, "unterminated logical line")
  out
// Reads an indented body.
@f nc_body_lines(
  NcCursor *c, int header_line, int indent
) NcLines
  NcLines out = {0}
  for ;;
    size_t next = c->pos
    while next < c->ts.n && c->ts.v[next].kind == NC_SPACE
      ++next
    if next == c->ts.n
      break
    NcToken t = c->ts.v[next]
    if t.line <= header_line
      nc_fail(c->ctx, t.line,
        "expected an indented function body")
    if t.column - 1 <= indent
      break
    NC_PUSH(c->ctx, out, nc_logical_line(c))
  if !out.n
    nc_fail(c->ctx, header_line,
      "expected an indented function body")
  out
