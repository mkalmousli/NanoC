#include "nanoc/manage.h"
#include <stdlib.h>
#include <string.h>
#include <sys/utsname.h>
@f mg_home(char *out) bool
  const char *home = getenv(
    "HOME")
  if !home || !*home
    return false
  snprintf(out, PATH_MAX,
    "%s", home)
  true
@f mg_config(char *out) bool
  const char *xdg = getenv(
    "XDG_CONFIG_HOME")
  if xdg && *xdg
    snprintf(out, PATH_MAX,
      "%s", xdg)
    return true
  char home[PATH_MAX]
  if !mg_home(home)
    return false
  snprintf(out, PATH_MAX,
    "%s/.config", home)
  true
@f mg_sublime_dir(
  char *out
) bool
  char home[PATH_MAX]
  if !mg_home(home)
    return false
  struct utsname u
  uname(&u)
  if !strcmp(u.sysname,
    "Darwin")
    snprintf(out, PATH_MAX,
      "%s/Library/Applicatio"
      "n Support/Sublime "
      "Text/Packages/User",
      home)
  else
    snprintf(out, PATH_MAX,
      "%s/.config/sublime-te"
      "xt/Packages/User",
      home)
  true
@f mg_add(
  NcTarget *t, int *n,
  const char *src,
  const char *dir,
  const char *rel
) void
  t[*n].src = src
  snprintf(t[*n].dst,
    PATH_MAX, "%s/%s", dir,
    rel)
  *n += 1
@f mg_vscode_at(
  NcTarget *t, int *n,
  const char *base
) void
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir,
    "%s/extensions/mkalmousl"
    "i.nanoc-language-0.1.0",
    base)
  mg_add(t, n,
    "editors/vscode/package."
    "json", dir,
    "package.json")
  mg_add(t, n,
    "editors/vscode/language"
    "-configuration.json",
    dir,
    "language-configuration."
    "json")
  mg_add(t, n,
    "editors/vscode/syntaxes"
    "/nanoc.tmLanguage.json",
    dir,
    "syntaxes/nanoc.tmLangua"
    "ge.json")
  mg_add(t, n,
    "editors/vscode/icon.png",
    dir, "icon.png")
  mg_add(t, n,
    "editors/vscode/README.m"
    "d", dir, "README.md")
  mg_add(t, n,
    "editors/vscode/icons/na"
    "noc.svg", dir,
    "icons/nanoc.svg")
  mg_add(t, n,
    "editors/vscode/snippets"
    "/nanoc.code-snippets",
    dir,
    "snippets/nanoc.code-sni"
    "ppets")
@f mg_vscode(
  NcTarget *t, int *n,
  const char *home
) void
  const char *bases[] = {
    ".vscode", ".vscode-oss",
    ".cursor"}
  int found = 0
  for int i = 0; i < 3; ++i
    char base[PATH_MAX]
    snprintf(base,
      sizeof base, "%s/%s",
      home, bases[i])
    if nc_exists(base)
      mg_vscode_at(t, n, base)
      found += 1
  if !found
    char base[PATH_MAX]
    snprintf(base,
      sizeof base,
      "%s/.vscode", home)
    mg_vscode_at(t, n, base)
