#ifndef NC_WEB_STDIO_H
#define NC_WEB_STDIO_H
#include <stddef.h>
#include <stdarg.h>
typedef struct NcFile FILE;
extern FILE *stdin, *stdout, *stderr;
#define EOF (-1)
int printf(const char *, ...);
int fprintf(FILE *, const char *, ...);
int vfprintf(FILE *, const char *, va_list);
int snprintf(char *, size_t, const char *, ...);
int vsnprintf(char *, size_t, const char *, va_list);
int puts(const char *);
int fputs(const char *, FILE *);
int fputc(int, FILE *);
int putchar(int);
size_t fwrite(const void *, size_t, size_t, FILE *);
size_t fread(void *, size_t, size_t, FILE *);
char *fgets(char *, int, FILE *);
FILE *fopen(const char *, const char *);
int fclose(FILE *);
int fflush(FILE *);
int remove(const char *);
int rename(const char *, const char *);
int ferror(FILE *);
FILE *tmpfile(void);
long ftell(FILE *);
void rewind(FILE *);
int sscanf(const char *, const char *, ...);
#endif
