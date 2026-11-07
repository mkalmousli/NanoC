// Statement header lookahead.
@lang 1
+ "nanoc/nanoc.h"

// Finds the statement header.
f nc_header(const NcCursor *c) -> NcHeader
  size_t i = c->pos ? c->pos - 1 : 0
  if (i && nc_is(c->ts.v[i - 1], "@"))
    --i
  return (NcHeader){c->ts.v[i].line, c->ts.v[i].column - 1}

// Tells if a token is on the line.
f nc_same_line(const NcCursor *c, int line) -> bool
  size_t i = c->pos
  while (i < c->ts.n && c->ts.v[i].kind == NC_SPACE)
    ++i
  return i < c->ts.n && c->ts.v[i].line == line

// Tells if the header has s.
f nc_header_at(const NcCursor *c, const char *s, int line) -> bool
  size_t i = c->pos
  while (i < c->ts.n && c->ts.v[i].kind == NC_SPACE)
    ++i
  return i < c->ts.n && c->ts.v[i].line == line && nc_is(c->ts.v[i], s)

// Consumes s from the header.
f nc_header_eat(NcCursor *c, const char *s, int line) -> bool
  if (!nc_header_at(c, s, line))
    return 0
  nc_need(c, s)
  return 1

// Reads the rest of the line.
f nc_line_expression(NcCursor *c) -> NcTokens
  NcTokens ts = {0}
  nc_skip(c)
  while (c->pos < c->ts.n)
    NcToken t = c->ts.v[c->pos]
    if (t.kind == NC_SPACE && memchr(t.s, '\n', t.n))
      break
    if (t.kind == NC_PUNCT && nc_is(t, ";"))
      ++c->pos; break
    if (t.kind == NC_PUNCT && (nc_is(t, "(") || nc_is(t, "[") || nc_is(t, "{")))
      size_t start = c->pos
      (void)nc_group(c, nc_text(c->ctx, t), nc_is(t, "(") ? ")" : nc_is(t, "[") ? "]" : "}")
      for (size_t i = (start), nanoc_bound_1 = (c->pos); i < nanoc_bound_1; ++i)
        NC_PUSH(c->ctx, ts, c->ts.v[i])
    else
      NC_PUSH(c->ctx, ts, t); ++c->pos
  while (ts.n && ts.v[ts.n - 1].kind == NC_SPACE)
    --ts.n
  if (! ts.n)
    nc_fail(c->ctx, nc_line(c), "missing expression")
  return ts

// Builds nodes from indented lines.
f nc_indented_nodes(NcCursor *c, NcHeader header, bool program) -> NcNodes
  NcLines lines = nc_prepare_lines(c->ctx, nc_body_lines(c, header.line, header.indent), program)
  size_t i = 0
  NcNodes nodes = nc_tree(c->ctx, lines, &i, lines.v[0].indent, 0)
  if (i != lines.n)
    nc_fail(c->ctx, lines.v[i].line, "inconsistent indentation")
  return nodes
