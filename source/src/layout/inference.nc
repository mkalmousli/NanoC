// Type inference for := declarations.
@lang 1
+ "nanoc/nanoc.h"

extern int nc_std;
+ <errno.h>

// Infers only simple literals using widths guaranteed by ISO C; arbitrary expressions need a type.
f nc_infer(NcContext *c, NcTokens ts, int line) char *
  NcTokens items = nc_significant(c, ts)
  size_t i = items.n > 1 && (nc_is(items.v[0], "+") || nc_is(items.v[0], "-")) ? 1 : 0
  if items.n == i + 1
    NcToken t = items.v[i]
    if t.kind == NC_LITERAL && t.n && t.s[0] == '"'
      < "const char *"
    if t.kind == NC_LITERAL && t.n && t.s[0] == '\''
      < c->cpp ? "auto" : "int"
    if nc_is(t, "true") || nc_is(t, "false")
      < c->cpp ? "bool" : nc_std == 89 ? "int" : "_Bool"
    if t.kind == NC_NUMBER
      char *s = nc_text(c, t), *end
      char *signed_text = i ? nc_format(c, "%.*s%s", (int)items.v[0].n, items.v[0].s, s) : s
      errno = 0
      long long n = strtoll(signed_text, &end, 10)
      if !errno && !*end && n >= -32767 && n <= 32767
        < "int"
      if !errno && !*end && n >= -2147483647LL && n <= 2147483647LL
        < "long"
      if strpbrk(s, ".eE")
        errno = 0
        (void)strtod(s, &end)
        if !*end
          < "double"
  if c->cpp
    < "auto"
  nc_fail(c, line, "type needed: use 'name:CType = expression' for nonliteral initializers")
  < NULL

// Parses a declaration head.
f nc_declaration(NcContext *ctx, NcTokens ts, int line) NcTokens
  NcCursor c = {ctx, ts, 0}
  NcTokens names = nc_until(&c, "=")
  nc_need(&c, "=")
  NcTokens init = nc_slice(ts, c.pos, ts.n)
  bool colon = 0
  for size_t i = (0), nanoc_bound_1 = (names.n); i < nanoc_bound_1; ++i
    if nc_is(names.v[i], ":")
      colon = 1
  char *type = colon ? "" : nc_format(ctx, ":%s", nc_infer(ctx, init, line))
  < nc_lex(ctx, nc_format(ctx, "%s%s=%s", nc_join(ctx, names), type, nc_join(ctx, init)), line)
