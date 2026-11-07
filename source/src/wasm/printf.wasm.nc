@lang 1
+ "nanoc/nanoc.h"
// printf subset: %% %c %s %d %i %u %x %X %p %zu %zd %ld %lld %llu %lx %jd %.*s %*s
// with width, '-', '0' and precision for strings and integers.
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
struct Sink { char *buf; size_t cap, len; FILE *file; char tmp[512]; };
// Implements put for the freestanding browser compiler.
f put(struct Sink *s, const char *p, size_t n) static void
  if s->file
    fwrite(p, 1, n, s->file)
    <
  for size_t i = 0; i < n; ++i
    if s->buf && s->len + 1 < s->cap
      s->buf[s->len] = p[i]
    ++s->len

// Implements pad for the freestanding browser compiler.
f pad(struct Sink *s, size_t n, char c) static void
  for ; n; --n
    put(s, &c, 1)

// Formats an unsigned integer with padding and precision.
f emit_unsigned(struct Sink *s, unsigned long long v, unsigned base, int upper, int width, int left, int zero, int prec, int neg) static void
  char digits[32]
  int n = 0
  const char *dg = upper ? "0123456789ABCDEF" : "0123456789abcdef"
  for ;;
    digits[n++] = dg[v % base]
    v /= base
    if !v
      !
  while n < prec
    digits[n++] = '0'
  int total = n + (neg ? 1 : 0)
  if !left && !zero
    pad(s, width > total ? width - total : 0, ' ')
  if neg
    put(s, "-", 1)
  if !left && zero
    pad(s, width > total ? width - total : 0, '0')
  while n
    put(s, &digits[--n], 1)
  if left
    pad(s, width > total ? width - total : 0, ' ')
struct Sink;
int nc_vformat(struct Sink *, const char *, va_list);
// Implements vfprintf for the freestanding browser compiler.
f vfprintf(FILE *f, const char *fmt, va_list ap) int
  struct Sink s
  memset(&s, 0, sizeof s)
  s.file = f
  <  nc_vformat(&s, fmt, ap)

// Implements vsnprintf for the freestanding browser compiler.
f vsnprintf(char *buf, size_t cap, const char *fmt, va_list ap) int
  struct Sink s
  memset(&s, 0, sizeof s)
  s.buf = buf
  s.cap = cap
  nc_vformat(&s, fmt, ap)
  if cap
    buf[s.len < cap ? s.len : cap - 1] = 0
  <  (int)s.len

// Implements snprintf for the freestanding browser compiler.
f snprintf(char *buf, size_t cap, const char *fmt, ...) int
  va_list ap
  va_start(ap, fmt)
  int n = vsnprintf(buf, cap, fmt, ap)
  va_end(ap)
  <  n

// Implements fprintf for the freestanding browser compiler.
f fprintf(FILE *f, const char *fmt, ...) int
  va_list ap
  va_start(ap, fmt)
  int n = vfprintf(f, fmt, ap)
  va_end(ap)
  <  n

// Implements printf for the freestanding browser compiler.
f printf(const char *fmt, ...) int
  va_list ap
  va_start(ap, fmt)
  int n = vfprintf(stdout, fmt, ap)
  va_end(ap)
  <  n

// Implements nc_vformat for the freestanding browser compiler.
f nc_vformat(struct Sink *s, const char *fmt, va_list ap) int
  for const char *p = fmt; *p; ++p
    if *p != '%'
      put(s, p, 1)
      ^
    ++p
    int left = 0, zero = 0, width = 0, prec = -1, lng = 0
    for ; ; ++p
      if *p == '-'
        left = 1
      elif *p == '0'
        zero = 1
      else
        !
    if *p == '*'
      width = va_arg(ap, int)
      ++p
    else
      while *p >= '0' && *p <= '9'
        width = width * 10 + (*p++ - '0')
    if *p == '.'
      ++p
      prec = 0
      if *p == '*'
        prec = va_arg(ap, int)
        ++p
      else
        while *p >= '0' && *p <= '9'
          prec = prec * 10 + (*p++ - '0')
    int sz = 0
    while *p == 'l' || *p == 'z' || *p == 'j' || *p == 'h'
      if *p == 'z'
        sz = 1
      elif *p != 'h'
        lng += 1
      ++p
    char c = *p
    if c == '%'
      put(s, "%", 1)
      ^
    if c == 'c'
      char ch = (char)va_arg(ap, int)
      pad(s, !left && width > 1 ? width - 1 : 0, ' ')
      put(s, &ch, 1)
      pad(s, left && width > 1 ? width - 1 : 0, ' ')
      ^
    if c == 's'
      const char *v = va_arg(ap, const char *)
      if !v
        v = "(null)"
      size_t n = strlen(v)
      if prec >= 0 && (size_t)prec < n
        n = prec
      if !left
        pad(s, width > (int)n ? width - n : 0, ' ')
      put(s, v, n)
      if left
        pad(s, width > (int)n ? width - n : 0, ' ')
      ^
    if c == 'd' || c == 'i'
      long long v = sz ? (long long)va_arg(ap, size_t) : lng ? va_arg(ap, long long) : (long long)va_arg(ap, int)
      unsigned long long u = v < 0 ? 0ULL - (unsigned long long)v : (unsigned long long)v
      emit_unsigned(s, u, 10, 0, width, left, zero, prec, v < 0)
      ^
    if c == 'u' || c == 'x' || c == 'X' || c == 'p'
      unsigned long long v = sz ? (unsigned long long)va_arg(ap, size_t) : lng ? va_arg(ap, unsigned long long) : (c == 'p' ? (unsigned long long)(uintptr_t)va_arg(ap, void *) : (unsigned long long)va_arg(ap, unsigned int))
      emit_unsigned(s, v, c == 'u' ? 10 : 16, c == 'X', width, left, zero, prec, 0)
      ^
    if c == 'f' || c == 'g'
      (void)va_arg(ap, double)
      put(s, "?", 1)
      ^
    put(s, "%", 1)
    put(s, &c, 1)
  <  (int)s->len

