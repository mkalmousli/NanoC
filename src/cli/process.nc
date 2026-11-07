// Explicit CLI process execution uses argument vectors, never an implicit shell.
@lang 1
+ "nanoc/nanoc.h"

+ <errno.h>
// Reads a bounded process stream after execution.
f nc_process_stream(NcContext *c, FILE *file) -> char *
  if (fseek(file, 0, SEEK_END))
    nc_fail(c, 0, "cannot seek process stream")
  long count = ftell(file)
  if (count < 0 || (uintmax_t)count > c->max_output)
    nc_fail(c, 0, "process output limit exceeded")
  rewind(file)
  char *text = nc_alloc(c, (size_t)count + 1)
  if (fread(text, 1, (size_t)count, file) != (size_t)count)
    nc_fail(c, 0, "cannot read process stream")
  if (memchr(text, 0, (size_t)count))
    nc_fail(c, 0, "process output contains NUL bytes")
  return text

// Executes an explicitly requested executable and captures stdout, stderr and exit status.
f nc_process(NcContext *c, const char * *argv) -> NcProcess
  FILE *out = tmpfile(), *err = tmpfile()
  if (!out || !err)
    if (out)
      fclose(out)
    if (err)
      fclose(err)
    nc_fail(c, 0, "cannot open process streams")
  int status = 0
  #ifdef _WIN32
  int saved_out = _dup(1), saved_err = _dup(2)
  fflush(NULL)
  if (saved_out < 0 || saved_err < 0 || _dup2(_fileno(out),1) || _dup2(_fileno(err),2))
    nc_fail(c, 0, "cannot redirect process streams")
  intptr_t code = _spawnvp(_P_WAIT, argv[0], argv)
  _dup2(saved_out,1)
  _dup2(saved_err,2)
  _close(saved_out)
  _close(saved_err)
  status = code < 0 ? 127 : (int)code
  #else
  pid_t child = fork()
  if (child == 0)
    if (dup2(fileno(out),1) < 0 || dup2(fileno(err),2) < 0)
      _exit(126)
    execvp(argv[0], (char *const *)argv)
    _exit(127)
  if (child < 0)
    fclose(out); fclose(err); nc_fail(c, 0, "cannot create process")
  int result
  while (waitpid(child, &result, 0) < 0)
    if (errno != EINTR)
      fclose(out); fclose(err); nc_fail(c, 0, "cannot wait for process")
  status = WIFEXITED(result) ? WEXITSTATUS(result) : 128 + WTERMSIG(result)
  #endif
  NcProcess process = {status, nc_process_stream(c, out), nc_process_stream(c, err)}
  fclose(out)
  fclose(err)
  return process
