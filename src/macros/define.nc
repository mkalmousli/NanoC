// Parses @m macro definitions.
@use "nanoc/nanoc"
// Defines a macro.
@f nc_define_macro(NcContext *ctx, NcCursor *c) void
  NcHeader header = nc_header(c)
  char *name = nc_name(c)
  if (!strcmp(name, "fn") || !strcmp(name, "let") || !strcmp(name, "for") || !strcmp(name, "macro")
    || !strcmp(name, "ct") || !strcmp(name, "m") || !strcmp(name, "f") || !strcmp(name, "bt"))
    nc_fail(ctx, nc_line(c), "reserved extension name")
  if nc_get(&ctx->macros, name)
    nc_fail(ctx, nc_line(c), "duplicate macro: %s", name)
  NcMacro *m = nc_alloc(ctx, sizeof *m)
  NcGroups args = {0}
  if nc_header_at(c, "(", header.line)
    args = nc_split(ctx, nc_group(c, "(", ")"), ",")
  NcMap names = {0}
  for usize i = 0; i < args.n; ++i
    NcCursor a = {ctx, args.v[i], 0}
    nc_need(&a, "$")
    NcParam p = {.name = nc_name(&a)}
    p.kind = nc_eat(&a, ":") ? nc_name(&a) : "tokens"
    p.variadic = nc_eat(&a, "...")
    if (!nc_end(&a)
      || (strcmp(p.kind, "tokens") && strcmp(p.kind, "ident") && strcmp(p.kind, "block")))
      nc_fail(ctx, nc_line(&a), "expected ident, tokens, or block parameter")
    if nc_get(&names, p.name) || !strcmp(p.name, "fresh")
      nc_fail(ctx, nc_line(&a), "duplicate or reserved parameter")
    nc_put(ctx, &names, p.name, (void *)1)
    if m->params.n and m->params.v[m->params.n - 1].variadic
      nc_fail(ctx, nc_line(&a), "variadic parameter must be last")
    NC_PUSH(ctx, m->params, p)
  m->body = nc_macro_body(c, header, &m->program)
  nc_put(ctx, &ctx->macros, name, m)
