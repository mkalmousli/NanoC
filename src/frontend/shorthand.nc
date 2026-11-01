// Shorthand forms such as fn.
@use "nanoc/nanoc"
// Expands shorthand forms.
@f nc_shorthand(NcContext *ctx, NcCursor *c, cstr name, usize depth) char *
  if !strcmp(name, "fn") then return nc_function(ctx, c, depth)
  if !strcmp(name, "let")
    NcTokens declaration = nc_until(c, ";")
    nc_need(c, ";")
    char *text = nc_format(ctx, "%s;", nc_typed(ctx, declaration, true))
    return nc_expand(ctx, nc_lex(ctx, text, 1), depth)
  NcCursor h = {ctx, nc_group(c, "(", ")"), 0}
  char *type = nc_name(&h), *id = nc_name(&h)
  nc_need(&h, "in")
  char *low = nc_trim(ctx, nc_join(ctx, nc_until(&h, "..")))
  nc_need(&h, "..")
  char *high = nc_trim(ctx, nc_join(ctx, nc_slice(h.ts, h.pos, h.ts.n)))
  if !*low or !*high then nc_fail(ctx, nc_line(c), "range requires two bounds")
  NcTokens body = nc_group(c, "{", "}")
  char *start = nc_fresh(ctx, "start"), *end = nc_fresh(ctx, "end")
  nc_format(ctx, "{ %s %s = (%s); %s %s = (%s); for (%s %s = %s; %s < %s; ++%s) {%s} }", type,
    start, low, type, end, high, type, id, start, id, end, id, nc_expand(ctx, body, depth))
