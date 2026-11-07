// Editor config locations on this host.
@lang 1
+ "nanoc/nanoc.h"

+ "nanoc/manage.h"
+ <stdlib.h>
+ <string.h>

// Finds the user home directory.
f mg_home(char *out) bool
  const char *home = getenv(NC_HOME_VAR)
  if !home || !*home
    < 0
  snprintf(out, PATH_MAX, "%s", home)
  < 1

// Finds the user config directory.
f mg_config(char *out) bool
  const char *xdg = getenv("XDG_CONFIG_HOME")
  if xdg && *xdg
    snprintf(out, PATH_MAX, "%s", xdg)
    < 1
  char home[PATH_MAX]
  if !mg_home(home)
    < 0
  snprintf(out, PATH_MAX, NC_CONFIG_DIR, home)
  < 1

// Finds the Sublime packages dir.
f mg_sublime_dir(char *out) bool
  char home[PATH_MAX]
  if !mg_home(home)
    < 0
  snprintf(out, PATH_MAX, NC_SUBLIME_DIR, home)
  < 1

// Adds a file to the targets.
f mg_add(NcTarget *t, int *n, const char *src, const char *dir, const char *rel)
  t[*n].src = src
  snprintf(t[*n].dst, PATH_MAX, "%s/%s", dir, rel)
  *n += 1

// Adds VS Code targets under a base.
f mg_vscode_at(NcTarget *t, int *n, const char *base)
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s/extensions/mkalmousli.nanoc-language-0.1.0", base)
  mg_add(t, n, "editors/vscode/package.json", dir, "package.json")
  mg_add(t, n, "editors/vscode/language-configuration.json", dir, "language-configuration.json")
  mg_add(t, n, "editors/vscode/syntaxes/nanoc.tmLanguage.json", dir,
          "syntaxes/nanoc.tmLanguage.json")
  mg_add(t, n, "editors/vscode/icon.png", dir, "icon.png")
  mg_add(t, n, "editors/vscode/README.md", dir, "README.md")
  mg_add(t, n, "editors/vscode/icons/nanoc.svg", dir, "icons/nanoc.svg")
  mg_add(t, n, "editors/vscode/snippets/nanoc.code-snippets", dir, "snippets/nanoc.code-snippets")

// Adds all VS Code targets.
f mg_vscode(NcTarget *t, int *n, const char *home)
  const char *bases[] = {".vscode", ".vscode-oss", ".cursor"}
  int found = 0
  for int i = (0), nanoc_bound_1 = (3); i < nanoc_bound_1; ++i
    char base[PATH_MAX]
    snprintf(base, sizeof base, "%s/%s", home, bases[i])
    if nc_exists(base)
      mg_vscode_at(t, n, base)
      found += 1
  if ! found
    char base[PATH_MAX]
    snprintf(base, sizeof base, "%s/.vscode", home)
    mg_vscode_at(t, n, base)
