// Pretty printer: readable, indented C.
#include "nanoc/nanoc.h"
// Handles whitespace and comments between tokens.
@f space(NcPretty *p, NcToken t) static void
  if t.s[0] == '/'
    NcToken none = {"", 0, t.line, 0, NC_PUNCT}
    nc_pp_resolve(p, none)
    if p->last_dir && !p->top && !p->paren
      nc_pp_blank(p)
    p->last_dir = false
    p->space = true
    p->comment = true
    size_t n = t.n
    while n && isspace((unsigned char)t.s[n - 1])
      --n
    nc_pp_put(p, t.s, n)
    if t.s[1] == '/'
      if p->paren
        nc_pp_nl(p)
      else
        nc_pp_end(p)
    return
  size_t lines = 0
  for size_t i = 0; i < t.n; ++i
    lines += t.s[i] == '\n'
  p->space = true
  if (lines > 1 && !p->top && !p->paren && p->stmt
    && !p->comment)
    p->gap = true
// Handles ";" and ",".
@f separator(NcPretty *p, NcToken t) static void
  bool init = p->top && p->kind[p->top - 1] == 'i'
  nc_pp_put(p, t.s, 1)
  if t.s[0] == ';'
    p->ternary = 0
    p->kw_type = false
    p->kw_enum = false
    if !p->paren && !init
      p->stmt = true
      nc_pp_end(p)
  elif !p->paren && p->top && p->kind[p->top - 1] == 'e'
    nc_pp_end(p)
  elif (p->paren || init) && p->col > 90
    nc_pp_nl(p)
    p->cont = true
// Handles ":" (case labels and ternaries).
@f colon(NcPretty *p, NcToken t) static void
  nc_pp_put(p, t.s, 1)
  if p->ternary > 0
    --p->ternary
  elif p->in_case && !p->paren && p->top
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
    if !p->top && !p->paren
      nc_pp_blank(p)
  if p->gap && p->out.n && !p->paren
    nc_pp_blank(p)
  p->gap = false
  p->comment = false
  bool punct = t.kind == NC_PUNCT && t.n == 1
  char ch = punct ? t.s[0] : 0
  if ((ch && strchr(")],;", ch)) || nc_pp_prev_punct(p, "(")
    || nc_pp_prev_punct(p, "["))
    p->space = false
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
          p->cases[p->top - 1] = false
          --p->ind
        p->in_case = true
      elif nc_is(t, "struct") || nc_is(t, "union") || nc_is(t, "enum")
        p->kw_type = true
        p->kw_enum = nc_is(t, "enum")
    if ch == '?'
      ++p->ternary
    if ch == '('
      p->ctl[p->paren & 255] = (nc_pp_prev_is(p, "if") || nc_pp_prev_is(p, "for") || nc_pp_prev_is(p, "while") || nc_pp_prev_is(p, "switch"))
      ++p->paren
    elif ch == ')' && p->paren
      --p->paren
      p->ctl[255] = p->ctl[p->paren & 255]
    nc_pp_put(p, t.s, t.n)
  if t.kind != NC_SPACE
    p->prev = t
    p->has_prev = true
  if !punct || (ch != ';' && ch != '{' && ch != '}' && ch != ':')
    p->stmt = false
// Formats C text with indentation and line breaks.
@f nc_pretty(NcContext *c, const char *text) char *
  NcPretty state = {0}
  NcPretty *p = &state
  p->c = c
  p->bol = true
  p->stmt = true
  NcTokens ts = nc_lex(c, text, 1)
  for size_t i = 0; i < ts.n; ++i
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
  p->out.v
