#include "nanoc/layout.h"
@f nc_header(const NcCursor *c) NcHeader
  size_t i = c->pos ? c->pos - 1 : 0
  while i && !nc_is(c->ts.v[i], "@")
    --i
  (NcHeader){c->ts.v[i].line, c->ts.v[i].column - 1}
@f nc_same_line(const NcCursor *c, int line) bool
  size_t i = c->pos
  while i < c->ts.n && c->ts.v[i].kind == NC_SPACE
    ++i
  i < c->ts.n && c->ts.v[i].line == line
@f nc_header_at(const NcCursor *c, const char *s, int line) bool
  size_t i = c->pos
  while i < c->ts.n && c->ts.v[i].kind == NC_SPACE
    ++i
  i < c->ts.n && c->ts.v[i].line == line && nc_is(c->ts.v[i], s)
@f nc_header_eat(NcCursor *c, const char *s, int line) bool
  if !nc_header_at(c, s, line)
    return false
  nc_need(c, s)
  true
@f nc_line_expression(NcCursor *c) NcTokens
  NcTokens ts = {0}
  nc_skip(c)
  while c->pos < c->ts.n
    NcToken t = c->ts.v[c->pos]
    if t.kind == NC_SPACE && memchr(t.s, '\n', t.n)
      break
    if t.kind == NC_PUNCT && nc_is(t, ";")
      ++c->pos
      break
    if t.kind == NC_PUNCT && (nc_is(t, "(") || nc_is(t, "[") || nc_is(t, "{"))
      size_t start = c->pos
      (void)nc_group(c, nc_text(c->ctx, t), nc_is(t, "(") ? ")" : nc_is(t, "[") ? "]" : "}")
      for size_t i = start; i < c->pos; ++i
        NC_PUSH(c->ctx, ts, c->ts.v[i])
    else
      NC_PUSH(c->ctx, ts, t)
      ++c->pos
  while ts.n && ts.v[ts.n - 1].kind == NC_SPACE
    --ts.n
  if !ts.n
    nc_fail(c->ctx, nc_line(c), "missing expression")
  ts
@f nc_indented_nodes(NcCursor *c, NcHeader header, bool program) NcNodes
  NcLines lines = nc_prepare_lines(c->ctx, nc_body_lines(c, header.line, header.indent), program)
  size_t i = 0
  NcNodes nodes = nc_tree(c->ctx, lines, &i, lines.v[0].indent, 0)
  if i != lines.n
    nc_fail(c->ctx, lines.v[i].line, "inconsistent indentation")
  nodes
