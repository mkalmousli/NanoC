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
