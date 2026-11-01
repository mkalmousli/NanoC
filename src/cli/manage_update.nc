#include "nanoc/manage.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
@f nc_update_command(const char *prefix) int
  char script[PATH_MAX]
  snprintf(script, sizeof script, "%s/share/nanoc/install.sh", prefix)
  if !nc_exists(script)
    fputs("nanoc: installer missing; reinstall with the one-line installer\n", stderr)
    return 1
  char cmd[PATH_MAX * 2]
  snprintf(cmd, sizeof cmd, "sh '%s' update --prefix '%s'", script, prefix)
  system(cmd) == 0 ? 0 : 1
