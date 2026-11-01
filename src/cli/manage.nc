#include "nanoc/manage.h"
#include <stdlib.h>
#include <string.h>
@f nc_manage(int argc, char **argv) int
  if argc < 2
    return -1
  const char *cmd = argv[1]
  bool editor = !strcmp(cmd, "editor")
  bool uninstall = !strcmp(cmd, "uninstall")
  bool update = !strcmp(cmd, "update")
  if !editor && !uninstall && !update
    return -1
  char prefix[PATH_MAX]
  if !nc_prefix(argv[0], prefix)
    fputs("nanoc: cannot locate the installation\n", stderr)
    return 1
  if editor
    return nc_editor_command(argc - 2, argv + 2, prefix)
  if uninstall
    return nc_uninstall_command(argc - 2, argv + 2, prefix)
  nc_update_command(prefix)
