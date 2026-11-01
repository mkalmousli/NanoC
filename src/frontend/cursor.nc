#include "nanoc/nanoc.h"
@f nc_skip(NcCursor *c) void
  while (c->pos < c->ts.n
    && c->ts.v[c->pos].kind
    == NC_SPACE)
    ++c->pos
@f nc_end(NcCursor *c) bool
  nc_skip(c)
  c->pos == c->ts.n
@f nc_at(
  NcCursor *c, const char *s
) bool
  nc_skip(c)
  c->pos < c->ts.n && nc_is(
    c->ts.v[c->pos], s)
@f nc_line(
  const NcCursor *c
) int
  if c->pos < c->ts.n
    return c->ts.v[
      c->pos].line
  c->ts.n ? c->ts.v[
    c->ts.n - 1].line : 1
@f nc_take(
  NcCursor *c
) NcToken
  if nc_end(c)
    nc_fail(c->ctx,
      nc_line(c),
      "unexpected end of "
      "input")
  c->ts.v[c->pos++]
@f nc_eat(
  NcCursor *c, const char *s
) bool
  if !nc_at(c, s)
    return false
  ++c->pos
  true
@f nc_need(
  NcCursor *c, const char *s
) void
  NcToken t = nc_take(c)
  if !nc_is(t, s)
    nc_fail(c->ctx, t.line,
      "expected '%s', got "
      "'%.*s'", s, (int)t.n,
      t.s)
@f nc_name(NcCursor *c) char *
  NcToken t = nc_take(c)
  if t.kind != NC_WORD
    nc_fail(c->ctx, t.line,
      "expected identifier")
  nc_text(c->ctx, t)
