// NanoC v1 statements preserve C expression tokens and evaluation order.
@lang 1
+ "nanoc/nanoc.h"
// Lowers a declaration, preprocessing directive, or ordinary C statement.
f nc_statement(NcContext *c, NcLayoutLine line) char *
  NcTokens ts = line.ts
  NcTokens items = nc_significant(c, ts)
  if !items.n
    < ""
  if nc_is(items.v[items.n - 1], ";")
    size_t last = ts.n
    while last && ts.v[last - 1].kind == NC_SPACE
      --last
    ts.n = last - 1
    items = nc_significant(c, ts)
  if !items.n
    < ";"
  char *directive = nc_pp_simple(c, ts, line.line)
  if directive
    < directive
  if nc_is(items.v[0], "return") || nc_is(items.v[0], "break") || nc_is(items.v[0], "continue")
    nc_fail(c, line.line, "NanoC v1 uses '< value', '!' and '^' for return, break and continue")
  if nc_is(items.v[0], "<")
    < nc_format(c, "return %s;", nc_words(c, nc_slice(ts, 1, ts.n)))
  if items.n == 1 && (nc_is(items.v[0], "!") || nc_is(items.v[0], "^"))
    < nc_is(items.v[0], "!") ? "break;" : "continue;"
  if nc_is(items.v[0], "=")
    nc_fail(c, line.line, "NanoC v1 returns use '< expression'")
  if nc_is(items.v[0], "?")
    nc_fail(c, line.line, "NanoC v1 runtime conditions use if")
  if items.n > 1 && items.v[0].kind == NC_WORD && nc_is(items.v[1], ":=")
    NcTokens normalized = {0}
    for size_t i = 0; i < ts.n; ++i
      NC_PUSH(c, normalized, nc_is(ts.v[i], ":=") ? nc_token("=", ts.v[i].line, NC_PUNCT) : ts.v[i])
    < nc_format(c, "%s;", nc_words(c, nc_lex(c, nc_typed(c, nc_declaration(c, normalized, line.line), 1), line.line)))
  if items.n > 1 && items.v[0].kind == NC_WORD && (nc_is(items.v[1], ":") || nc_is(items.v[1], ","))
    bool declaration = 0
    for size_t i = 0; i < items.n; ++i
      if nc_is(items.v[i], ":") && (!i || !nc_is(items.v[i - 1], ":")) && (i + 1 == items.n || !nc_is(items.v[i + 1], ":"))
        declaration = 1
    if declaration
      < nc_format(c, "%s;", nc_words(c, nc_lex(c, nc_typed(c, ts, 1), line.line)))
  if items.v[0].kind == NC_DIRECTIVE
    < nc_join(c, ts)
  < nc_format(c, "%s;", nc_trim(c, nc_words(c, ts)))
