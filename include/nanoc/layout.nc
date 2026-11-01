// Layout tree types.
typedef struct { NcTokens ts; int indent, line; bool raw; } NcLayoutLine;
typedef struct { NcLayoutLine *v; size_t n, cap; } NcLines;
typedef struct NcNode NcNode;
typedef struct { NcNode *v; size_t n, cap; } NcNodes;
struct NcNode { NcLayoutLine head; NcNodes children; };
typedef struct { int line, indent; } NcHeader;
// State of the pretty C printer.
typedef struct {
    NcContext *c;
    NcBuffer out;
    NcToken prev;
    int ind, top, paren, after, ternary;
    size_t col;
    bool bol, space, cont, stmt, kw_type, kw_enum, in_case, gap, comment, last_dir, has_prev;
    char kind[256];
    bool cases[256], dos[256], ctl[256];
} NcPretty;
