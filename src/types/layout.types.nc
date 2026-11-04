// Layout tree types.
@s NcLayoutLine ts:NcTokens; indent,line:i32; raw:bool
@s NcLines v:*NcLayoutLine; n,cap:usize
typedef struct NcNode NcNode;
@s NcNodes v:*NcNode; n,cap:usize
struct NcNode { NcLayoutLine head; NcNodes children; };
@s NcHeader line,indent:i32
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
