// File builtins: read, write, mkdir.
@use "nanoc/nanoc", sys/stat, errno
// Creates the parent directories.
@f directories(NcContext *c, cstr path, int line) static void
  char *copy = nc_string(c, path, strlen(path))
  if !*copy then nc_fail(c, line, "empty directory path")
  for char *p = copy + 1; ; ++p
    if *p && *p != '/' then continue
    char last = *p
    *p = 0
    if mkdir(copy, 0755) and errno != EEXIST then nc_fail(c, line, "cannot create directory %s: %s", copy, strerror(errno))
    *p = last
    if not last then break
// Runs file builtins.
@f nc_meta_files(NcMachine *m, cstr name, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  if !strcmp(name, "file")
    nc_arity(c, a, 0, line)
    return nc_value_text(NC_STRING, (char *)c->file)
  nc_arity(c, a, !strcmp(name, "write") ? 2 : 1, line)
  cstr path = nc_meta_text(c, a.v[0], line)
  if !strcmp(name, "read") then return nc_value_text(NC_STRING, nc_read(c, path))
  if !strcmp(name, "exists")
    struct stat st
    return nc_boolean(stat(path, &st) == 0)
  if !strcmp(name, "env") then return nc_value_text(NC_STRING, getenv(path) ? getenv(path) : "")
  nc_effect(m, line)
  if !strcmp(name, "write") then nc_write(c, path, nc_meta_text(c, a.v[1], line))
  elif !strcmp(name, "mkdir") then directories(c, path, line)
  elif !strcmp(name, "remove") && remove(path) && errno != ENOENT
    nc_fail(c, line, "cannot remove %s: %s", path, strerror(errno))
  nc_integer(0)
