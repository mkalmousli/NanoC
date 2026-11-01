// Brace handling for the pretty C printer.
@use "nanoc/nanoc"
// Tells if the previous token is the word s.
@f nc_pp_prev_is(NcPretty *p, cstr s) bool
  p->has_prev and p->prev.kind == NC_WORD and nc_is(p->prev, s)
// Tells if the previous token is the punctuation s.
@f nc_pp_prev_punct(NcPretty *p, cstr s) bool
  p->has_prev and p->prev.kind == NC_PUNCT and nc_is(p->prev, s)
// Classifies a "{": 'b' block, 't' type body, 'e' enum, 'i' init.
@f brace_kind(NcPretty *p) static char
  if p->paren || (p->top && p->kind[p->top - 1] == 'i')
    return 'i'
  if !p->has_prev || nc_pp_prev_is(p, "else") || nc_pp_prev_is(p, "do")
    return 'b'
  if (nc_pp_prev_punct(p, ";") || nc_pp_prev_punct(p, "{") || nc_pp_prev_punct(p, "}")
    || nc_pp_prev_punct(p, ":"))
    return 'b'
  if nc_pp_prev_punct(p, ")")
    return p->ctl[255] || !p->top ? 'b' : 'i'
  if p->kw_type and p->prev.kind == NC_WORD
    return p->kw_enum ? 'e' : 't'
  if !p->top and p->prev.kind == NC_LITERAL
    return 'b'
  'i'
// Handles an opening brace.
@f nc_pp_open(NcPretty *p, NcToken t) void
  if p->top == 255
    nc_fail(p->c, t.line, "braces nested too deeply")
  char kind = brace_kind(p)
  p->kind[p->top] = kind
  p->cases[p->top] = false
  p->dos[p->top] = nc_pp_prev_is(p, "do")
  ++p->top
  if kind == 'i'
    nc_pp_put(p, "{", 1)
    return
  p->space = !p->bol
  nc_pp_put(p, "{", 1)
  ++p->ind
  p->stmt = true
  p->kw_type = false
  p->kw_enum = false
  nc_pp_end(p)
// Handles a closing brace; returns what to do after it.
@f nc_pp_close(NcPretty *p) void
  if !p->top
    nc_pp_put(p, "}", 1)
    return
  --p->top
  char kind = p->kind[p->top]
  if kind == 'i'
    nc_pp_put(p, "}", 1)
    return
  if p->cases[p->top]
    --p->ind
  --p->ind
  nc_pp_end(p)
  nc_pp_put(p, "}", 1)
  p->stmt = kind == 'b'
  p->after = kind != 'b' ? 3 : p->dos[p->top] ? 2 : !p->top ? 4 : 1
// Decides the line break owed after a block's closing brace.
@f nc_pp_resolve(NcPretty *p, NcToken t) void
  int after = p->after
  p->after = 0
  if after == 0 or after == 3
    return
  bool word = t.kind == NC_WORD
  if (after == 1 && word && nc_is(t, "else")) || (after == 2 && word && nc_is(t, "while"))
    p->space = true
    return
  nc_pp_end(p)
  if after == 4
    nc_pp_blank(p)
