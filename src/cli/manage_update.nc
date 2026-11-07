// The update command.
@lang 1
+ "nanoc/nanoc.h"

+ "nanoc/manage.h"
+ <stdio.h>
+ <stdlib.h>
+ <string.h>
+ <time.h>

// Runs a shell step, with label.
f nc_update_cmd(const char *cmd, const char *what) static int
  printf("  %s\n", what)
  fflush(stdout)
  int rc = system(cmd)
  < rc == 0 ? 0 : 1

// Runs the update command.
f nc_update_command(const char *prefix) int
  if !nc_have_command("git")
    fputs("nanoc: update needs git\n", stderr)
    < 1
  const char *tmp = getenv(NC_TEMP_VAR)
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s/nanoc-update-%lx", tmp && *tmp ? tmp : NC_TEMP_DEFAULT, (unsigned long)time(NULL))
  if NC_MKDIR(dir)
    fputs("nanoc: cannot create a temporary directory\n", stderr)
    < 1
  char cmd[PATH_MAX * 4]
  snprintf(cmd, sizeof cmd,
          "git clone -q --depth 1 https://github.com/mkalmousli/NanoC.git \"%s/NanoC\"", dir)
  int rc = nc_update_cmd(cmd, "Fetching the latest NanoC")
  if rc == 0
    snprintf(cmd, sizeof cmd,
                  "cd \"%s/NanoC\" && cc -std=c11 -O2 build.c -o builder && ./builder install --prefix \"%s\"", dir,
                  prefix)
    rc = nc_update_cmd(cmd, "Building and installing")
  snprintf(cmd, sizeof cmd, NC_SHELL_RMTREE, dir)
  if system(cmd)
    fputs("nanoc: could not remove the temporary clone\n", stderr)
  < rc
