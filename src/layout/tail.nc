// Implicit results from final value expressions in non-void runtime functions.
@lang 1
+ "nanoc/nanoc.h"

// Recognizes void return types even when storage or function specifiers precede them.
f nc_void_type(NcContext *c, const char *type) bool
  NcTokens ts = nc_significant(c, nc_lex(c, type, 1))
  < ts.n && nc_is(ts.v[ts.n - 1], "void")

// Distinguishes value expressions from declarations, directives and explicit statements.
f nc_tail_value(NcContext *c, NcTokens input) bool
  NcTokens ts = nc_significant(c, input)
  if !ts.n
    < 0
  if ts.n == 1 && (nc_is(ts.v[0], "!") || nc_is(ts.v[0], "^"))
    < 0
  if nc_is(ts.v[ts.n - 1], ";")
    < 0
  const char *excluded[] = {
    "<", "@", "+", "$", "return", "break", "continue", "goto",
    "if", "elif", "else", "for", "while", "do", "switch", "typedef",
    "struct", "union", "enum", "const", "static", "volatile", "int",
    "char", "float", "double", "long", "short", "unsigned", "signed", "void", "bool", "size_t"
  }
  for size_t i = 0; i < sizeof excluded / sizeof *excluded; ++i
    if nc_is(ts.v[0], excluded[i])
      < 0
  if ts.v[0].kind == NC_DIRECTIVE
    < 0
  if ts.n > 1 && ts.v[0].kind == NC_WORD && ts.v[1].kind == NC_WORD && !nc_is(ts.v[0], "sizeof")
    < 0
  int nesting = 0, ternary = 0
  for size_t i = 0; i < ts.n; ++i
    NcToken t = ts.v[i]
    if nc_is(t, "(") || nc_is(t, "[") || nc_is(t, "{")
      ++nesting
    elif nc_is(t, ")") || nc_is(t, "]") || nc_is(t, "}")
      --nesting
    elif !nesting && nc_is(t, "?")
      ++ternary
    elif !nesting && nc_is(t, ":") && ((i && nc_is(ts.v[i - 1], ":")) || (i + 1 < ts.n && nc_is(ts.v[i + 1], ":")))
      ^
    elif !nesting && nc_is(t, ":") && ternary
      --ternary
    elif !nesting && (nc_is(t, ":") || nc_is(t, ":=") || nc_is(t, "=") || nc_is(t, "++") || nc_is(t, "--"))
      < 0
  if ts.n > 1 && ts.v[0].kind == NC_WORD && nc_is(ts.v[1], "(")
    for size_t i = 0; i < c->symbols.n; ++i
      NcSymbol symbol = c->symbols.v[i]
      if nc_is(ts.v[0], symbol.name) && nc_void_type(c, symbol.returns)
        < 0
  < 1

// Adds returns only to final expressions and the final branches of a conditional chain.
f nc_runtime_tail(NcContext *c, NcNodes nodes)
  if !nodes.n
    <
  size_t i = nodes.n - 1
  NcNode *node = &nodes.v[i]
  NcTokens sig = nc_significant(c, node->head.ts)
  if !sig.n
    <
  if node->children.n
    if !nc_is(sig.v[0], "if") && !nc_is(sig.v[0], "elif") && !nc_is(sig.v[0], "else")
      <
    for ;;
      nc_runtime_tail(c, nodes.v[i].children)
      sig = nc_significant(c, nodes.v[i].head.ts)
      if !i || nc_is(sig.v[0], "if")
        !
      --i
    <
  if !node->head.raw && nc_tail_value(c, node->head.ts)
    node->head.ts = nc_lex(c, nc_format(c, "< %s", nc_join(c, node->head.ts)), node->head.line)
