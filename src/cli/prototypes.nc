#include "nanoc/nanoc.h"
@f nc_prototypes(NcContext *c, FILE *out) void
  for size_t i = 0; i < c->symbols.n; ++i
    NcSymbol s = c->symbols.v[i]
    if strncmp(s.returns, "static", 6)
      fprintf(out, "%s %s(%s);\n", s.returns, s.name, s.params)
