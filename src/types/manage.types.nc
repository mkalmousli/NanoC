// Manage command types.
@lang 1
#define _XOPEN_SOURCE 700
/* Paths are bounded by PATH_MAX; snprintf truncation is handled by callers. */
#pragma GCC diagnostic ignored "-Wformat-truncation"
+ <stdio.h>
+ <stdbool.h>
+ <limits.h>
+ <stddef.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
s NcTarget
  src:const char *
  char dst[PATH_MAX]
