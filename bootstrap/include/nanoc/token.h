#ifndef NC_TOKEN_H
#define NC_TOKEN_H
#include "base.h"
typedef enum { NC_SPACE, NC_WORD, NC_NUMBER, NC_LITERAL, NC_PUNCT, NC_DIRECTIVE } NcKind;
typedef struct { const char *s; size_t n; int line, column; NcKind kind; } NcToken;
typedef struct { NcToken *v; size_t n, cap; } NcTokens;
typedef struct { NcTokens *v; size_t n, cap; } NcGroups;
typedef struct { NcContext *ctx; NcTokens ts; size_t pos; } NcCursor;
bool nc_is(NcToken, const char *);
bool nc_has_token(const NcMap *, NcToken);
char *nc_text(NcContext *, NcToken);
NcToken nc_token(const char *, int, NcKind);
NcTokens nc_slice(NcTokens, size_t, size_t);
NcTokens nc_lex(NcContext *, const char *, int);
char *nc_join(NcContext *, NcTokens);
char *nc_words(NcContext *, NcTokens);
NcTokens nc_significant(NcContext *, NcTokens);
size_t nc_literal_start(const char *, size_t, bool);
size_t nc_literal_end(NcContext *, const char *, size_t, int);
size_t nc_line_end(const char *, size_t);
void nc_skip(NcCursor *);
bool nc_end(NcCursor *);
bool nc_at(NcCursor *, const char *);
bool nc_eat(NcCursor *, const char *);
NcToken nc_take(NcCursor *);
void nc_need(NcCursor *, const char *);
char *nc_name(NcCursor *);
int nc_line(const NcCursor *);
NcTokens nc_group(NcCursor *, const char *, const char *);
NcTokens nc_until(NcCursor *, const char *);
NcGroups nc_split(NcContext *, NcTokens, const char *);
#endif
