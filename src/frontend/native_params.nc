// NanoC parameters use name:type, or exact C declarators for C interoperability.
@lang 1
+ "nanoc/nanoc.h"

// Converts name-first parameters while passing C parameter lists through without semantic analysis.
f nc_native_parameters(NcContext *ctx, NcTokens ts) -> char *
  if (!nc_significant(ctx, ts).n)
    return ctx->cpp ? "" : "void"
  for (size_t i = 0; i < ts.n; ++i)
    if (nc_is(ts.v[i], ":") && (!i || !nc_is(ts.v[i - 1], ":")) && (i + 1 == ts.n || !nc_is(ts.v[i + 1], ":")))
      return nc_parameters(ctx, ts)
  return nc_join(ctx, ts)
