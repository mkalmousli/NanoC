// Base types and limits. Host feature macros must precede every libc include.
@lang 1
#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE 700
#endif
+ <stdbool.h>
+ <stddef.h>
+ <stdint.h>
+ <setjmp.h>
+ <stdio.h>
+ <stdlib.h>
+ <string.h>
+ <stdarg.h>
+ <limits.h>
+ <ctype.h>

typedef struct NcContext NcContext;
typedef struct NcAllocation NcAllocation;
s NcEntry
  key:const char *
  value:*void

s NcMap
  v:*NcEntry
  n,cap:size_t

s NcBuffer
  v:*char
  n,cap:size_t

s NcStrings
  v:*char *
  n,cap:size_t

#define NC_PUSH(c, a, x) do { \
    if ((a).n == (a).cap) (a).v = nc_grow(c, (a).v, (a).n, &(a).cap, sizeof *(a).v); \
    (a).v[(a).n++] = (x); \
} while (0)
