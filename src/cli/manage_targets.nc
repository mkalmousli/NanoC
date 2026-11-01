#include "nanoc/manage.h"
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
@f mg_home(char *out) bool
  const char *home = getenv("HOME")
  if !home || !*home
    return false
  snprintf(out, PATH_MAX, "%s", home)
  true
@f mg_config(char *out) bool
  const char *xdg = getenv("XDG_CONFIG_HOME")
  if xdg && *xdg
    snprintf(out, PATH_MAX, "%s", xdg)
    return true
  char home[PATH_MAX]
  if !mg_home(home)
    return false
  snprintf(out, PATH_MAX, "%s/.config", home)
  true
@f mg_sublime_dir(char *out) bool
  char home[PATH_MAX]
  if !mg_home(home)
    return false
  struct utsname u
  uname(&u)
  if !strcmp(u.sysname, "Darwin")
    snprintf(out, PATH_MAX, "%s/Library/Application Support/Sublime Text/Packages/User", home)
  else
    snprintf(out, PATH_MAX, "%s/.config/sublime-text/Packages/User", home)
  true
@f mg_add(NcTarget *t, int *n, const char *src, const char *dir, const char *rel) void
  t[*n].src = src
  snprintf(t[*n].dst, PATH_MAX, "%s/%s", dir, rel)
  *n += 1
@f mg_vscode_at(NcTarget *t, int *n, const char *base) void
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s/extensions/mkalmousli.nanoc-language-0.1.0", base)
  mg_add(t, n, "editors/vscode/package.json", dir, "package.json")
  mg_add(t, n, "editors/vscode/language-configuration.json", dir, "language-configuration.json")
  mg_add(t, n, "editors/vscode/syntaxes/nanoc.tmLanguage.json", dir, "syntaxes/nanoc.tmLanguage.json")
@f mg_vscode(NcTarget *t, int *n, const char *home) void
  const char *bases[] = {".vscode", ".vscode-oss", ".cursor"}
  int found = 0
  for int i = 0; i < 3; ++i
    char base[PATH_MAX]
    snprintf(base, sizeof base, "%s/%s", home, bases[i])
    if nc_exists(base)
      mg_vscode_at(t, n, base)
      found += 1
  if !found
    char base[PATH_MAX]
    snprintf(base, sizeof base, "%s/.vscode", home)
    mg_vscode_at(t, n, base)
@f nc_editor_name(size_t i) const char *
  static const char *names[] = {"vscode", "vim", "neovim", "emacs", "micro", "nano", "sublime", NULL}
  names[i]
@f nc_known_editor(const char *name) bool
  for size_t i = 0; nc_editor_name(i); ++i
    if !strcmp(name, nc_editor_name(i))
      return true
  false
@f nc_targets(const char *editor, NcTarget *t) int
  char home[PATH_MAX]
  char cfg[PATH_MAX]
  char dir[PATH_MAX]
  if !nc_known_editor(editor) || !mg_home(home) || !mg_config(cfg)
    return -1
  int n = 0
  if !strcmp(editor, "vscode")
    mg_vscode(t, &n, home)
  if !strcmp(editor, "vim") || !strcmp(editor, "neovim")
    if !strcmp(editor, "vim")
      snprintf(dir, sizeof dir, "%s/.vim", home)
    else
      snprintf(dir, sizeof dir, "%s/nvim", cfg)
    mg_add(t, &n, "editors/vim/nanoc.vim", dir, "syntax/nanoc.vim")
    mg_add(t, &n, "editors/vim/ftdetect/nanoc.vim", dir, "ftdetect/nanoc.vim")
  if !strcmp(editor, "emacs")
    char emacs[PATH_MAX]
    snprintf(emacs, sizeof emacs, "%s/.emacs.d", home)
    if nc_exists(emacs)
      snprintf(dir, sizeof dir, "%s/lisp", emacs)
    else
      snprintf(dir, sizeof dir, "%s/emacs/lisp", cfg)
    mg_add(t, &n, "editors/emacs/nanoc-mode.el", dir, "nanoc-mode.el")
  if !strcmp(editor, "micro")
    snprintf(dir, sizeof dir, "%s/micro/syntax", cfg)
    mg_add(t, &n, "editors/micro/nanoc.yaml", dir, "nanoc.yaml")
  if !strcmp(editor, "nano")
    snprintf(dir, sizeof dir, "%s/.nano", home)
    mg_add(t, &n, "editors/nano/nanoc.nanorc", dir, "nanoc.nanorc")
  if !strcmp(editor, "sublime") && mg_sublime_dir(dir)
    mg_add(t, &n, "editors/sublime/NanoC.sublime-syntax", dir, "NanoC.sublime-syntax")
  n
