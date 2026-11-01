#ifndef NC_MANAGE_H
#define NC_MANAGE_H
/* Paths are bounded by PATH_MAX; snprintf truncation is handled by callers. */
#pragma GCC diagnostic ignored "-Wformat-truncation"
#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include <stddef.h>
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
typedef struct { const char *src; char dst[PATH_MAX]; } NcTarget;
int nc_manage(int, char **);
bool mg_home(char *);
bool mg_config(char *);
bool mg_sublime_dir(char *);
bool mg_detected(const char *);
bool mg_installed(const char *, const char *);
void mg_forget(const char *, const char *);
void mg_remember(const char *, const char *, const char *);
const char *nc_editor_name(size_t);
bool nc_known_editor(const char *);
int nc_targets(const char *, NcTarget *);
bool nc_prefix(const char *, char *);
bool nc_copy_file(const char *, const char *);
bool nc_make_dirs(const char *);
bool nc_exists(const char *);
bool nc_have_command(const char *);
bool nc_confirm(const char *);
int nc_editor_command(int, char **, const char *);
int nc_uninstall_command(int, char **, const char *);
int nc_update_command(const char *);
#endif
