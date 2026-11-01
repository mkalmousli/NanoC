#include "nanoc/manage.h"
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
@f nc_exists(
  const char *path
) bool
  struct stat st
  stat(path, &st) == 0
@f nc_search(
  const char *name, char *out
) static bool
  const char *path = getenv(
    "PATH")
  if !path
    return false
  const char *p = path
  while *p
    const char *end = strchr(
      p, ':')
    size_t n = (end
      ? (size_t)(end - p)
      : strlen(p))
    snprintf(out, PATH_MAX,
      "%.*s/%s", (int)n,
      n ? p : ".", name)
    if access(out, X_OK) == 0
      return true
    p = end ? end + 1 : p + n
  false
@f nc_have_command(
  const char *name
) bool
  char found[PATH_MAX]
  nc_search(name, found)
@f nc_prefix(
  const char *argv0, char *out
) bool
  char exe[PATH_MAX]
  if strchr(argv0, '/')
    if !realpath(argv0, exe)
      return false
  elif !nc_search(argv0, exe)
    return false
  char *slash = strrchr(exe,
    '/')
  if !slash
    return false
  *slash = 0
  slash = strrchr(exe, '/')
  if !slash
    return false
  *slash = 0
  snprintf(out, PATH_MAX,
    "%s", exe)
  true
@f nc_make_dirs(
  const char *path
) bool
  char copy[PATH_MAX]
  snprintf(copy, sizeof copy,
    "%s", path)
  for (char *p = copy + 1; *p;
    ++p)
    if *p == '/'
      *p = 0
      if (mkdir(copy, 0755)
        && errno != EEXIST)
        return false
      *p = '/'
  if (mkdir(copy, 0755)
    && errno != EEXIST)
    return false
  true
@f nc_copy_file(
  const char *from,
  const char *to
) bool
  FILE *in = fopen(from, "rb")
  if !in
    return false
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir,
    "%s", to)
  char *slash = strrchr(dir,
    '/')
  if slash
    *slash = 0
    if !nc_make_dirs(dir)
      fclose(in)
      return false
  FILE *out = fopen(to, "wb")
  if !out
    fclose(in)
    return false
  char buf[8192]
  bool ok = true
  size_t n = fread(buf, 1,
    sizeof buf, in)
  while n
    if (fwrite(buf, 1, n, out)
      != n)
      ok = false
    n = fread(buf, 1,
      sizeof buf, in)
  fclose(in)
  return (fclose(out) == 0
    && ok)
@f nc_confirm(
  const char *question
) bool
  printf("%s [y/N] ",
    question)
  fflush(stdout)
  char line[16]
  if !fgets(line, sizeof line,
    stdin)
    return false
  line[0] == 'y' || line[
    0] == 'Y'
