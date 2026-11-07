// Runs host processes for BT on Windows: one quoted command line through the shell, output captured in temporary files.
@lang 1
+ "nanoc/nanoc.h"

#ifdef _WIN32
// Appends an argument to the command line, quoted for the Windows shell.
f quote(NcContext *c, NcBuffer *cmd, const char *arg) -> static void
  nc_add(c, cmd, "\"")
  for (size_t i = (0), nanoc_bound_1 = (strlen(arg)); i < nanoc_bound_1; ++i)
    if (arg[i] == '"')
      nc_add(c, cmd, "\\")
    nc_addn(c, cmd, arg + i, 1)
  nc_add(c, cmd, "\" ")

// Reads a whole file as text, or returns nil when it is unreadable or bigger than the limit.
f slurp(NcContext *c, const char *path) -> static char *
  FILE *f = fopen(path, "rb")
  if (! f)
    return NULL
  fseek(f, 0, SEEK_END)
  long size = ftell(f)
  rewind(f)
  char *text = NULL
  if (size >= 0 && (size_t)size <= c->max_output)
    text = nc_alloc(c, (size_t)size + 1)
    if (fread(text, 1, (size_t)size, f) != (size_t)size)
      text = NULL
  fclose(f)
  return text

// Runs a host command and captures its status, stdout and stderr.
f nc_host_run(NcMachine *m, NcValues a, int line) -> NcValue
  NcContext *c = m->ctx
  if (a.n != 1 && a.n != 2)
    nc_fail(c, line, "run/exec expects argv[,cwd]")
  if (a.v[0].kind != NC_LIST || !a.v[0].count)
    nc_fail(c, line, "command requires a nonempty argument list")
  const char * tmp = getenv(NC_TEMP_VAR)
  char out_path[PATH_MAX]
  char err_path[PATH_MAX]
  snprintf(out_path, sizeof out_path, "%s/nanoc-out-%d-%zu", tmp ? tmp : NC_TEMP_DEFAULT, _getpid(), ++c->serial)
  snprintf(err_path, sizeof err_path, "%s/nanoc-err-%d-%zu", tmp ? tmp : NC_TEMP_DEFAULT, _getpid(), ++c->serial)
  NcBuffer cmd = {0}
  nc_add(c, &cmd, "\"")
  if (a.n == 2)
    nc_printf(c, &cmd, "cd /d \"%s\" && ", nc_meta_text(c, a.v[1], line))
  for (size_t i = (0), nanoc_bound_2 = (a.v[0].count); i < nanoc_bound_2; ++i)
    quote(c, &cmd, nc_meta_text(c, a.v[0].items[i], line))
  nc_printf(c, &cmd, ">\"%s\" 2>\"%s\"\"", out_path, err_path)
  int status = system(cmd.v)
  char *out = slurp(c, out_path), *err = slurp(c, err_path)
  remove(out_path)
  remove(err_path)
  if (! out || ! err)
    nc_fail(c, line, "command capture failed or output limit exceeded")
  NcValues result = {0}
  NC_PUSH(c, result, nc_integer(status))
  NC_PUSH(c, result, nc_value_text(NC_STRING, out))
  NC_PUSH(c, result, nc_value_text(NC_STRING, err))
  return nc_list(result)

#endif
