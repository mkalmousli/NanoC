#ifndef NC_WEB_SYS_STAT_H
#define NC_WEB_SYS_STAT_H
#include <stdint.h>
struct stat { int64_t st_size; unsigned st_mode; };
int stat(const char *, struct stat *);
int fstat(int, struct stat *);
#endif
