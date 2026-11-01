// Block arguments of macro calls.
#include "nanoc/nanoc.h"
// Takes an indented block argument.
@f nc_block_argument(
  NcContext *ctx, NcCursor *c, NcMacro *m, NcGroups *args, int line, int indent
) void
  if !m->params.n || args->n + 1 != m->params.n
    return
  NcParam last = m->params.v[m->params.n - 1]
  if last.variadic || strcmp(last.kind, "block")
    return
  NcHeader header = {line, indent}
  usize next = c->pos
  while next < c->ts.n && c->ts.v[next].kind == NC_SPACE
    ++next
  if next == c->ts.n || c->ts.v[next].line <= line || c->ts.v[next].column - 1 <= header.indent
    return
  NcNodes nodes = nc_indented_nodes(c, header, false)
  char *body = nc_emit_block(ctx, nodes, false, 0)
  NcTokens block = nc_lex(ctx, nc_format(ctx, "{%s}", body), line)
  NC_PUSH(ctx, *args, block)
