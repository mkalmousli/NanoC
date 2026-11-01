// The match statement: a switch whose arms are "values" blocks, with else as default.
// Tokens of a header line without its closing colon.
@f bare(NcContext *c, NcLayoutLine line) static NcTokens
  NcTokens ts = nc_significant(c, line.ts)
  if ts.n && nc_is(ts.v[ts.n - 1], ":") then --ts.n
  ts
// Tells if an arm body is simple statements that need no braces: no declarations and no blocks.
@f plain(NcContext *c, cstr body) bool
  if strchr(body, '{') then return false
  NcTokens ts = nc_significant(c, nc_lex(c, body, 1))
  for i:usize in 0..ts.n
    if ts.v[i].kind == NC_WORD and i + 1 < ts.n and (ts.v[i + 1].kind == NC_WORD or nc_is(ts.v[i + 1], "*")) and (!i or nc_is(ts.v[i - 1], ";")) then return false
  true
// Emits "match x" with arms "a, b" (indented bodies) and an optional "else" arm.
@f nc_match(NcContext *c, NcNode node, usize depth) char *
  NcTokens head = bare(c, node.head)
  char *subject = nc_trim(c, nc_join(c, nc_slice(head, 1, head.n)))
  NcBuffer out = {0}
  nc_printf(c, &out, "switch (%s) {\n", subject)
  for i:usize in 0..node.children.n
    NcNode arm = node.children.v[i]
    NcTokens labels = bare(c, arm.head)
    if labels.n == 1 && nc_is(labels.v[0], "else") then nc_add(c, &out, "default:")
    else
      NcGroups items = nc_split(c, labels, ",")
      for k:usize in 0..items.n then nc_printf(c, &out, "case %s:", nc_trim(c, nc_join(c, items.v[k])))
    char *body = nc_emit_block(c, arm.children, false, depth + 1)
    nc_printf(c, &out, plain(c, body) ? " %s break;\n" : " {%s} break;\n", body)
  nc_add(c, &out, "}\n")
  out.v
