// Splits tokens into logical lines.
// Reads one logical line.
@f nc_logical_line(NcCursor *c) NcLayoutLine
  usize whitespace = c->pos
  nc_skip(c)
  if c->pos == c->ts.n then nc_fail(c->ctx, nc_line(c), "expected a logical line")
  NcLayoutLine out = {.indent = c->ts.v[c->pos].column - 1, .line = nc_line(c)}
  for i:usize in whitespace..c->pos
    NcToken t = c->ts.v[i]
    usize tail = t.n
    while tail && t.s[tail - 1] != '\n' then --tail
    if memchr(t.s + tail, '\t', t.n - tail) then nc_fail(c->ctx, out.line, "use spaces for indentation")
  NcStrings stack = {0}
  while c->pos < c->ts.n
    NcToken t = c->ts.v[c->pos]
    if !stack.n && t.kind == NC_SPACE && memchr(t.s, '\n', t.n) then break
    if !stack.n and t.kind == NC_DIRECTIVE
      if out.ts.n then nc_fail(c->ctx, t.line, "directive must start its own line")
      NC_PUSH(c->ctx, out.ts, t)
      ++c->pos
      break
    ++c->pos
    NC_PUSH(c->ctx, out.ts, t)
    if t.kind != NC_PUNCT then continue
    const char *end = nc_is(t, "(") ? ")" : nc_is(t, "[") ? "]" : nc_is(t, "{") ? "}" : NULL
    if end then NC_PUSH(c->ctx, stack, (char *)end)
    elif nc_is(t, ")") || nc_is(t, "]") || nc_is(t, "}")
      if !stack.n or !nc_is(t, stack.v[stack.n - 1]) then nc_fail(c->ctx, t.line, "mismatched delimiter")
      --stack.n
  if stack.n then nc_fail(c->ctx, out.line, "unterminated logical line")
  out
// Reads an indented body.
@f nc_body_lines(NcCursor *c, int header_line, int indent) NcLines
  NcLines out = {0}
  for ;;
    usize next = c->pos
    while next < c->ts.n and c->ts.v[next].kind == NC_SPACE
      ++next
    if next == c->ts.n then break
    NcToken t = c->ts.v[next]
    if t.line <= header_line then nc_fail(c->ctx, t.line, "expected an indented function body")
    if t.column - 1 <= indent then break
    NC_PUSH(c->ctx, out, nc_logical_line(c))
  if not out.n then nc_fail(c->ctx, header_line, "expected an indented function body")
  out
