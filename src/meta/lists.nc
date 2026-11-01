// List and slice builtins.
@use "nanoc/nanoc"
// Runs list builtins.
@f nc_meta_lists(NcMachine *m, cstr name, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  if !strcmp(name, "lex")
    nc_arity(c, a, 1, line)
    NcTokens ts = nc_lex(c, nc_meta_text(c, a.v[0], line), line)
    NcValues out = {0}
    for i:usize in 0..ts.n
      if ts.v[i].kind != NC_SPACE
        NC_PUSH(c, out, nc_value_text(NC_CODE, nc_text(c, ts.v[i])))
    nc_check(c, out.n * 8, line)
    return nc_list(out)
  if !strcmp(name, "slice")
    if a.n != 2 and a.n != 3
      nc_fail(c, line, "slice expects value,start[,end]")
    NcValue v = a.v[0]
    usize size = v.kind == NC_LIST ? v.count : strlen(nc_meta_text(c, v, line))
    int64_t start = nc_numeric(c, a.v[1], line)
    int64_t end = a.n == 3 ? nc_numeric(c, a.v[2], line) : (int64_t)size
    if start < 0 or end < start or (uint64_t)end > size
      nc_fail(c, line, "invalid slice bounds")
    if v.kind != NC_LIST
      return nc_value_text(v.kind, nc_string(c, v.text + start, (usize)(end - start)))
    NcValues out = {0}
    for usize i = (usize)start; i < (usize)end; ++i
      NC_PUSH(c, out, v.items[i])
    return nc_list(out)
  nc_arity(c, a, 2, line)
  if a.v[0].kind != NC_LIST
    nc_fail(c, line, "%s requires a list", name)
  if !strcmp(name, "push")
    NcValues out = {0}
    nc_check(c, (a.v[0].count + 1) * 8, line)
    for usize i = 0; i < a.v[0].count; ++i
      NC_PUSH(c, out, a.v[0].items[i])
    NC_PUSH(c, out, a.v[1])
    NcValue result = nc_list(out)
    if result.height > c->max_depth
      nc_fail(c, line, "value depth limit exceeded")
    return result
  cstr separator = nc_meta_text(c, a.v[1], line)
  NcBuffer b = {0}
  for usize i = 0; i < a.v[0].count; ++i
    nc_step(c, line)
    if i
      nc_add(c, &b, separator)
    nc_add(c, &b, nc_meta_text(c, a.v[0].items[i], line))
    nc_check(c, b.n, line)
  nc_add(c, &b, "")
  nc_value_text(NC_STRING, b.v)
