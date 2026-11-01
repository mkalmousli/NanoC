// Type inference for := declarations.
@use errno
// Rewrites := with a typeof.
@f nc_infer(NcContext *c, NcTokens ts, int line) char *
  NcTokens items = nc_significant(c, ts)
  size_t i = items.n > 1 && (nc_is(items.v[0], "+") || nc_is(items.v[0], "-")) ? 1 : 0
  if items.n == i + 1
    NcToken t = items.v[i]
    if t.kind == NC_LITERAL && t.n && t.s[0] == '"' then return "const char *"
    if nc_is(t, "true") || nc_is(t, "false") then return c->cpp ? "bool" : "_Bool"
    if t.kind == NC_NUMBER
      char *s = nc_text(c, t), *end
      char *signed_text = i ? nc_format(c, "%.*s%s", (int)items.v[0].n, items.v[0].s, s) : s
      errno = 0
      i64 n = strtoll(signed_text, &end, 10)
      if !errno and !*end and n >= INT32_MIN and n <= INT32_MAX then return "int"
      if strpbrk(s, ".eE")
        errno = 0
        (void)strtod(s, &end)
        if !*end then return "double"
  if c->cpp then return "auto"
  nc_fail(c, line, "type needed: use 'name:CType = expression' for nonliteral initializers")
  nil
// Parses a declaration head.
@f nc_declaration(NcContext *ctx, NcTokens ts, int line) NcTokens
  NcCursor c = {ctx, ts, 0}
  NcTokens names = nc_until(&c, "=")
  nc_need(&c, "=")
  NcTokens init = nc_slice(ts, c.pos, ts.n)
  bool colon = false
  for i:usize in 0..names.n
    if nc_is(names.v[i], ":") then colon = true
  char *type = colon ? "" : nc_format(ctx, ":%s", nc_infer(ctx, init, line))
  nc_lex(ctx, nc_format(ctx, "%s%s=%s", nc_join(ctx, names), type, nc_join(ctx, init)), line)
