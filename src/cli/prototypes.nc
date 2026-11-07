// Prints non-static prototypes for --prototypes. Used to
@lang 1
+ "nanoc/nanoc.h"

// generate headers.
// Prints non-static prototypes.
f nc_prototypes(NcContext *c, FILE *out)
  for size_t i = (0), nanoc_bound_1 = (c->symbols.n); i < nanoc_bound_1; ++i
    NcSymbol s = c->symbols.v[i]
    if strncmp(s.returns, "static", 6)
      fprintf(out, "%s%s%s(%s);\n", s.returns, nc_sep(s.returns), s.name, s.params)
