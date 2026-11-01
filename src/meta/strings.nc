// String builtins.
@use "nanoc/nanoc"
// Runs string builtins.
@f nc_meta_strings(NcMachine *m, cstr name, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  nc_arity(c, a, (!strcmp(name, "replace") || !strcmp(name, "rename")) ? 3 : 2, line)
  cstr text = nc_meta_text(c, a.v[0], line)
  cstr needle = nc_meta_text(c, a.v[1], line)
  usize n = strlen(needle)
  if !strcmp(name, "rename")
    cstr to = nc_meta_text(c, a.v[2], line)
    if !nc_identifier(needle) or !nc_identifier(to)
      nc_fail(c, line, "rename expects identifier names")
    NcTokens ts = nc_lex(c, text, line)
    NcBuffer out = {0}
    for i:usize in 0..ts.n
      NcToken t = ts.v[i]
      nc_step(c, line)
      if t.kind == NC_WORD and nc_is(t, needle)
        nc_add(c, &out, to)
      else
        nc_addn(c, &out, t.s, t.n)
      nc_check(c, out.n, line)
    nc_add(c, &out, "")
    return nc_value_text(a.v[0].kind, out.v)
  if !strcmp(name, "find") || !strcmp(name, "contains")
    cstr found = strstr(text, needle)
    return (!strcmp(name, "contains") ? nc_boolean(found != NULL)
      : nc_integer(found ? found - text : -1))
  if not n
    nc_fail(c, line, "separator/search text must not be empty")
  if !strcmp(name, "split")
    NcValues list = {0}
    for ;;
      nc_step(c, line)
      cstr found = strstr(text, needle)
      NC_PUSH(c, list,
        nc_value_text(NC_STRING, nc_string(c, text, found ? (usize)(found - text) : strlen(text))))
      nc_check(c, list.n * 8, line)
      if not found
        break
      text = found + n
    return nc_list(list)
  cstr replacement = nc_meta_text(c, a.v[2], line)
  NcBuffer out = {0}
  for ;;
    nc_step(c, line)
    cstr found = strstr(text, needle)
    nc_addn(c, &out, text, found ? (usize)(found - text) : strlen(text))
    if found
      nc_add(c, &out, replacement)
    nc_check(c, out.n, line)
    if not found
      break
    text = found + n
  nc_value_text(a.v[0].kind, out.v)
