#include "nanoc/core.h"
@f nc_is(NcToken t, const char *s) bool
  t.n == strlen(s) && !memcmp(t.s, s, t.n)
@f nc_text(NcContext *c, NcToken t) char *
  nc_string(c, t.s, t.n)
@f nc_token(const char *s, int line, NcKind kind) NcToken
  (NcToken){s, strlen(s), line, 1, kind}
@f nc_slice(NcTokens ts, size_t a, size_t b) NcTokens
  (NcTokens){ts.v ? ts.v + a : NULL, b - a, b - a}
@f nc_join(NcContext *c, NcTokens ts) char *
  NcBuffer b = {0}
  for size_t i = 0; i < ts.n; ++i
    nc_addn(c, &b, ts.v[i].s, ts.v[i].n)
  nc_add(c, &b, "")
  b.v
@f nc_significant(NcContext *c, NcTokens ts) NcTokens
  NcTokens out = {0}
  for size_t i = 0; i < ts.n; ++i
    if ts.v[i].kind != NC_SPACE
      NC_PUSH(c, out, ts.v[i])
  out
@f nc_words(NcContext *c, NcTokens ts) char *
  NcBuffer b = {0}
  for size_t i = 0; i < ts.n; ++i
    NcToken t = ts.v[i]
    const char *s = NULL
    if t.kind == NC_WORD
      if nc_is(t, "and")
        s = "&&"
      else
        if nc_is(t, "or")
          s = "||"
        else
          if nc_is(t, "not")
            s = "!"
          else
            if nc_is(t, "true")
              s = "1"
            else
              if nc_is(t, "false")
                s = "0"
    if s
      nc_add(c, &b, s)
    else
      nc_addn(c, &b, t.s, t.n)
  nc_add(c, &b, "")
  b.v
@f nc_names(NcContext *c, NcTokens ts) void
  for size_t i = 0; i < ts.n; ++i
    if ts.v[i].kind == NC_WORD && !nc_has_token(&c->names, ts.v[i])
      nc_put(c, &c->names, nc_text(c, ts.v[i]), (void *)1)
