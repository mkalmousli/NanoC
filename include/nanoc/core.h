#ifndef NC_CORE_H
#define NC_CORE_H
#include "token.h"
typedef struct { char *name, *params, *returns, *intent; int line; } NcSymbol;
typedef struct { NcSymbol *v; size_t n, cap; } NcSymbols;
struct NcContext {
    const char *file;
    bool cpp;
    size_t max_depth, max_steps, max_output, steps, serial, allocated;
    size_t max_passes, pass;
    bool effects, again, lines;
    const char *source, *next_source;
    NcMap state;
    NcStrings logs;
    NcAllocation *allocations;
    NcMap names, macros;
    NcSymbols symbols;
    jmp_buf trap;
    char error[16384], detail[2048];
    const char *code;
    int error_line;
    char *frames[256];
    size_t frame_count;
};
void nc_init(NcContext *, const char *);
void nc_dispose(NcContext *);
_Noreturn void nc_fail(NcContext *, int, const char *, ...);
void nc_step(NcContext *, int);
void nc_check(NcContext *, size_t, int);
void nc_depth(NcContext *, size_t, int, const char *);
char *nc_fresh(NcContext *, const char *);
void nc_names(NcContext *, NcTokens);
char *nc_expand(NcContext *, NcTokens, size_t);
char *nc_transpile(NcContext *, const char *);
char *nc_typed(NcContext *, NcTokens, bool);
char *nc_parameters(NcContext *, NcTokens);
char *nc_function(NcContext *, NcCursor *, size_t);
char *nc_native_function(NcContext *, NcCursor *, size_t);
char *nc_shorthand(NcContext *, NcCursor *, const char *, size_t);
char *nc_compile_time(NcContext *, NcTokens, size_t);
char *nc_read(NcContext *, const char *);
void nc_write(NcContext *, const char *, const char *);
#endif
