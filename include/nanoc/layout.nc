typedef struct { NcTokens ts; int indent, line; bool raw; } NcLayoutLine;
typedef struct { NcLayoutLine *v; size_t n, cap; } NcLines;
typedef struct NcNode NcNode;
typedef struct { NcNode *v; size_t n, cap; } NcNodes;
struct NcNode { NcLayoutLine head; NcNodes children; };
typedef struct { int line, indent; } NcHeader;
