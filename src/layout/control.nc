// Control statements: if, for, while.
// Tells if one parenthesis pair spans all of s.
@f enclosed(cstr s) static bool
  if *s != '(' then return false
  int depth = 0
  for usize i = 0; s[i]; ++i
    if s[i] == '"' || s[i] == '\''
      char quote = s[i++]
      while s[i] and s[i] != quote then i += s[i] == '\\' && s[i + 1] ? 2 : 1
      if !s[i] then return false
    elif s[i] == '('
      ++depth
    elif s[i] == ')' && --depth == 0 then return !s[i + 1]
  false
// Wraps a condition in parentheses unless already wrapped.
@f paren(NcContext *ctx, cstr s) static char * = enclosed(s) ? nc_format(ctx, "%s", s) : nc_format(ctx, "(%s)", s)
// Rewrites a control statement.
@f nc_control(NcContext *ctx, NcTokens ts, int line) char *
  char *source = nc_trim(ctx, nc_words(ctx, ts))
  usize len = strlen(source)
  if not len then nc_fail(ctx, line, "empty control header")
  char *header = nc_trim(ctx, nc_string(ctx, source, source[len - 1] == ':' ? len - 1 : len))
  NcCursor c = {ctx, nc_lex(ctx, header, line), 0}
  char *name = nc_name(&c)
  char *rest = nc_trim(ctx, nc_join(ctx, nc_slice(c.ts, c.pos, c.ts.n)))
  if !strcmp(name, "if") || !strcmp(name, "while") || !strcmp(name, "elif")
    if !*rest then nc_fail(ctx, line, "missing condition")
    return nc_format(ctx, "%s %s", !strcmp(name, "elif") ? "else if" : name, paren(ctx, rest))
  if !strcmp(name, "unless") || !strcmp(name, "until")
    if !*rest then nc_fail(ctx, line, "missing condition")
    return nc_format(ctx, "%s (!(%s))", name[1] == 'n' && name[2] == 'l' ? "if" : "while", rest)
  if !strcmp(name, "loop") then return nc_format(ctx, "for (;;)")
  if !strcmp(name, "else")
    if nc_eat(&c, "if") then return nc_format(ctx, "else if %s", paren(ctx, nc_join(ctx, nc_slice(c.ts, c.pos, c.ts.n))))
    if *rest then nc_fail(ctx, line, "else takes no condition")
    return "else"
  if !strcmp(name, "for")
    if nc_at(&c, "(") then return nc_format(ctx, "for %s", rest)
    for usize i = c.pos; i < c.ts.n; ++i
      if nc_is(c.ts.v[i], ";") then return nc_format(ctx, "for (%s)", rest)
    char *id = nc_name(&c), *type = "int"
    bool typed = nc_eat(&c, ":")
    if typed then type = nc_alias_name(ctx, nc_name(&c))
    (void)nc_eat(&c, "in")
    char *bounds = nc_join(ctx, nc_slice(c.ts, c.pos, c.ts.n))
    bool range = false
    for usize i = c.pos; i < c.ts.n; ++i
      if nc_is(c.ts.v[i], "..") then range = true
    if ctx->cpp and !range
      return nc_format(ctx, "for (%s%s %s : %s)", typed ? type : "auto", typed ? "&" : "&&", id,
        bounds)
    NcBuffer out = {0}
    for usize i = 0; bounds[i]; ++i
      if !strncmp(bounds + i, "..<", 3) then nc_add(ctx, &out, ".."); i += 2
      else nc_addn(ctx, &out, bounds + i, 1)
    nc_add(ctx, &out, "")
    return nc_format(ctx, "@for (%s %s in %s)", type, id, out.v)
  nc_fail(ctx, line, "unsupported block header: %s", name)
  nil
