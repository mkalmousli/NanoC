// Prints non-static prototypes for --prototypes. Used to
// generate headers.
@use "nanoc/nanoc"
// Prints non-static prototypes.
@f nc_prototypes(NcContext *c, FILE *out) void
  for i:usize in 0..c->symbols.n
    NcSymbol s = c->symbols.v[i]
    if strncmp(s.returns, "static", 6)
      fprintf(out, "%s%s%s(%s);\n", s.returns, nc_sep(s.returns), s.name, s.params)
