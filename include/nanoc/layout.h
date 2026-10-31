#ifndef NC_LAYOUT_H
#define NC_LAYOUT_H
#include "core.h"
typedef struct { NcTokens ts; int indent, line; } NcLayoutLine;
typedef struct { NcLayoutLine *v; size_t n, cap; } NcLines;
typedef struct NcNode NcNode;
typedef struct { NcNode *v; size_t n, cap; } NcNodes;
struct NcNode { NcLayoutLine head; NcNodes children; };
NcLayoutLine nc_logical_line(NcCursor *);
NcLines nc_body_lines(NcCursor *, int, int);
NcNodes nc_tree(NcContext *, NcLines, size_t *, int, size_t);
char *nc_statement(NcContext *, NcLayoutLine, bool);
char *nc_control(NcContext *, NcTokens, int);
char *nc_emit_block(NcContext *, NcNodes, bool, size_t);
char *nc_infer(NcContext *, NcTokens, int);
NcTokens nc_declaration(NcContext *, NcTokens, int);
void nc_marker(NcContext *, NcBuffer *, int);
#endif
