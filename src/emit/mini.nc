// Mini emitter: smallest valid C for fast compiles.
#include "nanoc/nanoc.h"
// Tells if a character can continue an identifier.
@f wordy(char ch) static bool
  isalnum((unsigned char)ch) || ch == '_' || (unsigned char)ch >= 128
// Tells if two adjacent characters must stay apart.
@f apart(char a, char b) static bool
  const char *glue = "+-&|<>=*/!%^:."
  if wordy(a) && wordy(b)
    return true
  if a && b && strchr(glue, a) && strchr(glue, b)
    return true
  (a == '"' || a == '\'') && wordy(b)
// Strips comments and layout; keeps one directive per line.
@f nc_mini(NcContext *c, const char *text) char *
  NcTokens ts = nc_lex(c, text, 1)
  NcBuffer out = {0}
  for usize i = 0; i < ts.n; ++i
    NcToken t = ts.v[i]
    if t.kind == NC_SPACE
      continue
    usize n = t.n
    if t.kind == NC_DIRECTIVE
      while n && isspace((unsigned char)t.s[n - 1])
        --n
      if out.n && out.v[out.n - 1] != '\n'
        nc_add(c, &out, "\n")
      nc_addn(c, &out, t.s, n)
      nc_add(c, &out, "\n")
      continue
    if out.n && apart(out.v[out.n - 1], t.s[0])
      nc_add(c, &out, " ")
    nc_addn(c, &out, t.s, n)
  if out.n && out.v[out.n - 1] != '\n'
    nc_add(c, &out, "\n")
  nc_add(c, &out, "")
  out.v
// Applies the selected emit style to generated C.
@f nc_style(NcContext *c, const char *text) char *
  if c->mini
    return nc_mini(c, text)
  nc_pretty(c, text)
