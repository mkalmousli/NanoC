// Recognition of statement-leading compact syntax; expression tokens are left alone.
@lang 1
+ "nanoc/nanoc.h"

// Reports whether a token starts a source line (comments count as whitespace).
f nc_bol(NcTokens ts, size_t at) bool
  int line = ts.v[at].line
  while at
    NcToken prev = ts.v[--at]
    if prev.kind != NC_SPACE
      < prev.line < line
    if memchr(prev.s, '\n', prev.n)
      < 1
  < 1

// Recognizes an unprefixed declaration without treating C declarations as NanoC.
f nc_compact_decl(NcTokens ts, size_t at) bool
  if !nc_bol(ts, at)
    < 0
  NcToken t = ts.v[at++]
  if !nc_is(t, "f") && !nc_is(t, "s") && !nc_is(t, "u") && !nc_is(t, "e")
    < 0
  while at < ts.n && ts.v[at].kind == NC_SPACE && ts.v[at].line == t.line
    ++at
  if at == ts.n || ts.v[at].line != t.line || ts.v[at].kind != NC_WORD
    < 0
  bool expression = 0
  while at < ts.n && ts.v[at].line == t.line
    if nc_is(ts.v[at], "=")
      expression = 1
    if (nc_is(ts.v[at], ";") && !nc_is(t, "f")) || (nc_is(ts.v[at], "{") && !expression)
      < 0
    ++at
  < 1

// Detects actual NanoC syntax, preserving the fast path for unmarked C and C++.
f nc_has_syntax(NcContext *c, const char *input) bool
  NcTokens ts = nc_lex(c, input, 1)
  for size_t i = (0), nanoc_bound_1 = (ts.n); i < nanoc_bound_1; ++i
    NcToken t = ts.v[i]
    if t.kind == NC_SPACE || t.kind == NC_LITERAL || t.kind == NC_DIRECTIVE
      ^
    if nc_is(t, "@") || nc_compact_decl(ts, i)
      < 1
    if nc_directive_start(ts, i)
      < 1
  < 0

// Recognizes a directive sigil before parsing a logical line; C fragments can be unbalanced.
f nc_directive_start(NcTokens ts, size_t at) bool
  if !nc_bol(ts, at)
    < 0
  NcToken t = ts.v[at++]
  while at < ts.n && ts.v[at].kind == NC_SPACE && !memchr(ts.v[at].s, '\n', ts.v[at].n)
    ++at
  bool next = at < ts.n && ts.v[at].line == t.line
  if nc_is(t, "asm") || nc_is(t, "$")
    < 1
  if nc_is(t, ":")
    < !next || nc_is(ts.v[at], "#")
  if !next
    < 0
  NcToken n = ts.v[at]
  if nc_is(t, "+")
    for size_t k = at; k < ts.n && ts.v[k].line == t.line; ++k
      if nc_is(ts.v[k], ";")
        < 0
    < nc_is(n, "<") || n.kind == NC_LITERAL || n.kind == NC_WORD
  if nc_is(t, "!")
    if !nc_is(n, "!") || t.s + t.n != n.s
      < 0
    ++at
    while at < ts.n && ts.v[at].kind == NC_SPACE && !memchr(ts.v[at].s, '\n', ts.v[at].n)
      ++at
    < at < ts.n && ts.v[at].line == t.line && ts.v[at].kind == NC_LITERAL && ts.v[at].s[0] == '"'
  < nc_is(t, "?") && (nc_is(n, "+") || nc_is(n, "-") || nc_is(n, "#"))
