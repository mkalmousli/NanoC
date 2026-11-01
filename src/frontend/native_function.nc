// Native function headers and returns.
@use "nanoc/nanoc"
// Reads a function return type.
@f return_type(NcCursor *c, int line) static NcTokens
  usize start = c->pos
  while (nc_same_line(c, line) && !nc_header_at(c, "=>", line) && !nc_header_at(c, "=", line)
    && !nc_header_at(c, "{", line))
    (void)nc_take(c)
  nc_slice(c->ts, start, c->pos)
// Rewrites the final return.
@f lower_returns(NcContext *ctx, char *body, int line) static char *
  if !strstr(body, "=>")
    return body
  NcTokens ts = nc_lex(ctx, body, line)
  NcBuffer b = {0}
  for i:usize in 0..ts.n
    NcToken t = ts.v[i]
    if t.kind == NC_PUNCT && nc_is(t, "=>")
      nc_add(ctx, &b, "return ")
    else
      nc_addn(ctx, &b, t.s, t.n)
  nc_add(ctx, &b, "")
  b.v
// Expands a native function.
@f nc_native_function(NcContext *ctx, NcCursor *c, usize depth) char *
  NcHeader header = nc_header(c)
  int definition_line = header.line
  char *name = nc_name(c)
  char *params = ctx->cpp ? "" : "void"
  if nc_header_at(c, "(", header.line)
    params = nc_native_parameters(ctx, nc_group(c, "(", ")"))
    header.line = c->ts.v[c->pos - 1].line
  char *type = "void"
  bool arrow = nc_header_eat(c, "->", header.line)
  if (arrow
    or (
      nc_same_line(c, header.line) && !nc_header_at(c, "=", header.line)
      && !nc_header_at(c, "=>", header.line) && !nc_header_at(c, "{", header.line)))
    type = nc_trim(ctx, nc_join(ctx, nc_aliased(ctx, return_type(c, header.line))))
  if !*type
    nc_fail(ctx, header.line, "missing return type")
  NcTokens result = nc_significant(ctx, nc_lex(ctx, type, header.line))
  bool value = !nc_is(result.v[result.n - 1], "void")
  NC_PUSH(ctx, ctx->symbols, ((NcSymbol){name, params, type, "", definition_line}))
  char *body
  ctx->ret_type = type
  ctx->defers = nil
  if nc_header_eat(c, "=>", header.line)
    char *expr = nc_join(ctx, nc_aliased(ctx, nc_until(c, ";")))
    nc_need(c, ";")
    body = nc_format(ctx, "%s%s;", value ? "return " : "", expr)
  else
    bool expression = nc_header_eat(c, "=", header.line)
    usize next = c->pos
    while next < c->ts.n and c->ts.v[next].kind == NC_SPACE
      ++next
    if expression and nc_same_line(c, header.line)
      body = nc_format(ctx, "%s%s;", value ? "return " : "", nc_join(ctx, nc_aliased(ctx, nc_line_expression(c))))
    elif next < c->ts.n && nc_is(c->ts.v[next], "{")
      body = nc_join(ctx, nc_aliased(ctx, nc_group(c, "{", "}")))
    else
      body = nc_emit_block(ctx, nc_indented_nodes(c, header, false), value, 0)
  char *expanded = nc_expand(ctx, nc_lex(ctx, body, header.line), depth)
  nc_format(ctx, "%s%s%s(%s) {%s}", type, nc_sep(type), name, params,
    lower_returns(ctx, expanded, header.line))
