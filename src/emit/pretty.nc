// Pretty printer: readable, indented C.
@use "nanoc/nanoc"
// Handles whitespace and comments between tokens.
@f space(NcPretty *p, NcToken t) static void
  if t.s[0] == '/'
    NcToken none = {"", 0, t.line, 0, NC_PUNCT}
    nc_pp_resolve(p, none)
    if p->last_dir and !p->top and !p->paren then nc_pp_blank(p)
    p->last_dir = false
    p->space = true
    p->comment = true
    usize n = t.n
    while n and isspace((u8)t.s[n - 1]) then --n
    nc_pp_put(p, t.s, n)
    if t.s[1] == '/'
      if p->paren then nc_pp_nl(p)
      else nc_pp_end(p)
    return
  usize lines = 0
  for i:usize in 0..t.n then lines += t.s[i] == '\n'
  p->space = true
  if lines > 1 and !p->top and !p->paren and p->stmt and !p->comment then p->gap = true
// Handles ";" and ",".
@f separator(NcPretty *p, NcToken t) static void
  bool init = p->top && p->kind[p->top - 1] == 'i'
  nc_pp_put(p, t.s, 1)
  if t.s[0] == ';'
    p->ternary = 0
    p->kw_type = false
    p->kw_enum = false
    if !p->paren and !init
      p->stmt = true
      nc_pp_end(p)
  elif !p->paren && p->top && p->kind[p->top - 1] == 'e' then nc_pp_end(p)
  elif (p->paren or init) and p->col > 90
    nc_pp_nl(p)
    p->cont = true
// Handles ":" (case labels and ternaries).
@f colon(NcPretty *p, NcToken t) static void
  nc_pp_put(p, t.s, 1)
  if p->ternary > 0 then --p->ternary
  elif p->in_case and !p->paren and p->top
    p->in_case = false
    p->cases[p->top - 1] = true
    ++p->ind
    p->stmt = true
    nc_pp_end(p)
// Handles one significant token.
@f nc_pp_token(NcPretty *p, NcToken t) static void
  if t.kind == NC_DIRECTIVE
    nc_pp_directive(p, t)
    return
  nc_pp_resolve(p, t)
  if p->last_dir
    p->last_dir = false
    if !p->top and !p->paren then nc_pp_blank(p)
  if p->gap and p->out.n and !p->paren then nc_pp_blank(p)
  p->gap = false
  p->comment = false
  bool punct = t.kind == NC_PUNCT and t.n == 1
  char ch = punct ? t.s[0] : 0
  if (ch && strchr(")],;", ch)) || nc_pp_prev_punct(p, "(") || nc_pp_prev_punct(p, "[") then p->space = false
  if ch == '{' then nc_pp_open(p, t)
  elif ch == '}' then nc_pp_close(p)
  elif ch == ';' || ch == ',' then separator(p, t)
  elif ch == ':' then colon(p, t)
  else
    if t.kind == NC_WORD and !p->paren
      if p->stmt && (nc_is(t, "case") || nc_is(t, "default"))
        if p->top and p->cases[p->top - 1]
          p->cases[p->top - 1] = false
          --p->ind
        p->in_case = true
      elif nc_is(t, "struct") || nc_is(t, "union") || nc_is(t, "enum")
        p->kw_type = true
        p->kw_enum = nc_is(t, "enum")
    if ch == '?'
      ++p->ternary
    if ch == '('
      p->ctl[
        p->paren & 255] = (nc_pp_prev_is(p, "if") || nc_pp_prev_is(p, "for")
        || nc_pp_prev_is(p, "while") || nc_pp_prev_is(p, "switch"))
      ++p->paren
    elif ch == ')' && p->paren
      --p->paren
      p->ctl[255] = p->ctl[p->paren & 255]
    nc_pp_put(p, t.s, t.n)
  if t.kind != NC_SPACE
    p->prev = t
    p->has_prev = true
  if !punct || (ch != ';' && ch != '{' && ch != '}' && ch != ':') then p->stmt = false
// Formats C text with indentation and line breaks.
@f nc_pretty(NcContext *c, cstr text) char *
  NcPretty state = {0}
  NcPretty *p = &state
  p->c = c
  p->bol = true
  p->stmt = true
  NcTokens ts = nc_lex(c, text, 1)
  for i:usize in 0..ts.n
    if ts.v[i].kind == NC_SPACE then space(p, ts.v[i])
    else nc_pp_token(p, ts.v[i])
  if p->after == 4 then p->after = 1
  if ts.n then nc_pp_resolve(p, ts.v[0])
  nc_pp_nl(p)
  nc_add(c, &p->out, "")
  p->out.v
