// The defer statement: runs a statement when its block ends or the function returns.
@use "nanoc/nanoc"
// Tells if the current function returns nothing.
@f is_void(NcContext *c) static bool
  c->ret_type && strstr(c->ret_type, "void") && !strchr(c->ret_type, '*')
// The return type without storage qualifiers, usable for a temporary.
@f value_type(NcContext *c) static char *
  char *t = c->ret_type ? c->ret_type : ""
  const char *q[] = {"static ", "inline ", "extern ", "_Noreturn "}
  for usize i = 0; i < 4; ++i
    while !strncmp(t, q[i], strlen(q[i]))
      t += strlen(q[i])
  t
// Wraps "return x;" so pending deferred statements run after x is computed.
@f nc_defer_return(NcContext *c, char *s) char *
  if !c->defers || strncmp(s, "return", 6) || (s[6] != ' ' && s[6] != ';')
    return s
  usize n = strlen(s)
  char *expr = nc_trim(c, nc_string(c, s + 6, n - 7))
  if !*expr or is_void(c)
    return nc_format(c, "{ %s return %s; }", c->defers, expr)
  char *tmp = nc_fresh(c, "ret")
  nc_format(c, "{ %s %s = (%s); %s return %s; }", value_type(c), tmp, expr, c->defers, tmp)
// Emits "defer stmt" at nodes[at]: the rest of the block becomes a scope that ends with the statement.
@f nc_emit_defer(NcContext *c, NcBuffer *out, NcNodes nodes, usize at, bool tail, usize depth) void
  NcLayoutLine line = nodes.v[at].head
  usize k = 0
  while line.ts.v[k].kind == NC_SPACE
    ++k
  line.ts = nc_slice(line.ts, k + 1, line.ts.n)
  if !line.ts.n
    nc_fail(c, line.line, "defer needs a statement")
  char *saved = c->defers, *stmt = nc_statement(c, line, false)
  c->defers = nc_format(c, "%s%s ", stmt, saved ? saved : "")
  NcNodes rest = {nodes.v + at + 1, nodes.n - at - 1, 0}
  nc_marker(c, out, line.line)
  nc_add(c, out, "{")
  nc_add(c, out, nc_emit_block(c, rest, tail, depth + 1))
  if !tail or is_void(c)
    nc_printf(c, out, "%s", c->defers)
  c->defers = saved
  nc_add(c, out, "}\n")
