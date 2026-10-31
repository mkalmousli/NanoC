#ifndef NC_MACRO_H
#define NC_MACRO_H
#include "core.h"
typedef struct { char *name, *kind; bool variadic; } NcParam;
typedef struct { NcParam *v; size_t n, cap; } NcParams;
typedef struct { NcParams params; NcTokens body; bool program; } NcMacro;
typedef struct { NcMap values, fresh; char *variadic; } NcBindings;
void nc_define_macro(NcContext *, NcCursor *);
char *nc_invoke_macro(NcContext *, NcCursor *, const char *, size_t);
char *nc_substitute(NcContext *, NcTokens, NcBindings *, size_t, size_t);
char *nc_macro_program(NcContext *, NcMacro *, NcBindings *, size_t);
#endif
