// Macro invocation and checking.
@use "nanoc/nanoc"
// Checks an argument fits its kind.
@f validate(NcContext *ctx, NcParam p, NcTokens ts) static void
  NcCursor c = {ctx, ts, 0}
  if !strcmp(p.kind, "ident") then (void)nc_name(&c)
  elif !strcmp(p.kind, "block") then (void)nc_group(&c, "{", "}")
  else
    if nc_end(&c) then nc_fail(ctx, nc_line(&c), "empty token argument")
    return
  if !nc_end(&c) then nc_fail(ctx, nc_line(&c), "invalid %s argument", p.kind)
// Expands a macro call.
@f nc_invoke_macro(NcContext *ctx, NcCursor *c, cstr name, usize depth) char *
  NcMacro *m = nc_get(&ctx->macros, name)
  if not m then nc_fail(ctx, nc_line(c), "unknown extension: @%s", name)
  int line = c->pos ? c->ts.v[c->pos - 1].line : nc_line(c)
  int indent = nc_header(c).indent
  bool bang = nc_header_eat(c, "!", line)
  NcGroups args = {0}
  bool block_only = (m->params.n == 1 && !strcmp(m->params.v[0].kind, "block")
    and !m->params.v[0].variadic)
  if bang || (m->params.n && !block_only) || nc_header_at(c, "(", line)
    args = nc_split(ctx, nc_group(c, "(", ")"), ",")
  nc_block_argument(ctx, c, m, &args, c->pos ? c->ts.v[c->pos - 1].line : line, indent)
  bool variadic = m->params.n and m->params.v[m->params.n - 1].variadic
  usize fixed = m->params.n - (usize)variadic
  if args.n < fixed or (!variadic and args.n != fixed)
    nc_fail(ctx, nc_line(c), "wrong argument count for @%s", name)
  NcBindings b = {0}
  for i:usize in 0..m->params.n
    NcParam p = m->params.v[i]
    NcGroups *values = nc_alloc(ctx, sizeof *values)
    usize end = p.variadic ? args.n : i + 1
    if p.variadic then b.variadic = p.name
    for j:usize in i..end
      validate(ctx, p, args.v[j])
      NC_PUSH(ctx, *values, args.v[j])
    nc_put(ctx, &b.values, p.name, values)
  char *generated = (m->program ? nc_macro_program(ctx, m, &b, depth)
    : nc_substitute(ctx, m->body, &b, depth, SIZE_MAX))
  nc_expand(ctx, nc_lex(ctx, generated, nc_line(c)), depth)
