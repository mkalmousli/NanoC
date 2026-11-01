// Records which editor files were installed.
@use "nanoc/manage", stdlib, string, unistd
// Gets the install manifest path.
@f mg_manifest(cstr prefix, char *out) static void
  snprintf(out, PATH_MAX, "%s/share/nanoc/editors.manifest", prefix)
// Tells if an editor is present.
@f mg_detected(cstr name) bool
  char home[PATH_MAX]
  char cfg[PATH_MAX]
  char dir[PATH_MAX]
  if !mg_home(home) or !mg_config(cfg)
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
// Tells if an editor is installed.
@f mg_installed(cstr prefix, cstr name) bool
  char path[PATH_MAX]
  mg_manifest(prefix, path)
  FILE *f = fopen(path, "r")
  if not f
    return false
  char line[PATH_MAX + 64]
  bool found = false
  usize len = strlen(name)
  while fgets(line, sizeof line, f)
    if !strncmp(line, name, len) && line[len] == ' '
      found = true
  fclose(f)
  found
// Drops an editor from the manifest.
@f mg_forget(cstr prefix, cstr name) void
  char path[PATH_MAX]
  char tmp[PATH_MAX + 8]
  mg_manifest(prefix, path)
  snprintf(tmp, sizeof tmp, "%s.tmp", path)
  FILE *in = fopen(path, "r")
  if not in
    return
  FILE *out = fopen(tmp, "w")
  if not out
    fclose(in)
    return
  char line[PATH_MAX + 64]
  usize len = strlen(name)
  while fgets(line, sizeof line, in)
    line[strcspn(line, "\n")] = 0
    if !strncmp(line, name, len) && line[len] == ' '
      remove(line + len + 1)
    else
      fputs(line, out)
  fclose(in)
  fclose(out)
  rename(tmp, path)
// Records an installed file.
@f mg_remember(cstr prefix, cstr name, cstr dst) void
  char path[PATH_MAX]
  mg_manifest(prefix, path)
  FILE *f = fopen(path, "a")
  if f
    fprintf(f, "%s %s\n", name, dst)
    fclose(f)
