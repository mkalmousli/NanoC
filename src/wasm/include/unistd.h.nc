#ifndef NC_WEB_UNISTD_H
#define NC_WEB_UNISTD_H
#include <stddef.h>
int unlink(const char *);
int access(const char *, int);
int chdir(const char *);
int mkdir(const char *, unsigned);
typedef long ssize_t;
ssize_t write(int, const void *, size_t);
int close(int);
int isatty(int);
int rmdir(const char *);
#define F_OK 0
#define X_OK 1
#endif
