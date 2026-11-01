// Prepares lines before the tree is built.
@use "nanoc/nanoc"
// Tells if a line extends C.
@f nc_extension_line(NcLayoutLine line) bool
  usize i = 0
  while i < line.ts.n and line.ts.v[i].kind == NC_SPACE
    ++i
  if i == line.ts.n || !nc_is(line.ts.v[i++], "@")
    return false
  while i < line.ts.n and line.ts.v[i].kind == NC_SPACE
    ++i
  i < line.ts.n and line.ts.v[i].kind == NC_WORD
// Tells if a line is meta.
@f nc_meta_line(NcLayoutLine line) bool
  usize i = 0
  while i < line.ts.n and line.ts.v[i].kind == NC_SPACE
    ++i
  if i == line.ts.n || !nc_is(line.ts.v[i++], "@")
    return false
  while i < line.ts.n and line.ts.v[i].kind == NC_SPACE
    ++i
  if i == line.ts.n
    return false
  NcToken t = line.ts.v[i]
  nc_is(t, "ct") || nc_is(t, "bt") || nc_is(t, "m") || nc_is(t, "macro")
// Marks lines before tree building.
@f nc_prepare_lines(NcContext *ctx, NcLines input, bool program) NcLines
  NcLines out = {0}
  int match_at = -1, arm_at = -1
  for usize i = 0; i < input.n; ++i
    NcLayoutLine line = input.v[i]
    if line.indent <= match_at
      match_at = arm_at = -1
    bool block = i + 1 < input.n and input.v[i + 1].indent > line.indent
    bool ext = block and nc_extension_line(line)
    bool meta = nc_meta_line(line) or ext
    if !program and meta
      NcBuffer raw = {0}
      nc_printf(ctx, &raw, "%s\n", nc_join(ctx, line.ts))
      while i + 1 < input.n and input.v[i + 1].indent > line.indent
        NcLayoutLine child = input.v[++i]
        nc_printf(ctx, &raw, "%*s%s\n", child.indent - line.indent, "", nc_join(ctx, child.ts))
      line.ts = nc_lex(ctx, raw.v, line.line)
      line.raw = true
      NC_PUSH(ctx, out, line)
      continue
    NcTokens ts = nc_significant(ctx, line.ts)
    if !ts.n
      continue
    NcToken first = ts.v[0], last = ts.v[ts.n - 1]
    bool control = (nc_is(first, "if") || nc_is(first, "elif") || nc_is(first, "else")
      || nc_is(first, "while") || nc_is(first, "for") || (nc_is(first, "loop") && ts.n == 1)
      || ((nc_is(first, "unless") || nc_is(first, "until")) && ts.n > 1 && !nc_is(ts.v[1], "=")))
    bool arm = match_at >= 0 and line.indent == arm_at
    if nc_is(first, "match") && block && ts.n > 1 && !program
      match_at = line.indent
      arm_at = input.v[i + 1].indent
      control = true
    if arm
      control = true
    bool function = (program && (nc_is(first, "f") || nc_is(first, "fn")) && ts.n >= 2
      and ts.v[1].kind == NC_WORD)
    bool expression = false
    if function
      for usize j = 0; j < ts.n; ++j
        if nc_is(ts.v[j], "=") || nc_is(ts.v[j], "=>")
          expression = true
    if ((control || (function && !expression)) && !nc_is(last, ":")
      && (block || (!nc_is(last, "}") && !nc_is(last, ";"))))
      NcTokens copy = {0}
      for usize j = 0; j < line.ts.n; ++j
        NC_PUSH(ctx, copy, line.ts.v[j])
      NC_PUSH(ctx, copy, nc_token(":", line.line, NC_PUNCT))
      line.ts = copy
    NC_PUSH(ctx, out, line)
  out
