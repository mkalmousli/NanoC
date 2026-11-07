// Small file and process helpers for manage.
@lang 1
+ "nanoc/nanoc.h"

+ "nanoc/manage.h"
+ <errno.h>
+ <stdlib.h>
+ <string.h>

// Tells if a path exists.
f nc_exists(const char *path) bool
  struct stat st
  < stat(path, &st) == 0

// Finds a command on PATH.
f nc_search(const char *name, char *out) static bool
  const char *path = getenv("PATH")
  if ! path
    < 0
  const char * p = path
  while *p
    const char *end = strchr(p, NC_PATH_LIST)
    size_t n = end ? (size_t)(end - p) : strlen(p)
    snprintf(out, PATH_MAX, "%.*s/%s", (int)n, n ? p : ".", name)
    if NC_RUNNABLE(out)
      < 1
    p = end ? end + 1 : p + n
  < 0

// Tells if a command is on PATH.
f nc_have_command(const char *name) bool
  char found[PATH_MAX]
  < nc_search(name, found)

// Finds either platform's final path separator without using a shell.
f nc_last_separator(char *path) char *
  char *forward = strrchr(path, '/')
  char *backward = strrchr(path, '\\')
  if !forward
    < backward
  if !backward
    < forward
  < forward > backward ? forward : backward

// Finds the install prefix of argv0.
f nc_prefix(const char *argv0, char *out) bool
  char exe[PATH_MAX]
  if strchr(argv0, '/') || strchr(argv0, '\\')
    if !NC_REALPATH(argv0, exe)
      < 0
  elif !nc_search(argv0, exe)
    < 0
  char *slash = nc_last_separator(exe)
  if ! slash
    < 0
  *slash = 0
  slash = nc_last_separator(exe)
  if ! slash
    < 0
  *slash = 0
  snprintf(out, PATH_MAX, "%s", exe)
  < 1

// Creates a directory tree.
f nc_make_dirs(const char *path) bool
  char copy[PATH_MAX]
  snprintf(copy, sizeof copy, "%s", path)
  for char *p = copy + 1; *p; ++p
    if *p == '/'
      *p = 0
      if NC_MKDIR(copy) && errno != EEXIST
        < 0
      *p = '/'
  if NC_MKDIR(copy) && errno != EEXIST
    < 0
  < 1

// Copies one file.
f nc_copy_file(const char *from, const char *to) bool
  FILE *in = fopen(from, "rb")
  if ! in
    < 0
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s", to)
  char *slash = strrchr(dir, '/')
  if slash
    *slash = 0
    if !nc_make_dirs(dir)
      fclose(in)
      < 0
  FILE *out = fopen(to, "wb")
  if ! out
    fclose(in)
    < 0
  char buf[8192]
  bool ok = 1
  size_t n = fread(buf, 1, sizeof buf, in)
  while n
    if fwrite(buf, 1, n, out) != n
      ok = 0
    n = fread(buf, 1, sizeof buf, in)
  fclose(in)
  < fclose(out) == 0 && ok

// Asks a yes/no question.
f nc_confirm(const char *question) bool
  printf("%s [y/N] ", question)
  fflush(stdout)
  char line[16]
  if !fgets(line, sizeof line, stdin)
    < 0
  < line[0] == 'y' || line[0] == 'Y'
