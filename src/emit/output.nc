// Low-level output for the pretty C printer.
@use "nanoc/nanoc"
// Writes text, indenting at the start of a line.
@f nc_pp_put(NcPretty *p, cstr s, usize n) void
  if p->bol
    usize width = (usize)(p->ind > 0 ? p->ind : 0) * 4
    if p->cont
      width += 8
    for i:usize in 0..width
      nc_add(p->c, &p->out, " ")
    p->col = width
    p->bol = false
  elif p->space
    nc_add(p->c, &p->out, " ")
    ++p->col
  p->space = false
  nc_addn(p->c, &p->out, s, n)
  p->col += n
// Ends the current line unless it is already empty.
@f nc_pp_nl(NcPretty *p) void
  if not p->bol
    nc_add(p->c, &p->out, "\n")
    p->bol = true
    p->col = 0
    p->space = false
// Ends a statement line and drops wrap indentation.
@f nc_pp_end(NcPretty *p) void
  p->cont = false
  nc_pp_nl(p)
// Ends the line and leaves one empty line after it.
@f nc_pp_blank(NcPretty *p) void
  nc_pp_nl(p)
  if p->out.n && !(p->out.n >= 2 && p->out.v[p->out.n - 2] == '\n')
    nc_add(p->c, &p->out, "\n")
// Writes a preprocessor directive on its own line.
@f nc_pp_directive(NcPretty *p, NcToken t) void
  usize n = t.n
  while n and isspace((u8)t.s[n - 1])
    --n
  bool marker = !strncmp(t.s, "#line", 5)
  if !marker and !p->last_dir and p->out.n and !p->top and !p->paren
    nc_pp_blank(p)
  nc_pp_nl(p)
  nc_addn(p->c, &p->out, t.s, n)
  nc_add(p->c, &p->out, "\n")
  p->bol = true
  p->col = 0
  p->stmt = true
  p->after = 0
  if not marker
    p->last_dir = true
