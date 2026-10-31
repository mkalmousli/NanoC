#ifndef NC_LAYOUT_H
#define NC_LAYOUT_H
#include "core.h"
typedef struct { NcTokens ts; int indent, line; bool raw; } NcLayoutLine;
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
typedef struct { int line, indent; } NcHeader;
NcHeader nc_header(const NcCursor *);
bool nc_header_at(const NcCursor *, const char *, int);
bool nc_header_eat(NcCursor *, const char *, int);
bool nc_same_line(const NcCursor *, int);
NcTokens nc_line_expression(NcCursor *);
NcLines nc_prepare_lines(NcContext *, NcLines, bool);
NcNodes nc_indented_nodes(NcCursor *, NcHeader, bool);
NcTokens nc_meta_body(NcCursor *, NcHeader, bool, bool);
NcTokens nc_macro_body(NcCursor *, NcHeader, bool *);
char *nc_emit_program(NcContext *, NcNodes, bool, size_t);
char *nc_program_control(NcContext *, NcTokens, int);
NcTokens nc_program_text(NcContext *, const char *, int);
bool nc_meta_line(NcLayoutLine);
bool nc_extension_line(NcLayoutLine);
char *nc_native_parameters(NcContext *, NcTokens);
char *nc_assembly(NcContext *, NcCursor *);
#endif
