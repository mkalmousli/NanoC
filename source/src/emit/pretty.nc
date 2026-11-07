// Pretty printer: readable, indented C.
@lang 1
+ "nanoc/nanoc.h"

extern int nc_std;
// Handles whitespace and comments between tokens.
f space(NcPretty *p, NcToken t) static void
  if t.s[0] == '/'
    NcToken none = {"", 0, t.line, 0, NC_PUNCT}
    nc_pp_resolve(p, none)
    if p->last_dir && !p->top && !p->paren
      nc_pp_blank(p)
    p->last_dir = 0
    if p->gap && p->out.n && !p->paren
      nc_pp_blank(p)
    p->gap = 0
    p->space = 1
    p->comment = 1
    size_t n = t.n
    while n && isspace((unsigned char)t.s[n - 1])
      --n
    if nc_std == 89 && t.s[1] == '/'
      char *body = nc_string(p->c, t.s + 2, n > 2 ? n - 2 : 0)
      for size_t k = 0; body[k] && body[k + 1]; ++k
        if body[k] == '*' && body[k + 1] == '/'
          body[k + 1] = ' '
      char *comment = nc_format(p->c, "/*%s */", body)
      nc_pp_put(p, comment, strlen(comment))
    else
      nc_pp_put(p, t.s, n)
    if t.s[1] == '/'
      if p->paren
        nc_pp_nl(p)
      else
        nc_pp_end(p)
    <
  size_t lines = 0
  for size_t i = (0), nanoc_bound_1 = (t.n); i < nanoc_bound_1; ++i
    lines += t.s[i] == '\n'
  p->space = 1
  if lines > 1 && !p->top && !p->paren && p->stmt && !p->comment
    p->gap = 1

// Handles ";" and ",".
f separator(NcPretty *p, NcToken t) static void
  bool init = p->top && p->kind[p->top - 1] == 'i'
  nc_pp_put(p, t.s, 1)
  if t.s[0] == ';'
    p->ternary = 0
    p->kw_type = 0
    p->kw_enum = 0
    if !p->paren && !init
      p->stmt = 1
      nc_pp_end(p)
  elif !p->paren && p->top && p->kind[p->top - 1] == 'e'
    nc_pp_end(p)
  elif (p->paren || init) && p->col > 90
    nc_pp_nl(p)
    p->cont = 1

// Handles ":" (case labels and ternaries).
f colon(NcPretty *p, NcToken t) static void
  nc_pp_put(p, t.s, 1)
  if p->ternary > 0
    --p->ternary
  elif p->in_case && !p->paren && p->top
    p->in_case = 0
    p->cases[p->top - 1] = 1
    ++p->ind
    p->stmt = 1
    nc_pp_end(p)

// Handles one significant token.
f nc_pp_token(NcPretty *p, NcToken t) static void
  if t.kind == NC_DIRECTIVE
    nc_pp_directive(p, t)
    <
  nc_pp_resolve(p, t)
  if p->last_dir
    p->last_dir = 0
    if !p->top && !p->paren
      nc_pp_blank(p)
  if p->gap && p->out.n && !p->paren
    nc_pp_blank(p)
  p->gap = 0
  p->comment = 0
  bool punct = t.kind == NC_PUNCT && t.n == 1
  char ch = punct ? t.s[0] : 0
  if (ch && strchr(")],;", ch)) || nc_pp_prev_punct(p, "(") || nc_pp_prev_punct(p, "[")
    p->space = 0
  if ch == '{'
    nc_pp_open(p, t)
  elif ch == '}'
    nc_pp_close(p)
  elif ch == ';' || ch == ','
    separator(p, t)
  elif ch == ':'
    colon(p, t)
  else
    if t.kind == NC_WORD && !p->paren
      if p->stmt && (nc_is(t, "case") || nc_is(t, "default"))
        if p->top && p->cases[p->top - 1]
          p->cases[p->top - 1] = 0
          --p->ind
        p->in_case = 1
      elif nc_is(t, "struct") || nc_is(t, "union") || nc_is(t, "enum")
        p->kw_type = 1
        p->kw_enum = nc_is(t, "enum")
    if ch == '?'
      ++p->ternary
    if ch == '('
      p->ctl[
                          p->paren & 255] = (nc_pp_prev_is(p, "if") || nc_pp_prev_is(p, "for") || nc_pp_prev_is(p, "while") || nc_pp_prev_is(p, "switch"))
      ++p->paren
    elif ch == ')' && p->paren
      --p->paren
      p->ctl[255] = p->ctl[p->paren & 255]
    nc_pp_put(p, t.s, t.n)
  if t.kind != NC_SPACE
    p->prev = t
    p->has_prev = 1
  if !punct || (ch != ';' && ch != '{' && ch != '}' && ch != ':')
    p->stmt = 0

// Formats C text with indentation and line breaks.
f nc_pretty(NcContext *c, const char *text) char *
  NcPretty state = {0}
  NcPretty *p = &state
  p->c = c
  p->bol = 1
  p->stmt = 1
  NcTokens ts = nc_lex(c, text, 1)
  for size_t i = (0), nanoc_bound_2 = (ts.n); i < nanoc_bound_2; ++i
    if nc_trace_boundary(c, &p->out, ts.v[i])
      ^
    if nc_emit_raw(c, &p->out, ts.v[i])
      p->bol = 1
      p->space = 0
      p->after = 0
      p->has_prev = 0
      p->stmt = 1
      ^
    if ts.v[i].kind == NC_SPACE
      space(p, ts.v[i])
    else
      nc_pp_token(p, ts.v[i])
  if p->after == 4
    p->after = 1
  if ts.n
    nc_pp_resolve(p, ts.v[0])
  nc_pp_nl(p)
  nc_add(c, &p->out, "")
  < p->out.v
