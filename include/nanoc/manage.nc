/* Paths are bounded by PATH_MAX; snprintf truncation is handled by callers. */
#pragma GCC diagnostic ignored "-Wformat-truncation"
#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include <stddef.h>
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
typedef struct { const char *src; char dst[PATH_MAX]; } NcTarget;
