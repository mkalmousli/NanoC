// Token cursor helpers for the parsers.
@lang 1
+ "nanoc/nanoc.h"

// Skips whitespace tokens.
f nc_skip(NcCursor *c)
  while c->pos < c->ts.n && c->ts.v[c->pos].kind == NC_SPACE
    ++c->pos

// Tells if the cursor is at the end.
f nc_end(NcCursor *c) bool
  nc_skip(c)
  < c->pos == c->ts.n

// Tells if the next token matches.
f nc_at(NcCursor *c, const char *s) bool
  nc_skip(c)
  < c->pos < c->ts.n && nc_is(c->ts.v[c->pos], s)

// Gets the current source line.
f nc_line(const NcCursor *c) int
  if c->pos < c->ts.n
    < c->ts.v[c->pos].line
  < c->ts.n ? c->ts.v[c->ts.n - 1].line : 1

// Takes the next token.
f nc_take(NcCursor *c) NcToken
  if nc_end(c)
    nc_fail(c->ctx, nc_line(c), "unexpected end of input")
  NcToken token = c->ts.v[c->pos++]
  c->ctx->last_token = token
  < token

// Consumes a token if it matches.
f nc_eat(NcCursor *c, const char *s) bool
  if !nc_at(c, s)
    < 0
  ++c->pos
  < 1

// Consumes a token or fails.
f nc_need(NcCursor *c, const char *s)
  NcToken t = nc_take(c)
  if !nc_is(t, s)
    nc_fail(c->ctx, t.line, "expected '%s', got '%.*s'", s, (int)t.n, t.s)

// Consumes an identifier.
f nc_name(NcCursor *c) char *
  NcToken t = nc_take(c)
  if t.kind != NC_WORD
    nc_fail(c->ctx, t.line, "expected identifier")
  < nc_text(c->ctx, t)
