#ifndef NC_WEB_STDLIB_H
#define NC_WEB_STDLIB_H
#include <stddef.h>
#include <stdint.h>
void *malloc(size_t);
void *calloc(size_t, size_t);
void *realloc(void *, size_t);
void free(void *);
void exit(int) __attribute__((noreturn));
void abort(void) __attribute__((noreturn));
char *getenv(const char *);
int mkstemp(char *);
char *mkdtemp(char *);
char *realpath(const char *, char *);
int system(const char *);
long long strtoll(const char *, char **, int);
unsigned long long strtoull(const char *, char **, int);
intmax_t strtoimax(const char *, char **, int);
double strtod(const char *, char **);
#include <stdint.h>
#endif
