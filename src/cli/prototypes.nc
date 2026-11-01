// Prints non-static prototypes for --prototypes. Used to
// generate headers.
#include "nanoc/nanoc.h"
// Prints non-static prototypes.
@f nc_prototypes(NcContext *c, FILE *out) void
  for size_t i = 0; i < c->symbols.n; ++i
    NcSymbol s = c->symbols.v[i]
    if strncmp(s.returns, "static", 6)
      fprintf(out, "%s%s%s(%s);\n", s.returns,
        nc_sep(s.returns), s.name, s.params)
