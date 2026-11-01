// The uninstall command.
#include "nanoc/manage.h"
@use stdlib
@use string
@use unistd
// Removes empty parent directories.
@f mg_prune(const char *prefix, const char *path) static void
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s", path)
  char stop[PATH_MAX]
  snprintf(stop, sizeof stop, "%s/share/nanoc", prefix)
  while strlen(dir) > strlen(stop)
    char *slash = strrchr(dir, '/')
    if !slash
      return
    *slash = 0
    if rmdir(dir)
      return
// Deletes recorded files.
@f mg_remove_recorded(const char *prefix) static int
  int count = 0
  char list[PATH_MAX]
  snprintf(list, sizeof list, "%s/share/nanoc/install.manifest", prefix)
  FILE *f = fopen(list, "r")
  if !f
    return 0
  char line[PATH_MAX]
  while fgets(line, sizeof line, f)
    line[strcspn(line, "\n")] = 0
    if !*line || !strcmp(line, "share/nanoc/install.manifest")
      continue
    char path[PATH_MAX]
    snprintf(path, sizeof path, "%s/%s", prefix, line)
    if !remove(path)
      count += 1
    mg_prune(prefix, path)
  fclose(f)
  remove(list)
  count
// Runs the uninstall command.
@f nc_uninstall_command(int argc, char **argv, const char *prefix) int
  bool yes = argc && !strcmp(argv[0], "--yes")
  printf("Remove NanoC from %s, including editor integrations?\n", prefix)
  if !yes && !nc_confirm("Continue?")
    puts("Cancelled.")
    return 1
  char *editors[] = {"remove", "--all"}
  nc_editor_command(2, editors, prefix)
  int files = mg_remove_recorded(prefix)
  char bin[PATH_MAX]
  snprintf(bin, sizeof bin, "%s/bin", prefix)
  rmdir(bin)
  char share[PATH_MAX]
  snprintf(share, sizeof share, "%s/share/nanoc", prefix)
  char manifest[PATH_MAX]
  snprintf(manifest, sizeof manifest, "%s/editors.manifest", share)
  remove(manifest)
  rmdir(share)
  char top[PATH_MAX * 2]
  snprintf(top, sizeof top, "%s/share", prefix)
  rmdir(top)
  printf("Removed %d NanoC files. Your source projects were not touched.\n", files)
  0
