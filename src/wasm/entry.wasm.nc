@lang 1
+ "nanoc/nanoc.h"
// Browser entry: transpile one NanoC source string to C. Errors trap (no
// longjmp in the browser build); the host reads the message with nc_web_error.
#include "nanoc/nanoc.h"
#include <string.h>
static NcContext *last;
static char *last_out;
static size_t last_len;
// Implements nc_host_write for the freestanding browser compiler.
f nc_host_write(int fd, const char *s, size_t n)
  (void)fd
  (void)s
  (void)n

// Implements nc_host_trap for the freestanding browser compiler.
f nc_host_trap(void)
  __builtin_trap()

// Implements nc_web_transpile for the freestanding browser compiler.
f nc_web_transpile(const char *src, size_t len) int
  NcContext *c = calloc(1, sizeof *c)
  nc_init(c, "playground.nc")
  last = c
  char *copy = malloc(len + 1)
  memcpy(copy, src, len)
  copy[len] = 0
  last_out = nc_transpile(c, copy)
  last_len = strlen(last_out)
  <  0

// Implements nc_web_output for the freestanding browser compiler.
f nc_web_output(void) const char *
  <  last_out

// Implements nc_web_output_len for the freestanding browser compiler.
f nc_web_output_len(void) size_t
  <  last_len

// Implements nc_web_error for the freestanding browser compiler.
f nc_web_error(void) const char *
  <  last ? last->error : ""

