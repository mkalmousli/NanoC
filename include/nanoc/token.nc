// Token and cursor types.
typedef enum { NC_SPACE, NC_WORD, NC_NUMBER, NC_LITERAL, NC_PUNCT, NC_DIRECTIVE } NcKind;
typedef struct { const char *s; size_t n; int line, column; NcKind kind; } NcToken;
typedef struct { NcToken *v; size_t n, cap; } NcTokens;
typedef struct { NcTokens *v; size_t n, cap; } NcGroups;
typedef struct { NcContext *ctx; NcTokens ts; size_t pos; } NcCursor;
