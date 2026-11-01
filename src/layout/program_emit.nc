// Emits meta programs as text.
// Tells if the node starts with word.
@f starts(NcContext *c, NcNode n, cstr word) static bool
  NcTokens ts = nc_significant(c, n.head.ts)
  ts.n and nc_is(ts.v[0], word)
// Tells if the node is a function.
@f function_node(NcContext *c, NcNode n) static bool
  NcTokens ts = nc_significant(c, n.head.ts)
  ts.n > 1 && ts.v[1].kind == NC_WORD && (nc_is(ts.v[0], "f") || nc_is(ts.v[0], "fn"))
// Tells if a line is a value.
@f value_line(NcContext *c, NcTokens ts) static bool
  NcTokens sig = nc_significant(c, ts)
  if not sig.n then return false
  const char *statements[] = {"emit", "log", "assert", "write", "mkdir", "remove", "again",
    "rewrite", "put"}
  for size_t i = 0; i < sizeof statements / sizeof *statements; ++i
    if nc_is(sig.v[0], statements[i]) then return false
  int level = 0
  for i:usize in 0..sig.n
    NcToken t = sig.v[i]
    if nc_is(t, "(") || nc_is(t, "[") || nc_is(t, "{")
      ++level
    elif nc_is(t, ")") || nc_is(t, "]") || nc_is(t, "}") then --level
    elif (!level
      and (
        nc_is(t, ":=") || nc_is(t, "=") || nc_is(t, "++") || nc_is(t, "--")
        || (t.n == 2 && t.s[1] == '=' && strchr("+-*/%", t.s[0]))))
      return false
  bool function = (sig.n > 1 and sig.v[1].kind == NC_WORD
    && (nc_is(sig.v[0], "f") || nc_is(sig.v[0], "fn")))
  !function && !nc_is(sig.v[0], "return") && !nc_is(sig.v[0], "=>") && !nc_is(sig.v[0],
    "break") && !nc_is(sig.v[0], "continue") && !nc_is(sig.v[0], "let") && !nc_is(sig.v[0],
    "if") && !nc_is(sig.v[0], "for") && !nc_is(sig.v[0], "while")
// Emits nodes as program text.
@f nc_emit_program(NcContext *ctx, NcNodes nodes, bool tail, usize depth) char *
  nc_depth(ctx, depth, nodes.n ? nodes.v[0].head.line : 1, "program layout")
  NcBuffer out = {0}
  int line = nodes.n ? nodes.v[0].head.line : 1
  for i:usize in 0..nodes.n
    NcNode n = nodes.v[i]
    while line < n.head.line
      nc_add(ctx, &out, "\n")
      ++line
    usize start = out.n
    if not n.children.n
      NcTokens ts = n.head.ts
      char *text = nc_trim(ctx, nc_join(ctx, ts))
      bool function = function_node(ctx, n)
      bool returning = tail and i + 1 == nodes.n and value_line(ctx, ts)
      nc_printf(ctx, &out, "%s%s%s\n", returning ? "return " : "", text,
        *text && text[strlen(text) - 1] == '}' && function ? "" : ";")
    else
      bool function = function_node(ctx, n)
      bool loop = starts(ctx, n, "for") || starts(ctx, n, "while")
      bool has_next_branch = (i + 1 < nodes.n
        && (starts(ctx, nodes.v[i + 1], "elif") || starts(ctx, nodes.v[i + 1], "else")))
      bool last = tail and !loop and (i + 1 == nodes.n or has_next_branch)
      char *header = nc_program_control(ctx, n.head.ts, n.head.line)
      nc_printf(ctx, &out, "%s {\n", header)
      for int pad = n.head.line + 1; pad < n.children.v[0].head.line; ++pad then nc_add(ctx, &out, "\n")
      char *body = nc_emit_program(ctx, n.children, function or last, depth + 1)
      usize size = strlen(body)
      if size && body[size - 1] == '\n' then --size
      nc_addn(ctx, &out, body, size)
      nc_add(ctx, &out, "}\n")
    for j:usize in start..out.n
      if out.v[j] == '\n'
        ++line
    nc_check(ctx, out.n, n.head.line)
  nc_add(ctx, &out, "")
  out.v
