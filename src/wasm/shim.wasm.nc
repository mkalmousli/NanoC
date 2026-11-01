// Minimal libc for the browser build: bump allocator, string helpers and a
// small printf. Host-only features (files, processes) fail cleanly.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <setjmp.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/utsname.h>
#include <stdarg.h>
#include <stdbool.h>
#define HEAP_BYTES (512u * 1024u * 1024u)
extern unsigned char __heap_base;
static size_t heap_top;
static size_t heap_limit = HEAP_BYTES;
struct NcFile { int unused; };
FILE *stdin, *stdout, *stderr;
int errno;
extern void nc_host_write(int fd, const char *s, size_t n);
extern void nc_host_trap(void) __attribute__((noreturn));
@f malloc(size_t n) void *
  size_t a = (n + 15) & ~(size_t)15
  if heap_top + a > heap_limit
    ret 0
  size_t need = (size_t)&__heap_base + heap_top + a
  size_t have = __builtin_wasm_memory_size(0) * 65536u
  if need > have
    size_t pages = (need - have + 65535) / 65536
    if __builtin_wasm_memory_grow(0, pages) == (size_t)-1
      ret 0
  void *p = (unsigned char *)&__heap_base + heap_top
  heap_top += a
  ret p
@f calloc(size_t n, size_t m) void *
  void *p = malloc(n * m)
  if p
    memset(p, 0, n * m)
  ret p
@f realloc(void *p, size_t n) void *
  void *q = malloc(n)
  if q && p
    memcpy(q, p, n)
  ret q
@f free(void *p) void
  (void)p
@f exit(int code) void
  (void)code
  nc_host_trap()
@f abort void
  nc_host_trap()
@f getenv(const char *k) char *
  (void)k
  ret 0
@f system(const char *c) int
  (void)c
  ret -1
@f fork int
  ret -1
@f waitpid(pid_t p, int *s, int o) int
  (void)p
  (void)s
  (void)o
  ret -1
@f isatty(int fd) int
  (void)fd
  ret 0
@f uname(struct utsname *u) int
  (void)u
  ret -1
@f strerror(int e) char *
  (void)e
  ret "error"
@f stat(const char *p, struct stat *s) int
  (void)p
  (void)s
  errno = ENOENT
  ret -1
@f fstat(int fd, struct stat *s) int
  (void)fd
  (void)s
  ret -1
@f unlink(const char *p) int
  (void)p
  ret -1
@f access(const char *p, int m) int
  (void)p
  (void)m
  ret -1
@f chdir(const char *p) int
  (void)p
  ret -1
@f mkdir(const char *p, unsigned m) int
  (void)p
  (void)m
  ret -1
@f fopen(const char *p, const char *m) FILE *
  (void)p
  (void)m
  errno = ENOENT
  ret 0
@f fclose(FILE *f) int
  (void)f
  ret 0
@f fflush(FILE *f) int
  (void)f
  ret 0
@f ferror(FILE *f) int
  (void)f
  ret 0
@f fgets(char *b, int n, FILE *f) char *
  (void)b
  (void)n
  (void)f
  ret 0
@f fread(void *p, size_t s, size_t n, FILE *f) size_t
  (void)p
  (void)s
  (void)n
  (void)f
  ret 0
@f fwrite(const void *p, size_t s, size_t n, FILE *f) size_t
  int fd = f == stderr ? 2 : 1
  nc_host_write(fd, p, s * n)
  ret n
@f fputs(const char *s, FILE *f) int
  ret fwrite(s, 1, strlen(s), f) ? 1 : EOF
@f fputc(int c, FILE *f) int
  char ch = (char)c
  fwrite(&ch, 1, 1, f)
  ret c
@f putchar(int c) int
  ret fputc(c, stdout)
@f puts(const char *s) int
  fputs(s, stdout)
  ret fputc('\n', stdout)
@f strlen(const char *s) size_t
  size_t n = 0
  while s[n]
    ++n
  ret n
@f strcmp(const char *a, const char *b) int
  while *a && *a == *b
    ++a
    ++b
  ret (unsigned char)*a - (unsigned char)*b
@f strncmp(const char *a, const char *b, size_t n) int
  for ; n; --n, ++a, ++b
    if *a != *b || !*a
      ret (unsigned char)*a - (unsigned char)*b
  ret 0
@f strchr(const char *s, int c) char *
  for ; *s; ++s
    if *s == (char)c
      ret (char *)s
  ret c == 0 ? (char *)s : 0
@f strrchr(const char *s, int c) char *
  const char *r = 0
  for ; *s; ++s
    if *s == (char)c
      r = s
  ret c == 0 ? (char *)s : (char *)r
@f strstr(const char *h, const char *n) char *
  size_t l = strlen(n)
  for ; *h; ++h
    if !strncmp(h, n, l)
      ret (char *)h
  ret l ? 0 : (char *)h
@f strcspn(const char *s, const char *r) size_t
  size_t n = 0
  while s[n] && !strchr(r, s[n])
    ++n
  ret n
@f strpbrk(const char *s, const char *r) char *
  for ; *s; ++s
    if strchr(r, *s)
      ret (char *)s
  ret 0
@f memcpy(void *d, const void *s, size_t n) void *
  unsigned char *o = d
  const unsigned char *i = s
  while n--
    *o++ = *i++
  ret d
@f memset(void *d, int c, size_t n) void *
  unsigned char *o = d
  while n--
    *o++ = (unsigned char)c
  ret d
@f memchr(const void *s, int c, size_t n) void *
  const unsigned char *p = s
  for ; n; --n, ++p
    if *p == (unsigned char)c
      ret (void *)p
  ret 0
@f memcmp(const void *a, const void *b, size_t n) int
  const unsigned char *x = a, *y = b
  for ; n; --n, ++x, ++y
    if *x != *y
      ret *x - *y
  ret 0
@f isspace(int c) int
  ret c == ' ' || (c >= '\t' && c <= '\r')
@f isdigit(int c) int
  ret c >= '0' && c <= '9'
@f isalpha(int c) int
  ret (c | 32) >= 'a' && (c | 32) <= 'z'
@f isalnum(int c) int
  ret isalpha(c) || isdigit(c)
@f isxdigit(int c) int
  ret isdigit(c) || ((c | 32) >= 'a' && (c | 32) <= 'f')
@f tolower(int c) int
  ret c >= 'A' && c <= 'Z' ? c + 32 : c
@f toupper(int c) int
  ret c >= 'a' && c <= 'z' ? c - 32 : c
@f strtoll(const char *s, char **e, int b) long long
  long long v = 0
  int neg = 0
  while isspace((unsigned char)*s)
    ++s
  if *s == '-' || *s == '+'
    neg = *s++ == '-'
  if !b
    b = 10
  for ; isalnum((unsigned char)*s); ++s
    int d = isdigit((unsigned char)*s) ? *s - '0' : tolower(*s) - 'a' + 10
    if d >= b
      break
    v = v * b + d
  if e
    *e = (char *)s
  ret neg ? -v : v
@f strtoull(const char *s, char **e, int b) unsigned long long
  ret (unsigned long long)strtoll(s, e, b)
@f strtoimax(const char *s, char **e, int b) intmax_t
  ret strtoll(s, e, b)
@f strtod(const char *s, char **e) double
  if e
    *e = (char *)s
  ret (double)strtoll(s, 0, 10)
@f longjmp(jmp_buf b, int v) void
  (void)b
  (void)v
  nc_host_trap()
