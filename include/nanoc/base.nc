// Base types and limits.
@use stdbool, stddef, stdint, setjmp, stdio, stdlib, string, stdarg, limits, ctype
typedef struct NcContext NcContext;
typedef struct NcAllocation NcAllocation;
@s NcEntry key:cstr; value:*void
@s NcMap v:*NcEntry; n,cap:usize
@s NcBuffer v:*char; n,cap:usize
@s NcStrings v:*char *; n,cap:usize
#define NC_PUSH(c, a, x) do { \
    if ((a).n == (a).cap) (a).v = nc_grow(c, (a).v, (a).n, &(a).cap, sizeof *(a).v); \
    (a).v[(a).n++] = (x); \
} while (0)
