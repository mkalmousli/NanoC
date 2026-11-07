#ifndef NC_MANAGE_H
#define NC_MANAGE_H
// Manage command types.

#define _XOPEN_SOURCE 700

/* Paths are bounded by PATH_MAX; snprintf truncation is handled by callers. */

#pragma GCC diagnostic ignored "-Wformat-truncation"
#include <stdio.h>
#include <stdbool.h>
#include <limits.h>
#include <stddef.h>
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

typedef struct NcTarget NcTarget;
struct NcTarget {
    const char *src;
    char dst[PATH_MAX];
};
int nc_uninstall_command(int argc, char **argv, const char *prefix);
void nc_process_json(FILE *out, const char *stage, NcProcess process);
char *nc_optional_tool(NcContext *c, const char *name);
const char *nc_python(void);
int nc_convert_command(NcContext *c, int argc, const char * *argv);
int nc_bench_command(NcContext *c,int argc,const char **argv);
int nc_doctor(NcContext *c,int argc,char **argv);
int nc_test_command(NcContext *c,int argc,char **argv);
bool nc_exists(const char *path);
bool nc_have_command(const char *name);
char *nc_last_separator(char *path);
bool nc_prefix(const char *argv0, char *out);
bool nc_make_dirs(const char *path);
bool nc_copy_file(const char *from, const char *to);
bool nc_confirm(const char *question);
int main(int argc, char **argv);
int nc_tokens_command(NcContext *c, int argc, const char **argv);
void nc_ui_line(bool ok, const char *name, const char *where);
int nc_editor_command(int argc, char **argv, const char *prefix);
int nc_manage(int argc, char **argv);
const char *nc_editor_name(size_t i);
bool nc_known_editor(const char *name);
int nc_targets(const char *editor, NcTarget *t);
bool mg_home(char *out);
bool mg_config(char *out);
bool mg_sublime_dir(char *out);
void mg_add(NcTarget *t, int *n, const char *src, const char *dir, const char *rel);
void mg_vscode_at(NcTarget *t, int *n, const char *base);
void mg_vscode(NcTarget *t, int *n, const char *home);
void build_unit(NcContext *c,const char *input,const char *file,bool lines);
int nc_build_command(NcContext *c,int argc,const char **argv);
int nc_update_command(const char *prefix);
bool mg_detected(const char *name);
bool mg_installed(const char *prefix, const char *name);
void mg_forget(const char *prefix, const char *name);
void mg_remember(const char *prefix, const char *name, const char *dst);
#endif
