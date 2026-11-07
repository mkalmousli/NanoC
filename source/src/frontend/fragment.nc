// Template-produced runtime blocks use the same v1 word grammar as source functions.
@lang 1
+ "nanoc/nanoc.h"

// Recognizes a control header with an indented body, leaving already-generated C tokens alone.
f nc_runtime_start(NcContext *c, NcTokens ts, size_t at) bool
  if !nc_bol(ts, at)
    < 0
  NcToken token = ts.v[at]
  if nc_is(token, "<")
    < 1
  if nc_is(token, "!") || nc_is(token, "^")
    size_t next = at + 1
    while next < ts.n && ts.v[next].kind == NC_SPACE && ts.v[next].line == token.line && !memchr(ts.v[next].s, '\n', ts.v[next].n)
      ++next
    < next == ts.n || ts.v[next].line > token.line || (ts.v[next].kind == NC_SPACE && memchr(ts.v[next].s, '\n', ts.v[next].n)) || nc_is(ts.v[next], ";")
  if token.kind != NC_WORD
    < 0
  if !nc_is(token, "if") && !nc_is(token, "elif") && !nc_is(token, "else") && !nc_is(token, "while") && !nc_is(token, "for")
    < 0
  NcCursor peek = {c, ts, at}
  NcLayoutLine line = nc_logical_line(&peek)
  if nc_end(&peek)
    < 0
  < peek.ts.v[peek.pos].column - 1 > line.indent

// Lowers one generated control chain, preserving its enclosing transformation event.
f nc_runtime_scope(NcContext *c, NcCursor *cur) char *
  NcLines lines = {0}
  NcLayoutLine head = nc_logical_line(cur)
  NcTokens sig = nc_significant(c, head.ts)
  if sig.n && (nc_is(sig.v[0], "<") || nc_is(sig.v[0], "!") || nc_is(sig.v[0], "^"))
    < nc_statement(c, head)
  int indent = head.indent
  bool conditional = nc_is(nc_significant(c, head.ts).v[0], "if")
  for ;;
    NC_PUSH(c, lines, head)
    NcLines body = nc_body_lines(cur, head.line, indent)
    for size_t i = 0; i < body.n; ++i
      NC_PUSH(c, lines, body.v[i])
    if !conditional
      !
    NcCursor peek = *cur
    if nc_end(&peek)
      !
    NcLayoutLine next = nc_logical_line(&peek)
    NcTokens sig = nc_significant(c, next.ts)
    if !sig.n || next.indent != indent || (!nc_is(sig.v[0], "elif") && !nc_is(sig.v[0], "else"))
      !
    *cur = peek
    head = next
  lines = nc_prepare_lines(c, lines, 0)
  size_t at = 0
  NcNodes nodes = nc_tree(c, lines, &at, indent, 0)
  if at != lines.n
    nc_fail(c, lines.v[at].line, "inconsistent indentation")
  < nc_emit_block(c, nodes, 0)
