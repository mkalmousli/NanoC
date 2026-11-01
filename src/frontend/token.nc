// Token predicates and text helpers.
#include "nanoc/nanoc.h"
// Tells if a token has the text.
@f nc_is(NcToken t, const char *s) bool
  t.n == strlen(s) && !memcmp(t.s, s, t.n)
// Copies a token as text.
@f nc_text(NcContext *c, NcToken t) char *
  nc_string(c, t.s, t.n)
// Makes a token.
@f nc_token(const char *s, int line, NcKind kind) NcToken
  (NcToken){s, strlen(s), line, 1, kind}
// Takes a sub-range of tokens.
@f nc_slice(NcTokens ts, usize a, usize b) NcTokens
  (NcTokens){ts.v ? ts.v + a : NULL, b - a, b - a}
// Concatenates token text.
@f nc_join(NcContext *c, NcTokens ts) char *
  NcBuffer b = {0}
  for usize i = 0; i < ts.n; ++i
    nc_addn(c, &b, ts.v[i].s, ts.v[i].n)
  nc_add(c, &b, "")
  b.v
// Drops whitespace tokens.
@f nc_significant(NcContext *c, NcTokens ts) NcTokens
  NcTokens out = {0}
  for usize i = 0; i < ts.n; ++i
    if ts.v[i].kind != NC_SPACE
      NC_PUSH(c, out, ts.v[i])
  out
// Joins tokens as spaced words.
@f nc_words(NcContext *c, NcTokens ts) char *
  NcBuffer b = {0}
  for usize i = 0; i < ts.n; ++i
    NcToken t = ts.v[i]
    nc_alias(&t)
    const char *s = NULL
    if t.kind == NC_WORD
      if nc_is(t, "and")
        s = "&&"
      elif nc_is(t, "or")
        s = "||"
      elif nc_is(t, "not")
        s = "!"
      elif nc_is(t, "true")
        s = "1"
      elif nc_is(t, "false")
        s = "0"
      elif nc_is(t, "nil")
        s = "NULL"
    if s
      nc_add(c, &b, s)
    else
      nc_addn(c, &b, t.s, t.n)
  nc_add(c, &b, "")
  b.v
// Records identifier tokens.
@f nc_names(NcContext *c, NcTokens ts) void
  for usize i = 0; i < ts.n; ++i
    if ts.v[i].kind == NC_WORD && !nc_has_token(&c->names, ts.v[i])
      nc_put(c, &c->names, nc_text(c, ts.v[i]), (void *)1)
