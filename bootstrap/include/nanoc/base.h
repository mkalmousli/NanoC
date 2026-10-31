#ifndef NC_BASE_H
#define NC_BASE_H
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include <ctype.h>
typedef struct NcContext NcContext;
typedef struct NcAllocation NcAllocation;
typedef struct { const char *key; void *value; } NcEntry;
typedef struct { NcEntry *v; size_t n, cap; } NcMap;
typedef struct { char *v; size_t n, cap; } NcBuffer;
typedef struct { char **v; size_t n, cap; } NcStrings;
#define NC_PUSH(c, a, x) do { \
    if ((a).n == (a).cap) (a).v = nc_grow(c, (a).v, (a).n, &(a).cap, sizeof *(a).v); \
    (a).v[(a).n++] = (x); \
} while (0)
void *nc_alloc(NcContext *, size_t);
void *nc_grow(NcContext *, const void *, size_t, size_t *, size_t);
void *nc_get(const NcMap *, const char *);
void nc_put(NcContext *, NcMap *, const char *, void *);
void nc_addn(NcContext *, NcBuffer *, const char *, size_t);
void nc_add(NcContext *, NcBuffer *, const char *);
void nc_printf(NcContext *, NcBuffer *, const char *, ...);
char *nc_string(NcContext *, const char *, size_t);
char *nc_format(NcContext *, const char *, ...);
char *nc_trim(NcContext *, const char *);
char *nc_quote(NcContext *, const char *);
char *nc_unquote(NcContext *, const char *, int);
bool nc_identifier(const char *);
#endif
