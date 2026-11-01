// Typed declarations with inference.
@use "nanoc/nanoc"
// Separator between a type and a name: none after "*".
@f nc_sep(cstr type) cstr 
  usize n = strlen(type)
  n && type[n - 1] == '*' ? "" : " "
// Parses a typed declaration.
@f nc_typed(NcContext *ctx, NcTokens input, bool initialized) char *
  NcCursor c = {ctx, input, 0}
  NcGroups names = nc_split(ctx, nc_until(&c, ":"), ",")
  nc_need(&c, ":")
  char *type = nc_trim(ctx, nc_join(ctx, nc_until(&c, "=")))
  if !*type
    nc_fail(ctx, nc_line(&c), "expected C type")
  NcTokens types = nc_lex(ctx, type, input.n ? input.v[0].line : 1)
  for i:usize in 0..types.n
    NcToken t = types.v[i]
    if (nc_is(t, "(") || nc_is(t, "[") || nc_is(t, ",") || nc_is(t, ";") || nc_is(t, "{")
      || nc_is(t, "}"))
      nc_fail(ctx, t.line, "use an ordinary C declaration for complex declarators")
  char *init = ""
  if nc_eat(&c, "=")
    if not initialized
      nc_fail(ctx, nc_line(&c), "parameter defaults are not supported")
    char *expr = nc_trim(ctx, nc_join(ctx, nc_slice(input, c.pos, input.n)))
    if !*expr
      nc_fail(ctx, nc_line(&c), "missing initializer")
    init = nc_format(ctx, " = %s", expr)
  if not names.n
    nc_fail(ctx, nc_line(&c), "missing declaration name")
  NcBuffer out = {0}
  for i:usize in 0..names.n
    NcCursor name = {ctx, names.v[i], 0}
    char *id = nc_name(&name)
    if !nc_end(&name)
      nc_fail(ctx, nc_line(&name), "expected a declaration name")
    if i
      nc_add(ctx, &out, initialized ? "; " : ", ")
    nc_printf(ctx, &out, "%s%s%s%s", type, nc_sep(type), id, init)
  out.v
// Parses a parameter list.
@f nc_parameters(NcContext *ctx, NcTokens ts) char *
  if !*nc_trim(ctx, nc_join(ctx, ts))
    return ctx->cpp ? "" : "void"
  NcGroups parts = nc_split(ctx, ts, ",")
  NcTokens pending = {0}
  NcBuffer out = {0}
  for i:usize in 0..parts.n
    if pending.n
      NC_PUSH(ctx, pending, nc_token(",", 1, NC_PUNCT))
    bool colon = false
    for usize j = 0; j < parts.v[i].n; ++j
      NcToken t = parts.v[i].v[j]
      NC_PUSH(ctx, pending, t)
      if nc_is(t, ":")
        colon = true
    if not colon
      continue
    if out.n
      nc_add(ctx, &out, ", ")
    nc_add(ctx, &out, nc_typed(ctx, pending, false))
    pending = (NcTokens){0}
  if pending.n
    nc_fail(ctx, pending.v[0].line, "parameters require explicit types")
  out.v
