// Parses @m macro definitions.
@lang 1
+ "nanoc/nanoc.h"

// Defines a macro.
f nc_define_macro(NcContext *ctx, NcCursor *c)
  NcHeader header = nc_header(c)
  char *name = nc_name(c)
  if !strcmp(name, "m") || (!strcmp(name, "ct") || !strcmp(name, "tt")) || !strcmp(name, "c") || !strcmp(name, "bt") || !strcmp(name, "asm")
    nc_fail(ctx, nc_line(c), "reserved transformation name")
  if nc_get(&ctx->macros, name)
    nc_fail(ctx, nc_line(c), "duplicate macro: %s", name)
  NcMacro *m = nc_alloc(ctx, sizeof *m)
  NcGroups args = {0}
  if nc_header_at(c, "(", header.line)
    args = nc_split(ctx, nc_group(c, "(", ")"), ",")
  NcMap names = {0}
  for size_t i = (0), nanoc_bound_1 = (args.n); i < nanoc_bound_1; ++i
    NcCursor a = {ctx, args.v[i], 0}
    nc_need(&a, "$")
    NcParam p = {.name = nc_name(&a)}
    p.kind = nc_eat(&a, ":") ? nc_name(&a) : "tokens"
    p.variadic = nc_eat(&a, "...")
    if !nc_end(&a) || (strcmp(p.kind, "tokens") && strcmp(p.kind, "ident") && strcmp(p.kind, "block"))
      nc_fail(ctx, nc_line(&a), "expected ident, tokens, or block parameter")
    if nc_get(&names, p.name) || !strcmp(p.name, "fresh")
      nc_fail(ctx, nc_line(&a), "duplicate or reserved parameter")
    nc_put(ctx, &names, p.name, (void *)1)
    if m->params.n && m->params.v[m->params.n - 1].variadic
      nc_fail(ctx, nc_line(&a), "variadic parameter must be last")
    NC_PUSH(ctx, m->params, p)
  m->body = nc_macro_body(c, header, &m->program)
  nc_put(ctx, &ctx->macros, name, m)
