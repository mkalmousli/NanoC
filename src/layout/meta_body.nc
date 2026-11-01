// Bodies of @bt, @ct and @m blocks.
#include "nanoc/nanoc.h"
// Reads a @bt or @ct body.
@f nc_meta_body(NcCursor *c, NcHeader header, bool program, bool tail) NcTokens
  usize next = c->pos
  while next < c->ts.n && c->ts.v[next].kind == NC_SPACE
    ++next
  if next < c->ts.n && nc_is(c->ts.v[next], "{")
    return nc_group(c, "{", "}")
  (void)nc_header_eat(c, ":", header.line)
  if !program
    usize start = c->pos
    (void)nc_body_lines(c, header.line, header.indent)
    return nc_slice(c->ts, start, c->pos)
  NcNodes nodes = nc_indented_nodes(c, header, true)
  nc_lex(c->ctx, nc_emit_program(c->ctx, nodes, tail, 0), nodes.v[0].head.line)
// Reads a @m body.
@f nc_macro_body(NcCursor *c, NcHeader header, bool *program) NcTokens
  header.line = c->pos ? c->ts.v[c->pos - 1].line : header.line
  bool old = nc_header_eat(c, "=>", header.line)
  *program = old || nc_header_eat(c, "=", header.line)
  if *program && !nc_header_at(c, "{", header.line) && nc_same_line(c, header.line)
    NcTokens expr = old ? nc_until(c, ";") : nc_line_expression(c)
    if old
      nc_need(c, ";")
    return nc_lex(c->ctx, nc_format(c->ctx, "return %s;", nc_join(c->ctx, expr)), header.line)
  nc_meta_body(c, header, *program, true)
