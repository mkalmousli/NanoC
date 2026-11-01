// The @asm inline assembly form.
#include "nanoc/nanoc.h"
// Expands an asm block to C.
@f nc_assembly(NcContext *ctx, NcCursor *c) char *
  NcHeader header = nc_header(c)
  NcBuffer qualifiers = {0}, code = {0}
  bool jump = false, seen[3] = {0}
  const char *names[] = {"volatile", "inline", "goto"}
  while nc_same_line(c, header.line)
    char *name = nc_name(c)
    size_t i = 0
    while i < 3 && strcmp(name, names[i])
      ++i
    if i == 3 || seen[i]
      nc_fail(ctx, header.line,
        "invalid or repeated assembly qualifier: %s", name)
    seen[i] = true
    if i == 2
      jump = true
    nc_printf(ctx, &qualifiers, " %s",
      i == 2 ? "goto" : i == 0 ? "__volatile__"
      : "__inline__")
  NcLines lines = nc_body_lines(c, header.line,
    header.indent)
  char *sections[4] = {"", "", "", ""}
  const char *keys[] = {"out", "in", "clobber", "labels"}
  int last = -1
  bool instructions = false
  for size_t i = 0; i < lines.n; ++i
    NcLayoutLine line = lines.v[i]
    nc_step(ctx, line.line)
    if line.indent != lines.v[0].indent
      nc_fail(ctx, line.line,
        "inconsistent assembly indentation")
    NcCursor row = {ctx, line.ts, 0}
    NcToken first = nc_take(&row)
    int section = 0
    while section < 4 && !nc_is(first, keys[section])
      ++section
    if section < 4
      if section <= last
        nc_fail(ctx, line.line,
          "assembly sections must be out, in, clobber, "
          "labels, once each")
      sections[section] = nc_trim(ctx,
        nc_join(ctx, nc_slice(row.ts, row.pos, row.ts.n)))
      if !*sections[section]
        nc_fail(ctx, line.line, "empty assembly section")
      last = section
    else
      if last >= 0
        nc_fail(ctx, line.line,
          "assembly instructions must precede operand "
          "sections")
      char *text = nc_trim(ctx, nc_join(ctx, line.ts))
      if first.kind == NC_LITERAL && first.s[0] == '"'
        nc_printf(ctx, &code, "%s ", text)
      else
        nc_printf(ctx, &code, "%s ",
          nc_quote(ctx, nc_format(ctx, "%s\n", text)))
      instructions = true
    nc_check(ctx, code.n, line.line)
  if !instructions
    nc_fail(ctx, header.line,
      "assembly needs instructions or a quoted template")
  if jump && !*sections[3]
    nc_fail(ctx, header.line, "assembly goto needs labels")
  if !jump && *sections[3]
    nc_fail(ctx, header.line,
      "assembly labels require goto")
  NcBuffer out = {0}
  nc_printf(ctx, &out, "__asm__%s (%s",
    qualifiers.v ? qualifiers.v : "", code.v)
  for int i = 0; i <= last; ++i
    nc_printf(ctx, &out, " : %s", sections[i])
  nc_add(ctx, &out, ");\n")
  out.v
