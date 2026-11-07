// Freestanding string, character and numeric conversion functions for the browser compiler.
@lang 1
+ "nanoc/nanoc.h"
+ <stdio.h>
+ <stdlib.h>
+ <string.h>
+ <ctype.h>
+ <stdint.h>
+ <setjmp.h>
extern void nc_host_trap(void) __attribute__((noreturn));

// Implements strlen for the freestanding browser compiler.
f strlen(const char *s) size_t
  size_t n = 0
  while s[n]
    ++n
  <  n

// Implements strcmp for the freestanding browser compiler.
f strcmp(const char *a, const char *b) int
  while *a && *a == *b
    ++a
    ++b
  <  (unsigned char)*a - (unsigned char)*b

// Implements strncmp for the freestanding browser compiler.
f strncmp(const char *a, const char *b, size_t n) int
  for ; n; --n, ++a, ++b
    if *a != *b || !*a
      <  (unsigned char)*a - (unsigned char)*b
  <  0

// Implements strchr for the freestanding browser compiler.
f strchr(const char *s, int c) char *
  for ; *s; ++s
    if *s == (char)c
      <  (char *)s
  <  c == 0 ? (char *)s : 0

// Implements strrchr for the freestanding browser compiler.
f strrchr(const char *s, int c) char *
  const char *r = 0
  for ; *s; ++s
    if *s == (char)c
      r = s
  <  c == 0 ? (char *)s : (char *)r

// Implements strstr for the freestanding browser compiler.
f strstr(const char *h, const char *n) char *
  size_t l = strlen(n)
  for ; *h; ++h
    if !strncmp(h, n, l)
      <  (char *)h
  <  l ? 0 : (char *)h

// Implements strcspn for the freestanding browser compiler.
f strcspn(const char *s, const char *r) size_t
  size_t n = 0
  while s[n] && !strchr(r, s[n])
    ++n
  <  n

// Implements strpbrk for the freestanding browser compiler.
f strpbrk(const char *s, const char *r) char *
  for ; *s; ++s
    if strchr(r, *s)
      <  (char *)s
  <  0

// Implements memcpy for the freestanding browser compiler.
f memcpy(void *d, const void *s, size_t n) void *
  unsigned char *o = d
  const unsigned char *i = s
  while n--
    *o++ = *i++
  <  d

// Implements memset for the freestanding browser compiler.
f memset(void *d, int c, size_t n) void *
  unsigned char *o = d
  while n--
    *o++ = (unsigned char)c
  <  d

// Implements memchr for the freestanding browser compiler.
f memchr(const void *s, int c, size_t n) void *
  const unsigned char *p = s
  for ; n; --n, ++p
    if *p == (unsigned char)c
      <  (void *)p
  <  0

// Implements memcmp for the freestanding browser compiler.
f memcmp(const void *a, const void *b, size_t n) int
  const unsigned char *x = a, *y = b
  for ; n; --n, ++x, ++y
    if *x != *y
      <  *x - *y
  <  0

// Implements isspace for the freestanding browser compiler.
f isspace(int c) int
  <  c == ' ' || (c >= '\t' && c <= '\r')

// Implements isdigit for the freestanding browser compiler.
f isdigit(int c) int
  <  c >= '0' && c <= '9'

// Implements isalpha for the freestanding browser compiler.
f isalpha(int c) int
  <  (c | 32) >= 'a' && (c | 32) <= 'z'

// Implements isalnum for the freestanding browser compiler.
f isalnum(int c) int
  <  isalpha(c) || isdigit(c)

// Implements isxdigit for the freestanding browser compiler.
f isxdigit(int c) int
  <  isdigit(c) || ((c | 32) >= 'a' && (c | 32) <= 'f')

// Implements tolower for the freestanding browser compiler.
f tolower(int c) int
  <  c >= 'A' && c <= 'Z' ? c + 32 : c

// Implements toupper for the freestanding browser compiler.
f toupper(int c) int
  <  c >= 'a' && c <= 'z' ? c - 32 : c

// Implements longjmp for the freestanding browser compiler.
f longjmp(jmp_buf b, int v)
  (void)b
  (void)v
  nc_host_trap()

