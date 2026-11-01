/* Minimal libc for the browser build: bump allocator, string helpers and a
   small printf. Host-only features (files, processes) fail cleanly. */
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

void *malloc(size_t n) {
    size_t a = (n + 15) & ~(size_t)15;
    if (heap_top + a > heap_limit) return 0;
    size_t need = (size_t)&__heap_base + heap_top + a;
    size_t have = __builtin_wasm_memory_size(0) * 65536u;
    if (need > have) {
        size_t pages = (need - have + 65535) / 65536;
        if (__builtin_wasm_memory_grow(0, pages) == (size_t)-1) return 0;
    }
    void *p = (unsigned char *)&__heap_base + heap_top;
    heap_top += a;
    return p;
}
void *calloc(size_t n, size_t m) {
    void *p = malloc(n * m);
    if (p) memset(p, 0, n * m);
    return p;
}
void *realloc(void *p, size_t n) {
    void *q = malloc(n);
    if (q && p) memcpy(q, p, n);
    return q;
}
void free(void *p) { (void)p; }
void exit(int code) { (void)code; nc_host_trap(); }
void abort(void) { nc_host_trap(); }
char *getenv(const char *k) { (void)k; return 0; }
int system(const char *c) { (void)c; return -1; }
int fork(void) { return -1; }
int waitpid(pid_t p, int *s, int o) { (void)p; (void)s; (void)o; return -1; }
int isatty(int fd) { (void)fd; return 0; }
int uname(struct utsname *u) { (void)u; return -1; }
char *strerror(int e) { (void)e; return "error"; }
int stat(const char *p, struct stat *s) { (void)p; (void)s; errno = ENOENT; return -1; }
int fstat(int fd, struct stat *s) { (void)fd; (void)s; return -1; }
int unlink(const char *p) { (void)p; return -1; }
int access(const char *p, int m) { (void)p; (void)m; return -1; }
int chdir(const char *p) { (void)p; return -1; }
int mkdir(const char *p, unsigned m) { (void)p; (void)m; return -1; }
FILE *fopen(const char *p, const char *m) { (void)p; (void)m; errno = ENOENT; return 0; }
int fclose(FILE *f) { (void)f; return 0; }
int fflush(FILE *f) { (void)f; return 0; }
int ferror(FILE *f) { (void)f; return 0; }
char *fgets(char *b, int n, FILE *f) { (void)b; (void)n; (void)f; return 0; }
size_t fread(void *p, size_t s, size_t n, FILE *f) { (void)p; (void)s; (void)n; (void)f; return 0; }
size_t fwrite(const void *p, size_t s, size_t n, FILE *f) {
    int fd = f == stderr ? 2 : 1;
    nc_host_write(fd, p, s * n);
    return n;
}
int fputs(const char *s, FILE *f) { return fwrite(s, 1, strlen(s), f) ? 1 : EOF; }
int fputc(int c, FILE *f) { char ch = (char)c; fwrite(&ch, 1, 1, f); return c; }
int putchar(int c) { return fputc(c, stdout); }
int puts(const char *s) { fputs(s, stdout); return fputc('\n', stdout); }

size_t strlen(const char *s) { size_t n = 0; while (s[n]) ++n; return n; }
int strcmp(const char *a, const char *b) {
    while (*a && *a == *b) { ++a; ++b; }
    return (unsigned char)*a - (unsigned char)*b;
}
int strncmp(const char *a, const char *b, size_t n) {
    for (; n; --n, ++a, ++b) {
        if (*a != *b || !*a) return (unsigned char)*a - (unsigned char)*b;
    }
    return 0;
}
char *strchr(const char *s, int c) {
    for (;; ++s) { if (*s == (char)c) return (char *)s; if (!*s) return 0; }
}
char *strrchr(const char *s, int c) {
    const char *r = 0;
    for (;; ++s) { if (*s == (char)c) r = s; if (!*s) return (char *)r; }
}
char *strstr(const char *h, const char *n) {
    size_t l = strlen(n);
    for (; *h; ++h) if (!strncmp(h, n, l)) return (char *)h;
    return l ? 0 : (char *)h;
}
size_t strcspn(const char *s, const char *r) {
    size_t n = 0;
    for (; s[n] && !strchr(r, s[n]); ++n) {}
    return n;
}
char *strpbrk(const char *s, const char *r) {
    for (; *s; ++s) if (strchr(r, *s)) return (char *)s;
    return 0;
}
void *memcpy(void *d, const void *s, size_t n) {
    unsigned char *o = d; const unsigned char *i = s;
    while (n--) *o++ = *i++;
    return d;
}
void *memset(void *d, int c, size_t n) {
    unsigned char *o = d;
    while (n--) *o++ = (unsigned char)c;
    return d;
}
void *memchr(const void *s, int c, size_t n) {
    const unsigned char *p = s;
    for (; n; --n, ++p) if (*p == (unsigned char)c) return (void *)p;
    return 0;
}
int memcmp(const void *a, const void *b, size_t n) {
    const unsigned char *x = a, *y = b;
    for (; n; --n, ++x, ++y) if (*x != *y) return *x - *y;
    return 0;
}
int isspace(int c) { return c == ' ' || (c >= '\t' && c <= '\r'); }
int isdigit(int c) { return c >= '0' && c <= '9'; }
int isalpha(int c) { return (c | 32) >= 'a' && (c | 32) <= 'z'; }
int isalnum(int c) { return isalpha(c) || isdigit(c); }
int isxdigit(int c) { return isdigit(c) || ((c | 32) >= 'a' && (c | 32) <= 'f'); }
int tolower(int c) { return c >= 'A' && c <= 'Z' ? c + 32 : c; }
int toupper(int c) { return c >= 'a' && c <= 'z' ? c - 32 : c; }

long long strtoll(const char *s, char **e, int b) {
    long long v = 0; int neg = 0;
    while (isspace((unsigned char)*s)) ++s;
    if (*s == '-' || *s == '+') neg = *s++ == '-';
    if (!b) b = 10;
    for (; isalnum((unsigned char)*s); ++s) {
        int d = isdigit((unsigned char)*s) ? *s - '0' : tolower(*s) - 'a' + 10;
        if (d >= b) break;
        v = v * b + d;
    }
    if (e) *e = (char *)s;
    return neg ? -v : v;
}
unsigned long long strtoull(const char *s, char **e, int b) { return (unsigned long long)strtoll(s, e, b); }
intmax_t strtoimax(const char *s, char **e, int b) { return strtoll(s, e, b); }
double strtod(const char *s, char **e) { if (e) *e = (char *)s; return (double)strtoll(s, 0, 10); }

void longjmp(jmp_buf b, int v) { (void)b; (void)v; nc_host_trap(); }
