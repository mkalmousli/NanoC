#include "nanoc/manage.h"
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
@f nc_ui_line(bool ok, const char *name, const char *where) void
  bool tty = isatty(1)
  const char *mark = ok ? (tty ? "\033[32m✓\033[0m" : "✓") : (tty ? "\033[31m✗\033[0m" : "✗")
  printf("  %s %-9s %s\n", mark, name, where)
@f mg_install(const char *prefix, const char *name) static bool
  NcTarget t[16]
  int n = nc_targets(name, t)
  if n <= 0
    return false
  char share[PATH_MAX * 2]
  snprintf(share, sizeof share, "%s/share/nanoc", prefix)
  mg_forget(prefix, name)
  bool ok = true
  for int i = 0; i < n; ++i
    char from[PATH_MAX * 2]
    snprintf(from, sizeof from, "%s/%s", share, t[i].src)
    if nc_copy_file(from, t[i].dst)
      mg_remember(prefix, name, t[i].dst)
      nc_ui_line(true, name, t[i].dst)
    else
      nc_ui_line(false, name, t[i].dst)
      ok = false
  ok
@f mg_named(int argc, char **argv, int first, const char *name) static bool
  for int i = first; i < argc; ++i
    if !strcmp(argv[i], name)
      return true
  false
@f nc_editor_list(const char *prefix) static int
  printf("  %-9s %-10s %s\n", "EDITOR", "DETECTED", "INSTALLED")
  for size_t i = 0; nc_editor_name(i); ++i
    const char *name = nc_editor_name(i)
    printf("  %-9s %-10s %s\n", name, mg_detected(name) ? "yes" : "no", mg_installed(prefix, name) ? "yes" : "no")
  0
@f nc_editor_command(int argc, char **argv, const char *prefix) int
  int first = 0
  bool remove = argc && (!strcmp(argv[0], "remove") || !strcmp(argv[0], "uninstall"))
  if argc && (remove || !strcmp(argv[0], "install"))
    first = 1
  if argc && !strcmp(argv[0], "list")
    return nc_editor_list(prefix)
  bool all = false
  int named = 0
  for int i = first; i < argc; ++i
    if !strcmp(argv[i], "--all")
      all = true
    else
      if !nc_known_editor(argv[i])
        fprintf(stderr, "nanoc editor: unknown editor %s (try: nanoc editor list)\n", argv[i])
        return 2
      named += 1
  if remove && !all && !named
    fputs("usage: nanoc editor remove NAME|--all\n", stderr)
    return 2
  int status = 0
  int acted = 0
  for size_t i = 0; nc_editor_name(i); ++i
    const char *name = nc_editor_name(i)
    bool picked = all || mg_named(argc, argv, first, name) || (!named && !remove && mg_detected(name))
    if !picked
      continue
    acted += 1
    if remove
      if mg_installed(prefix, name)
        mg_forget(prefix, name)
        printf("  - %s removed\n", name)
    else
      if !mg_install(prefix, name)
        status = 1
  if !acted && !remove
    puts("No supported editors detected. Name one: nanoc editor install vim")
  status
