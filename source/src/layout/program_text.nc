// Meta program source assembly.
@lang 1
+ "nanoc/nanoc.h"

// Lexes program text to tokens.
f nc_program_text(NcContext *ctx, const char *text, int line) NcTokens
  NcCursor c = {ctx, nc_lex(ctx, text, line), 0}
  if nc_end(&c)
    < (NcTokens){0}
  c.pos = 0
  NcNodes nodes = nc_indented_nodes(&c, (NcHeader){line - 1, -1}, 1)
  < nc_lex(ctx, nc_emit_program(ctx, nodes, 0, 0), nodes.v[0].head.line)
