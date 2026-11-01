// Runs host processes for BT on Windows: one quoted command line through the shell, output captured in temporary files.
#ifdef _WIN32
// Appends an argument to the command line, quoted for the Windows shell.
@f quote(NcContext *c, NcBuffer *cmd, cstr arg) static void
  nc_add(c, cmd, "\"")
  for i:usize in 0..strlen(arg)
    if arg[i] == '"' then nc_add(c, cmd, "\\")
    nc_addn(c, cmd, arg + i, 1)
  nc_add(c, cmd, "\" ")
// Reads a whole file as text, or returns nil when it is unreadable or bigger than the limit.
@f slurp(NcContext *c, cstr path) static char *
  FILE *f = fopen(path, "rb")
  if not f then return nil
  fseek(f, 0, SEEK_END)
  long size = ftell(f)
  rewind(f)
  char *text = nil
  if size >= 0 and (usize)size <= c->max_output
    text = nc_alloc(c, (usize)size + 1)
    if fread(text, 1, (usize)size, f) != (usize)size then text = nil
  fclose(f)
  text
// Runs a host command and captures its status, stdout and stderr.
@f nc_host_run(NcMachine *m, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  if a.n != 1 and a.n != 2 then nc_fail(c, line, "run/exec expects argv[,cwd]")
  if a.v[0].kind != NC_LIST or !a.v[0].count then nc_fail(c, line, "command requires a nonempty argument list")
  cstr tmp = getenv(NC_TEMP_VAR)
  char out_path[PATH_MAX]
  char err_path[PATH_MAX]
  snprintf(out_path, sizeof out_path, "%s/nanoc-out-%d-%zu", tmp ? tmp : NC_TEMP_DEFAULT, _getpid(), ++c->serial)
  snprintf(err_path, sizeof err_path, "%s/nanoc-err-%d-%zu", tmp ? tmp : NC_TEMP_DEFAULT, _getpid(), ++c->serial)
  NcBuffer cmd = {0}
  nc_add(c, &cmd, "\"")
  if a.n == 2 then nc_printf(c, &cmd, "cd /d \"%s\" && ", nc_meta_text(c, a.v[1], line))
  for i:usize in 0..a.v[0].count then quote(c, &cmd, nc_meta_text(c, a.v[0].items[i], line))
  nc_printf(c, &cmd, ">\"%s\" 2>\"%s\"\"", out_path, err_path)
  int status = system(cmd.v)
  char *out = slurp(c, out_path), *err = slurp(c, err_path)
  remove(out_path)
  remove(err_path)
  if not out or not err then nc_fail(c, line, "command capture failed or output limit exceeded")
  NcValues result = {0}
  NC_PUSH(c, result, nc_integer(status))
  NC_PUSH(c, result, nc_value_text(NC_STRING, out))
  NC_PUSH(c, result, nc_value_text(NC_STRING, err))
  nc_list(result)
#endif
