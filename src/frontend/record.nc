// Compact @s struct, @u union and @e enum declarations.
@use "nanoc/nanoc"
// Rest of the current line as tokens, up to a newline.
@f rest_of_line(NcCursor *c) static NcTokens
  NcTokens ts = {0}
  while c->pos < c->ts.n
    NcToken t = c->ts.v[c->pos]
    if t.kind == NC_SPACE && memchr(t.s, '\n', t.n)
      break
    NC_PUSH(c->ctx, ts, t)
    ++c->pos
  ts
// One field "names:type" or "type names" as a C declaration with its semicolon.
@f field_text(NcContext *ctx, NcTokens ts) static char *
  NcGroups parts = nc_split(ctx, nc_aliased(ctx, ts), ":")
  char *text = nc_trim(ctx, nc_join(ctx, ts))
  if parts.n != 2
    return *text ? nc_format(ctx, "%s;", nc_trim(ctx, nc_join(ctx, nc_aliased(ctx, ts)))) : ""
  char *type = nc_trim(ctx, nc_join(ctx, parts.v[1])), *stars = nc_format(ctx, "")
  while *type == '*'
    stars = nc_format(ctx, "%s*", stars)
    ++type
  NcGroups names = nc_split(ctx, parts.v[0], ",")
  NcBuffer out = {0}
  nc_printf(ctx, &out, "%s ", nc_trim(ctx, type))
  for size_t i = 0; i < names.n; ++i
    nc_printf(ctx, &out, "%s%s%s", i ? "," : "", stars, nc_trim(ctx, nc_join(ctx, names.v[i])))
  nc_add(ctx, &out, ";")
  out.v
// Field declarations of an @s/@u record, from the header line or its indented body.
@f record_fields(NcContext *ctx, NcCursor *c, NcHeader h, NcTokens head) static char *
  NcBuffer out = {0}
  if head.n
    NcGroups fs = nc_split(ctx, head, ";")
    for size_t i = 0; i < fs.n; ++i
      nc_add(ctx, &out, field_text(ctx, fs.v[i]))
    return out.v
  NcLines lines = nc_body_lines(c, h.line, h.indent)
  for size_t i = 0; i < lines.n; ++i
    nc_add(ctx, &out, field_text(ctx, lines.v[i].ts))
  out.v
// Expands "@s Name fields", "@u Name fields" or "@e Name items" (or the indented block form).
@f nc_record(NcContext *ctx, NcCursor *c, char kind) char *
  NcHeader h = nc_header(c)
  char *name = nc_name(c)
  NcTokens head = rest_of_line(c)
  if kind == 'e'
    NcBuffer items = {0}
    if head.n
      nc_add(ctx, &items, nc_join(ctx, head))
    else
      NcLines lines = nc_body_lines(c, h.line, h.indent)
      for size_t i = 0; i < lines.n; ++i
        nc_printf(ctx, &items, "%s%s", i ? "," : "", nc_join(ctx, lines.v[i].ts))
    return nc_format(ctx, "typedef enum { %s } %s;\n", items.v ? items.v : "", name)
  const char *word = kind == 's' ? "struct" : "union"
  nc_format(ctx, "typedef %s %s %s;\n%s %s { %s };\n", word, name, name, word, name,
    record_fields(ctx, c, h, head))
