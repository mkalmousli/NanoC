#include "nanoc/layout.h"
NcTokens nc_program_text(NcContext *ctx, const char *text, int line) {
    NcCursor c = {ctx, nc_lex(ctx, text, line), 0};
    if (nc_end(&c)) return (NcTokens){0};
    c.pos = 0;
    NcNodes nodes = nc_indented_nodes(&c, (NcHeader){line - 1, -1}, true);
    return nc_lex(ctx, nc_emit_program(ctx, nodes, false, 0), nodes.v[0].head.line);
}
