#include "nanoc/manage.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
@f mg_manifest(const char *prefix, char *out) static void
  snprintf(out, PATH_MAX, "%s/share/nanoc/editors.manifest", prefix)
@f mg_detected(const char *name) bool
  char home[PATH_MAX]
  char cfg[PATH_MAX]
  char dir[PATH_MAX]
  if !mg_home(home) || !mg_config(cfg)
    return false
  if !strcmp(name, "vscode")
    snprintf(dir, sizeof dir, "%s/.vscode", home)
    return nc_exists(dir) || nc_have_command("code")
  if !strcmp(name, "vim")
    snprintf(dir, sizeof dir, "%s/.vim", home)
    return nc_exists(dir) || nc_have_command("vim")
  if !strcmp(name, "neovim")
    snprintf(dir, sizeof dir, "%s/nvim", cfg)
    return nc_exists(dir) || nc_have_command("nvim")
  if !strcmp(name, "emacs")
    snprintf(dir, sizeof dir, "%s/.emacs.d", home)
    return nc_have_command("emacs") || nc_exists(dir)
  if !strcmp(name, "micro")
    snprintf(dir, sizeof dir, "%s/micro", cfg)
    return nc_exists(dir) || nc_have_command("micro")
  if !strcmp(name, "nano")
    return nc_have_command("nano")
  if !strcmp(name, "sublime")
    return nc_have_command("subl") || (mg_sublime_dir(dir) && nc_exists(dir))
  false
@f mg_installed(const char *prefix, const char *name) bool
  char path[PATH_MAX]
  mg_manifest(prefix, path)
  FILE *f = fopen(path, "r")
  if !f
    return false
  char line[PATH_MAX + 64]
  bool found = false
  size_t len = strlen(name)
  while fgets(line, sizeof line, f)
    if !strncmp(line, name, len) && line[len] == ' '
      found = true
  fclose(f)
  found
@f mg_forget(const char *prefix, const char *name) void
  char path[PATH_MAX]
  char tmp[PATH_MAX + 8]
  mg_manifest(prefix, path)
  snprintf(tmp, sizeof tmp, "%s.tmp", path)
  FILE *in = fopen(path, "r")
  if !in
    return
  FILE *out = fopen(tmp, "w")
  if !out
    fclose(in)
    return
  char line[PATH_MAX + 64]
  size_t len = strlen(name)
  while fgets(line, sizeof line, in)
    line[strcspn(line, "\n")] = 0
    if !strncmp(line, name, len) && line[len] == ' '
      remove(line + len + 1)
    else
      fputs(line, out)
  fclose(in)
  fclose(out)
  rename(tmp, path)
@f mg_remember(const char *prefix, const char *name, const char *dst) void
  char path[PATH_MAX]
  mg_manifest(prefix, path)
  FILE *f = fopen(path, "a")
  if f
    fprintf(f, "%s %s\n", name, dst)
    fclose(f)
