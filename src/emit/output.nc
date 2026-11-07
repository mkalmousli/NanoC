// Low-level output for the pretty C printer.
@lang 1
+ "nanoc/nanoc.h"

// Writes text, indenting at the start of a line.
f nc_pp_put(NcPretty *p, const char *s, size_t n) -> void
  if (p->bol)
    size_t width = (size_t)(p->ind > 0 ? p->ind : 0) * 4
    if (p->cont)
      width += 8
    for (size_t i = (0), nanoc_bound_1 = (width); i < nanoc_bound_1; ++i)
      nc_add(p->c, &p->out, " ")
    p->col = width
    p->bol = 0
  elif (p->space)
    nc_add(p->c, &p->out, " "); ++p->col
  p->space = 0
  nc_addn(p->c, &p->out, s, n)
  p->col += n

// Ends the current line unless it is already empty.
f nc_pp_nl(NcPretty *p) -> void
  if (! p->bol)
    nc_add(p->c, &p->out, "\n")
    p->bol = 1
    p->col = 0
    p->space = 0

// Ends a statement line and drops wrap indentation.
f nc_pp_end(NcPretty *p) -> void
  p->cont = 0
  nc_pp_nl(p)

// Ends the line and leaves one empty line after it.
f nc_pp_blank(NcPretty *p) -> void
  nc_pp_nl(p)
  if (p->out.n && !(p->out.n >= 2 && p->out.v[p->out.n - 2] == '\n'))
    nc_add(p->c, &p->out, "\n")

// Writes a preprocessor directive on its own line.
f nc_pp_directive(NcPretty *p, NcToken t) -> void
  size_t n = t.n
  while (n && isspace((unsigned char)t.s[n - 1]))
    --n
  bool marker = !strncmp(t.s, "#line", 5)
  if (!marker && !p->last_dir && p->out.n && !p->top && !p->paren)
    nc_pp_blank(p)
  nc_pp_nl(p)
  nc_addn(p->c, &p->out, t.s, n)
  nc_add(p->c, &p->out, "\n")
  p->bol = 1
  p->col = 0
  p->stmt = 1
  p->after = 0
  if (! marker)
    p->last_dir = 1
