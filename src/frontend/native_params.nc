// Native function parameter lists.
#include "nanoc/nanoc.h"
// Reads native parameters.
@f nc_native_parameters(NcContext *ctx, NcTokens ts) char *
  NcGroups groups = nc_split(ctx, ts, ",")
  if !groups.n
    return ctx->cpp ? "" : "void"
  char *type = NULL
  NcBuffer out = {0}
  for usize i = 0; i < groups.n; ++i
    NcTokens part = nc_significant(ctx, groups.v[i])
    if !part.n
      nc_fail(ctx, 1, "empty function parameter")
    if i
      nc_add(ctx, &out, ", ")
    if part.n == 1 && (nc_is(part.v[0], "void") || nc_is(part.v[0], "..."))
      nc_add(ctx, &out, nc_text(ctx, part.v[0]))
      continue
    NcToken name = part.v[part.n - 1]
    if name.kind != NC_WORD
      nc_fail(ctx, name.line, "use a typedef or ordinary C for complex parameters")
    if part.n > 1
      usize last = groups.v[i].n
      while last && groups.v[i].v[last - 1].kind == NC_SPACE
        --last
      type = nc_trim(ctx, nc_join(ctx, nc_aliased(ctx, nc_slice(groups.v[i], 0, last - 1))))
    if !type || !*type
      nc_fail(ctx, name.line, "first parameter in a group needs a C type")
    nc_printf(ctx, &out, "%s%s%.*s", type, nc_sep(type), (int)name.n, name.s)
  out.v
