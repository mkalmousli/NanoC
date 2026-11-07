@lang 1
+ "nanoc/nanoc.h"
// Browser entry: transpile one NanoC source string to C. Errors trap (no
// longjmp in the browser build); the host reads the message with nc_web_error.
#include "nanoc/nanoc.h"
#include <string.h>
static NcContext *last;
static char *last_out;
static size_t last_len;
f nc_host_write(int fd, const char *s, size_t n) -> void
  (void)fd
  (void)s
  (void)n

f nc_host_trap(void) -> void
  __builtin_trap()

f nc_web_transpile(const char *src, size_t len) -> int
  NcContext *c = calloc(1, sizeof *c)
  nc_init(c, "playground.nc")
  last = c
  char *copy = malloc(len + 1)
  memcpy(copy, src, len)
  copy[len] = 0
  last_out = nc_transpile(c, copy)
  last_len = strlen(last_out)
  return  0

f nc_web_output(void) -> const char *
  return  last_out

f nc_web_output_len(void) -> size_t
  return  last_len

f nc_web_error(void) -> const char *
  return  last ? last->error : ""

