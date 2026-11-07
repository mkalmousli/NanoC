// Host stubs and allocation for the freestanding browser compiler.
@lang 1
+ "nanoc/nanoc.h"
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
// Implements malloc for the freestanding browser compiler.
f malloc(size_t n) void *
  size_t a = (n + 15) & ~(size_t)15
  if heap_top + a > heap_limit
    <  0
  size_t need = (size_t)&__heap_base + heap_top + a
  size_t have = __builtin_wasm_memory_size(0) * 65536u
  if need > have
    size_t pages = (need - have + 65535) / 65536
    if __builtin_wasm_memory_grow(0, pages) == (size_t)-1
      <  0
  void *p = (unsigned char *)&__heap_base + heap_top
  heap_top += a
  <  p

// Implements calloc for the freestanding browser compiler.
f calloc(size_t n, size_t m) void *
  void *p = malloc(n * m)
  if p
    memset(p, 0, n * m)
  <  p

// Implements realloc for the freestanding browser compiler.
f realloc(void *p, size_t n) void *
  void *q = malloc(n)
  if q && p
    memcpy(q, p, n)
  <  q

// Implements free for the freestanding browser compiler.
f free(void *p)
  (void)p

// Implements exit for the freestanding browser compiler.
f exit(int code)
  (void)code
  nc_host_trap()

// Implements abort for the freestanding browser compiler.
f abort(void)
  nc_host_trap()

// Implements getenv for the freestanding browser compiler.
f getenv(const char *k) char *
  (void)k
  <  0

// Implements system for the freestanding browser compiler.
f system(const char *c) int
  (void)c
  <  -1

// Implements fork for the freestanding browser compiler.
f fork(void) int
  <  -1

// Implements waitpid for the freestanding browser compiler.
f waitpid(pid_t p, int *s, int o) int
  (void)p
  (void)s
  (void)o
  <  -1

// Implements isatty for the freestanding browser compiler.
f isatty(int fd) int
  (void)fd
  <  0

// Implements uname for the freestanding browser compiler.
f uname(struct utsname *u) int
  (void)u
  <  -1

// Implements strerror for the freestanding browser compiler.
f strerror(int e) char *
  (void)e
  <  "error"

// Implements stat for the freestanding browser compiler.
f stat(const char *p, struct stat *s) int
  (void)p
  (void)s
  errno = ENOENT
  <  -1

// Implements fstat for the freestanding browser compiler.
f fstat(int fd, struct stat *s) int
  (void)fd
  (void)s
  <  -1

// Implements unlink for the freestanding browser compiler.
f unlink(const char *p) int
  (void)p
  <  -1

// Implements access for the freestanding browser compiler.
f access(const char *p, int m) int
  (void)p
  (void)m
  <  -1

// Implements chdir for the freestanding browser compiler.
f chdir(const char *p) int
  (void)p
  <  -1

// Implements mkdir for the freestanding browser compiler.
f mkdir(const char *p, unsigned m) int
  (void)p
  (void)m
  <  -1

// Implements fopen for the freestanding browser compiler.
f fopen(const char *p, const char *m) FILE *
  (void)p
  (void)m
  errno = ENOENT
  <  0

// Implements fclose for the freestanding browser compiler.
f fclose(FILE *f) int
  (void)f
  <  0

// Implements fflush for the freestanding browser compiler.
f fflush(FILE *f) int
  (void)f
  <  0

// Implements ferror for the freestanding browser compiler.
f ferror(FILE *f) int
  (void)f
  <  0

// Implements fgets for the freestanding browser compiler.
f fgets(char *b, int n, FILE *f) char *
  (void)b
  (void)n
  (void)f
  <  0

// Implements fread for the freestanding browser compiler.
f fread(void *p, size_t s, size_t n, FILE *f) size_t
  (void)p
  (void)s
  (void)n
  (void)f
  <  0

// Implements fwrite for the freestanding browser compiler.
f fwrite(const void *p, size_t s, size_t n, FILE *f) size_t
  int fd = f == stderr ? 2 : 1
  nc_host_write(fd, p, s * n)
  <  n

// Implements fputs for the freestanding browser compiler.
f fputs(const char *s, FILE *f) int
  <  fwrite(s, 1, strlen(s), f) ? 1 : EOF

// Implements fputc for the freestanding browser compiler.
f fputc(int c, FILE *f) int
  char ch = (char)c
  fwrite(&ch, 1, 1, f)
  <  c

// Implements putchar for the freestanding browser compiler.
f putchar(int c) int
  <  fputc(c, stdout)

// Implements puts for the freestanding browser compiler.
f puts(const char *s) int
  fputs(s, stdout)
  <  fputc('\n', stdout)

