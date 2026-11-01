// The match statement: a switch whose arms are "values" blocks, with else as default.
@use "nanoc/nanoc"
// Tokens of a header line without its closing colon.
@f bare(NcContext *c, NcLayoutLine line) static NcTokens
  NcTokens ts = nc_significant(c, line.ts)
  if ts.n && nc_is(ts.v[ts.n - 1], ":")
    --ts.n
  ts
// Emits "match x" with arms "a, b" (indented bodies) and an optional "else" arm.
@f nc_match(NcContext *c, NcNode node, usize depth) char *
  NcTokens head = bare(c, node.head)
  char *subject = nc_trim(c, nc_join(c, nc_slice(head, 1, head.n)))
  NcBuffer out = {0}
  nc_printf(c, &out, "switch (%s) {\n", subject)
  for i:usize in 0..node.children.n
    NcNode arm = node.children.v[i]
    NcTokens labels = bare(c, arm.head)
    if labels.n == 1 && nc_is(labels.v[0], "else")
      nc_add(c, &out, "default:")
    else
      NcGroups items = nc_split(c, labels, ",")
      for k:usize in 0..items.n
        nc_printf(c, &out, "case %s:", nc_trim(c, nc_join(c, items.v[k])))
    nc_printf(c, &out, " {%s} break;\n", nc_emit_block(c, arm.children, false, depth + 1))
  nc_add(c, &out, "}\n")
  out.v
