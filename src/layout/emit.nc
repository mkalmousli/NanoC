// Emits a layout tree as C.
#include "nanoc/nanoc.h"
// Tells if the node starts with s.
@f lead(NcNode n, const char *s) static bool
  for usize i = 0; i < n.head.ts.n; ++i
    if n.head.ts.v[i].kind != NC_SPACE
      if nc_is(n.head.ts.v[i], "else")
        usize next = i + 1
        while next < n.head.ts.n && n.head.ts.v[next].kind == NC_SPACE
          ++next
        bool condition = next < n.head.ts.n && nc_is(n.head.ts.v[next], "if")
        return !strcmp(s, condition ? "elif" : "else")
      return nc_is(n.head.ts.v[i], s)
  false
// Starts a new C line (and #line).
@f nc_marker(NcContext *c, NcBuffer *b, int line) void
  if c->lines
    nc_printf(c, b, "\n#line %d %s\n", line, nc_quote(c, c->file))
  else
    nc_add(c, b, "\n")
// Emits a block of nodes as C.
@f nc_emit_block(NcContext *c, NcNodes nodes, bool tail, usize depth) char *
  nc_depth(c, depth, nodes.n ? nodes.v[0].head.line : 1, "layout")
  if !nodes.n && tail
    nc_fail(c, 1, "value function needs a final expression")
  NcBuffer out = {0}
  usize i = 0
  while i < nodes.n
    NcNode node = nodes.v[i]
    nc_step(c, node.head.line)
    usize last = i
    if lead(node, "if") && node.children.n
      while (last + 1 < nodes.n
        && (lead(nodes.v[last + 1], "elif") || lead(nodes.v[last + 1], "else")))
        if lead(nodes.v[last], "else")
          nc_fail(c, nodes.v[last + 1].head.line, "branch after else")
        ++last
        if !nodes.v[last].children.n
          nc_fail(c, nodes.v[last].head.line, "branch needs ':' and an indented block")
    elif lead(node, "elif") || lead(node, "else")
      nc_fail(c, node.head.line, "branch without matching if")
    if lead(node, "defer") && !node.children.n
      nc_emit_defer(c, &out, nodes, i, tail, depth)
      break
    bool returning = tail && last + 1 == nodes.n
    if !node.children.n
      if node.head.raw || nc_meta_line(node.head)
        nc_marker(c, &out, node.head.line)
        nc_add(c, &out, nc_join(c, node.head.ts))
        nc_add(c, &out, "\n")
        i = last + 1
        continue
      if (returning
        && (
          lead(node, "let") || lead(node, "var") || lead(node, "intent") || lead(node, "break")
          || lead(node, "continue")))
        nc_fail(c, node.head.line, "value function needs a final expression")
      nc_marker(c, &out, node.head.line)
      nc_add(c, &out, nc_defer_return(c, nc_statement(c, node.head, returning)))
    else
      if returning && (!lead(node, "if") || !lead(nodes.v[last], "else"))
        nc_fail(c, node.head.line, "value function needs a final expression or exhaustive if/else")
      for usize branch = i; branch <= last; ++branch
        NcNode n = nodes.v[branch]
        nc_marker(c, &out, n.head.line)
        nc_printf(c, &out, "%s {", nc_control(c, n.head.ts, n.head.line))
        nc_add(c, &out, nc_emit_block(c, n.children, returning, depth + 1))
        nc_add(c, &out, "}\n")
    nc_check(c, out.n, node.head.line)
    i = last + 1
  nc_add(c, &out, "")
  out.v
