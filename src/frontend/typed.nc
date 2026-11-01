// Typed declarations with inference.
#include "nanoc/nanoc.h"
// Parses a typed declaration.
@f nc_typed(
  NcContext *ctx, NcTokens input, bool initialized
) char *
  NcCursor c = {ctx, input, 0}
  NcGroups names = nc_split(ctx, nc_until(&c, ":"), ",")
  nc_need(&c, ":")
  char *type = nc_trim(ctx, nc_join(ctx, nc_until(&c, "=")))
  if !*type
    nc_fail(ctx, nc_line(&c), "expected C type")
  NcTokens types = nc_lex(ctx, type,
    input.n ? input.v[0].line : 1)
  for size_t i = 0; i < types.n; ++i
    NcToken t = types.v[i]
    if (nc_is(t, "(") || nc_is(t, "[") || nc_is(t, ",")
      || nc_is(t, ";") || nc_is(t, "{") || nc_is(t, "}"))
      nc_fail(ctx, t.line,
        "use an ordinary C declaration for complex "
        "declarators")
  char *init = ""
  if nc_eat(&c, "=")
    if !initialized
      nc_fail(ctx, nc_line(&c),
        "parameter defaults are not supported")
    char *expr = nc_trim(ctx,
      nc_join(ctx, nc_slice(input, c.pos, input.n)))
    if !*expr
      nc_fail(ctx, nc_line(&c), "missing initializer")
    init = nc_format(ctx, " = %s", expr)
  if !names.n
    nc_fail(ctx, nc_line(&c), "missing declaration name")
  NcBuffer out = {0}
  for size_t i = 0; i < names.n; ++i
    NcCursor name = {ctx, names.v[i], 0}
    char *id = nc_name(&name)
    if !nc_end(&name)
      nc_fail(ctx, nc_line(&name),
        "expected a declaration name")
    if i
      nc_add(ctx, &out, initialized ? "; " : ", ")
    nc_printf(ctx, &out, "%s %s%s", type, id, init)
  out.v
// Parses a parameter list.
@f nc_parameters(NcContext *ctx, NcTokens ts) char *
  if !*nc_trim(ctx, nc_join(ctx, ts))
    return ctx->cpp ? "" : "void"
  NcGroups parts = nc_split(ctx, ts, ",")
  NcTokens pending = {0}
  NcBuffer out = {0}
  for size_t i = 0; i < parts.n; ++i
    if pending.n
      NC_PUSH(ctx, pending, nc_token(",", 1, NC_PUNCT))
    bool colon = false
    for size_t j = 0; j < parts.v[i].n; ++j
      NcToken t = parts.v[i].v[j]
      NC_PUSH(ctx, pending, t)
      if nc_is(t, ":")
        colon = true
    if !colon
      continue
    if out.n
      nc_add(ctx, &out, ", ")
    nc_add(ctx, &out, nc_typed(ctx, pending, false))
    pending = (NcTokens){0}
  if pending.n
    nc_fail(ctx, pending.v[0].line,
      "parameters require explicit types")
  out.v
