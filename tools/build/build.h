#ifndef NC_BUILD_H
#define NC_BUILD_H
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <limits.h>
#include <stdint.h>
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
typedef struct { char *v[512]; size_t n; } BPaths;
typedef struct { const char *cc; bool sanitize; } BOptions;
void b_die(const char *);
void b_path(char *, const char *, const char *);
void b_mkdir(const char *);
void b_walk(BPaths *, const char *, const char *);
void b_paths_free(BPaths *);
int b_run(char *const *);
void b_compile(BOptions, bool);
int b_path_order(const void *, const void *);
void b_cc(BOptions, BPaths *, const char *, const char *, bool);
void b_generate(const char *, const char *);
bool b_equal(const char *, const char *);
void b_fixed_point(const char *, const char *);
void b_selfhost(BOptions);
uint64_t b_fingerprint(void);
void b_snapshot(void);
void b_install(const char *);
void b_uninstall(const char *);
void b_remove(const char *);
void b_copy(const char *, const char *);
bool b_exists(const char *);
void b_line_check(void);
#endif
