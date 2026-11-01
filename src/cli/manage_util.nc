// Small file and process helpers for manage.
@use "nanoc/manage", errno, stdlib, string
// Tells if a path exists.
@f nc_exists(cstr path) bool
  struct stat st
  stat(path, &st) == 0
// Finds a command on PATH.
@f nc_search(cstr name, char *out) static bool
  const char *path = getenv("PATH")
  if not path then return false
  cstr p = path
  while *p
    const char *end = strchr(p, NC_PATH_LIST)
    usize n = end ? (usize)(end - p) : strlen(p)
    snprintf(out, PATH_MAX, "%.*s/%s", (int)n, n ? p : ".", name)
    if NC_RUNNABLE(out) then return true
    p = end ? end + 1 : p + n
  false
// Tells if a command is on PATH.
@f nc_have_command(cstr name) bool
  char found[PATH_MAX]
  nc_search(name, found)
// Finds the install prefix of argv0.
@f nc_prefix(cstr argv0, char *out) bool
  char exe[PATH_MAX]
  if strchr(argv0, '/')
    if !NC_REALPATH(argv0, exe) then return false
  elif !nc_search(argv0, exe) then return false
  char *slash = strrchr(exe, '/')
  if not slash then return false
  *slash = 0
  slash = strrchr(exe, '/')
  if not slash then return false
  *slash = 0
  snprintf(out, PATH_MAX, "%s", exe)
  true
// Creates a directory tree.
@f nc_make_dirs(cstr path) bool
  char copy[PATH_MAX]
  snprintf(copy, sizeof copy, "%s", path)
  for char *p = copy + 1; *p; ++p
    if *p == '/'
      *p = 0
      if NC_MKDIR(copy) and errno != EEXIST then return false
      *p = '/'
  if NC_MKDIR(copy) and errno != EEXIST then return false
  true
// Copies one file.
@f nc_copy_file(cstr from, cstr to) bool
  FILE *in = fopen(from, "rb")
  if not in then return false
  char dir[PATH_MAX]
  snprintf(dir, sizeof dir, "%s", to)
  char *slash = strrchr(dir, '/')
  if slash
    *slash = 0
    if !nc_make_dirs(dir) then fclose(in); return false
  FILE *out = fopen(to, "wb")
  if not out then fclose(in); return false
  char buf[8192]
  bool ok = true
  size_t n = fread(buf, 1, sizeof buf, in)
  while n
    if fwrite(buf, 1, n, out) != n then ok = false
    n = fread(buf, 1, sizeof buf, in)
  fclose(in)
  return fclose(out) == 0 and ok
// Asks a yes/no question.
@f nc_confirm(cstr question) bool
  printf("%s [y/N] ", question)
  fflush(stdout)
  char line[16]
  if !fgets(line, sizeof line, stdin) then return false
  line[0] == 'y' || line[0] == 'Y'
