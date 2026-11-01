#include "nanoc/manage.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
@f nc_update_cmd(const char *cmd, const char *what) static int
  printf("  %s\n", what)
  fflush(stdout)
  int rc = system(cmd)
  rc == 0 ? 0 : 1
@f nc_update_command(const char *prefix) int
  if !nc_have_command("git")
    fputs("nanoc: update needs git\n", stderr)
    return 1
  const char *tmp = getenv("TMPDIR")
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s/nanoc-update-XXXXXX", tmp && *tmp ? tmp : "/tmp")
  if !mkdtemp(dir)
    fputs("nanoc: cannot create a temporary directory\n", stderr)
    return 1
  char cmd[PATH_MAX * 4]
  snprintf(cmd, sizeof cmd, "git clone -q --depth 1 https://github.com/mkalmousli/NanoC.git '%s/NanoC'", dir)
  int rc = nc_update_cmd(cmd, "Fetching the latest NanoC")
  if rc == 0
    snprintf(cmd, sizeof cmd, "cd '%s/NanoC' && cc -std=c11 -O2 build.c -o builder && ./builder install --prefix '%s'", dir, prefix)
    rc = nc_update_cmd(cmd, "Building and installing")
  snprintf(cmd, sizeof cmd, "rm -rf '%s'", dir)
  if system(cmd)
    fputs("nanoc: could not remove the temporary clone\n", stderr)
  rc
