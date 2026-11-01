// Growable text buffers.
#include "nanoc/nanoc.h"
// Appends n bytes.
@f nc_addn(NcContext *c, NcBuffer *b, const char *s, usize n) void
  if n > SIZE_MAX - b->n - 1
    nc_fail(c, 0, "output limit exceeded")
  usize need = b->n + n + 1
  while b->cap < need
    b->v = nc_grow(c, b->v, b->n, &b->cap, 1)
  if n
    memcpy(b->v + b->n, s, n)
  b->n += n
  b->v[b->n] = 0
// Appends a string.
@f nc_add(NcContext *c, NcBuffer *b, const char *s) void
  nc_addn(c, b, s, strlen(s))
// Appends formatted text.
@f nc_printf(NcContext *c, NcBuffer *b, const char *format, ...) void
  va_list a, copy
  va_start(a, format)
  va_copy(copy, a)
  int size = vsnprintf(NULL, 0, format, copy)
  va_end(copy)
  if size < 0
    nc_fail(c, 0, "formatting failed")
  char *s = nc_alloc(c, (usize)size + 1)
  vsnprintf(s, (usize)size + 1, format, a)
  va_end(a)
  nc_addn(c, b, s, (usize)size)
// Finishes a buffer as a string.
@f nc_string(NcContext *c, const char *s, usize n) char *
  char *p = nc_alloc(c, n + 1)
  if n
    memcpy(p, s, n)
  p
// Formats text into a new string.
@f nc_format(NcContext *c, const char *format, ...) char *
  va_list a, copy
  va_start(a, format)
  va_copy(copy, a)
  int size = vsnprintf(NULL, 0, format, copy)
  va_end(copy)
  if size < 0
    nc_fail(c, 0, "formatting failed")
  char *s = nc_alloc(c, (usize)size + 1)
  vsnprintf(s, (usize)size + 1, format, a)
  va_end(a)
  s
