// Preprocessor nodes emit directives and child statements without introducing C braces.
@lang 1
+ "nanoc/nanoc.h"

// Emits a runtime-scope preprocessor chain and advances the caller past its branches.
f nc_emit_pp(NcContext *c, NcNodes nodes, size_t *at, size_t depth) char *
  NcBuffer out = {0}
  bool ended = 0
  for ;;
    NcNode node = nodes.v[*at]
    NcTokens ts = nc_significant(c, node.head.ts)
    bool otherwise = nc_pp_kind(ts) == 5
    if ended
      nc_fail(c, node.head.line, "branch after preprocessor else")
    ended = otherwise
    if !node.children.n
      nc_fail(c, node.head.line, "preprocessor branch needs an indented body")
    nc_marker(c, &out, node.head.line)
    nc_add(c, &out, otherwise ? "#else\n" : nc_pp_header(c, node.head.ts, node.head.line))
    nc_add(c, &out, nc_emit_block(c, node.children, depth + 1))
    ++*at
    if *at == nodes.n
      !
    NcTokens next = nc_significant(c, nodes.v[*at].head.ts)
    if nc_pp_kind(next) != 4 && nc_pp_kind(next) != 5
      !
  nc_add(c, &out, "\n#endif\n")
  < out.v
