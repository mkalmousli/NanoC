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
int nc_uninstall_command(int argc, char ** argv, const char * prefix);
bool nc_exists(const char * path);
bool nc_have_command(const char * name);
bool nc_prefix(const char * argv0, char * out);
bool nc_make_dirs(const char * path);
bool nc_copy_file(const char * from, const char * to);
bool nc_confirm(const char * question);
int main(int argc, char ** argv);
void nc_ui_line(bool ok, const char * name, const char * where);
int nc_editor_command(int argc, char ** argv, const char * prefix);
int nc_manage(int argc, char ** argv);
bool mg_home(char * out);
bool mg_config(char * out);
bool mg_sublime_dir(char * out);
void mg_add(NcTarget * t, int * n, const char * src, const char * dir, const char * rel);
void mg_vscode_at(NcTarget * t, int * n, const char * base);
void mg_vscode(NcTarget * t, int * n, const char * home);
const char * nc_editor_name(size_t i);
bool nc_known_editor(const char * name);
int nc_targets(const char * editor, NcTarget * t);
int nc_update_command(const char * prefix);
bool mg_detected(const char * name);
bool mg_installed(const char * prefix, const char * name);
void mg_forget(const char * prefix, const char * name);
void mg_remember(const char * prefix, const char * name, const char * dst);
#endif
