// Short numeric type names that lex to plain C type words, valid in every C compiler.
@use "nanoc/nanoc"
// Rewrites a word token such as i32 or f64 to its C type; other tokens are unchanged.
int nc_std;
@f nc_alias(NcToken *t) void
  static const char *const map[][2] = {{"i8", "signed char"}, {"i16", "short"}, {"i32", "int"},
    {"i64", "long long"}, {"u8", "unsigned char"}, {"u16", "unsigned short"}, {"u32", "unsigned"},
    {"u64", "unsigned long long"}, {"f32", "float"}, {"f64", "double"}, {"usize", "size_t"},
    {"isize", "ptrdiff_t"}, {"byte", "unsigned char"}, {"cstr", "const char *"}}
  if t->kind != NC_WORD or t->n < 2 or t->n > 5
    return
  for k:usize 0..sizeof map / sizeof *map
    if strlen(map[k][0]) == t->n and !strncmp(t->s, map[k][0], t->n)
      if nc_std == 89 && strstr(map[k][1], "long long")
        t->s = map[k][1][0] == 'u' ? "unsigned long" : "long"
        t->n = strlen(t->s)
        return
      t->s = map[k][1]
      t->n = strlen(map[k][1])
      return
// Rewrites a type name given as text, e.g. "usize" to "size_t".
@f nc_alias_name(NcContext *c, cstr name) char *
  NcToken t = {name, strlen(name), 0, 0, NC_WORD}
  nc_alias(&t)
  nc_string(c, t.s, t.n)
// Returns the tokens with every short type name rewritten; only NanoC-owned code goes through here.
@f nc_aliased(NcContext *c, NcTokens ts) NcTokens
  NcTokens out = {0}
  for i:usize 0..ts.n
    NcToken t = ts.v[i]
    nc_alias(&t)
    NC_PUSH(c, out, t)
  out
