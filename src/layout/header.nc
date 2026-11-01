// Statement header lookahead.
@use "nanoc/nanoc"
// Finds the statement header.
@f nc_header(const NcCursor *c) NcHeader
  usize i = c->pos ? c->pos - 1 : 0
  while i && !nc_is(c->ts.v[i], "@") then --i
  (NcHeader){c->ts.v[i].line, c->ts.v[i].column - 1}
// Tells if a token is on the line.
@f nc_same_line(const NcCursor *c, int line) bool
  usize i = c->pos
  while i < c->ts.n and c->ts.v[i].kind == NC_SPACE
    ++i
  i < c->ts.n and c->ts.v[i].line == line
// Tells if the header has s.
@f nc_header_at(const NcCursor *c, cstr s, int line) bool
  usize i = c->pos
  while i < c->ts.n and c->ts.v[i].kind == NC_SPACE
    ++i
  i < c->ts.n and c->ts.v[i].line == line and nc_is(c->ts.v[i], s)
// Consumes s from the header.
@f nc_header_eat(NcCursor *c, cstr s, int line) bool
  if !nc_header_at(c, s, line) then return false
  nc_need(c, s)
  true
// Reads the rest of the line.
@f nc_line_expression(NcCursor *c) NcTokens
  NcTokens ts = {0}
  nc_skip(c)
  while c->pos < c->ts.n
    NcToken t = c->ts.v[c->pos]
    if t.kind == NC_SPACE && memchr(t.s, '\n', t.n) then break
    if t.kind == NC_PUNCT && nc_is(t, ";")
      ++c->pos
      break
    if t.kind == NC_PUNCT && (nc_is(t, "(") || nc_is(t, "[") || nc_is(t, "{"))
      usize start = c->pos
      (void)nc_group(c, nc_text(c->ctx, t), nc_is(t, "(") ? ")" : nc_is(t, "[") ? "]" : "}")
      for i:usize in start..c->pos then NC_PUSH(c->ctx, ts, c->ts.v[i])
    else
      NC_PUSH(c->ctx, ts, t)
      ++c->pos
  while ts.n and ts.v[ts.n - 1].kind == NC_SPACE then --ts.n
  if not ts.n then nc_fail(c->ctx, nc_line(c), "missing expression")
  ts
// Builds nodes from indented lines.
@f nc_indented_nodes(NcCursor *c, NcHeader header, bool program) NcNodes
  NcLines lines = nc_prepare_lines(c->ctx, nc_body_lines(c, header.line, header.indent), program)
  usize i = 0
  NcNodes nodes = nc_tree(c->ctx, lines, &i, lines.v[0].indent, 0)
  if i != lines.n then nc_fail(c->ctx, lines.v[i].line, "inconsistent indentation")
  nodes
