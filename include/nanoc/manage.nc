// Manage command types.
#define _XOPEN_SOURCE 700
/* Paths are bounded by PATH_MAX; snprintf truncation is handled by callers. */
#pragma GCC diagnostic ignored "-Wformat-truncation"
@use stdio
@use stdbool
@use limits
@use stddef
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
@s NcTarget src:cstr; char dst[PATH_MAX]
