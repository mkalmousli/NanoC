// Editor config locations on this host.
@use "nanoc/manage", stdlib, string, sys/utsname
// Finds the user home directory.
@f mg_home(char *out) bool
  const char *home = getenv("HOME")
  if !home or !*home then return false
  snprintf(out, PATH_MAX, "%s", home)
  true
// Finds the user config directory.
@f mg_config(char *out) bool
  const char *xdg = getenv("XDG_CONFIG_HOME")
  if xdg and *xdg then snprintf(out, PATH_MAX, "%s", xdg); return true
  char home[PATH_MAX]
  if !mg_home(home) then return false
  snprintf(out, PATH_MAX, "%s/.config", home)
  true
// Finds the Sublime packages dir.
@f mg_sublime_dir(char *out) bool
  char home[PATH_MAX]
  if !mg_home(home) then return false
  struct utsname u
  uname(&u)
  if !strcmp(u.sysname, "Darwin") then snprintf(out, PATH_MAX, "%s/Library/Application Support/Sublime Text/Packages/User", home)
  else snprintf(out, PATH_MAX, "%s/.config/sublime-text/Packages/User", home)
  true
// Adds a file to the targets.
@f mg_add(NcTarget *t, int *n, cstr src, cstr dir, cstr rel) void
  t[*n].src = src
  snprintf(t[*n].dst, PATH_MAX, "%s/%s", dir, rel)
  *n += 1
// Adds VS Code targets under a base.
@f mg_vscode_at(NcTarget *t, int *n, cstr base) void
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
@f mg_vscode(NcTarget *t, int *n, cstr home) void
  const char *bases[] = {".vscode", ".vscode-oss", ".cursor"}
  int found = 0
  for i in 0..3
    char base[PATH_MAX]
    snprintf(base, sizeof base, "%s/%s", home, bases[i])
    if nc_exists(base) then mg_vscode_at(t, n, base); found += 1
  if not found then char base[PATH_MAX]; snprintf(base, sizeof base, "%s/.vscode", home); mg_vscode_at(t, n, base)
