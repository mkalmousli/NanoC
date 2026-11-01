// Mini emitter: smallest valid C for fast compiles.
// Tells if a character can continue an identifier.
@f wordy(char ch) static bool = isalnum((unsigned char)ch) || ch == '_' || (unsigned char)ch >= 128
// Tells if two adjacent characters must stay apart.
@f apart(char a, char b) static bool
  const char *glue = "+-&|<>=*/!%^:."
  if wordy(a) and wordy(b) then return true
  if a and b and strchr(glue, a) and strchr(glue, b) then return true
  (a == '"' || a == '\'') && wordy(b)
// Strips comments and layout; keeps one directive per line.
@f nc_mini(NcContext *c, cstr text) char *
  NcTokens ts = nc_lex(c, text, 1)
  NcBuffer out = {0}
  for i:usize in 0..ts.n
    NcToken t = ts.v[i]
    if t.kind == NC_SPACE then continue
    usize n = t.n
    if t.kind == NC_DIRECTIVE
      while n and isspace((u8)t.s[n - 1]) then --n
      if out.n && out.v[out.n - 1] != '\n' then nc_add(c, &out, "\n")
      nc_addn(c, &out, t.s, n)
      nc_add(c, &out, "\n")
      continue
    if out.n and apart(out.v[out.n - 1], t.s[0]) then nc_add(c, &out, " ")
    nc_addn(c, &out, t.s, n)
  if out.n && out.v[out.n - 1] != '\n' then nc_add(c, &out, "\n")
  nc_add(c, &out, "")
  out.v
// Applies the selected emit style to generated C.
@f nc_style(NcContext *c, cstr text) char *
  if c->mini then return nc_mini(c, text)
  nc_pretty(c, text)
