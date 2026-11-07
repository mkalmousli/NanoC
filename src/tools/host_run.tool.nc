// Runs host processes for the external repository tool runner (POSIX: fork and exec; Windows: see host_run_win.nc).
@lang 1
+ "nanoc/nanoc.h"

+ <errno.h>

#ifndef _WIN32
#include <fcntl.h>
// Runs a host command, captures it.
f nc_host_run(NcMachine *m, NcValues a, int line) -> NcValue
  NcContext *c = m->ctx
  if (a.n != 1 && a.n != 2)
    nc_fail(c, line, "run/exec expects argv[,cwd]")
  if (a.v[0].kind != NC_LIST || !a.v[0].count)
    nc_fail(c, line, "command requires a nonempty argument list")
  NcValue list = a.v[0]
  char **argv = nc_alloc(c, (list.count + 1) * sizeof *argv)
  for (size_t i = (0), nanoc_bound_1 = (list.count); i < nanoc_bound_1; ++i)
    argv[i] = (char *)nc_meta_text(c, list.items[i], line)
  const char * cwd = a.n == 2 ? nc_meta_text(c, a.v[1], line) : NULL
  char out_path[32]
  char err_path[32]
  strcpy(out_path, "/tmp/nanoc-out-XXXXXX")
  strcpy(err_path, "/tmp/nanoc-err-XXXXXX")
  int out = mkstemp(out_path), err = mkstemp(err_path)
  if (out < 0 || err < 0)
    if (out >= 0)
      close(out); unlink(out_path)
    if (err >= 0)
      close(err); unlink(err_path)
    nc_fail(c, line, "cannot create process capture files")
  pid_t pid = fork()
  if (! pid)
    if (dup2(out, 1) < 0 || dup2(err, 2) < 0)
      _exit(126)
    close(out)
    close(err)
    if (cwd && chdir(cwd))
      _exit(126)
    execvp(argv[0], argv)
    _exit(127)
  if (pid < 0)
    close(out)
    close(err)
    unlink(out_path)
    unlink(err_path)
    nc_fail(c, line, "cannot fork build command")
  int status = 0
  pid_t waited
  while (1)
    waited = waitpid(pid, &status, 0)
    if (!(waited < 0 && errno == EINTR))
      break
  struct stat so, se
  bool valid = waited >= 0 && !fstat(out, &so) && !fstat(err, &se)
  char *stdout_text = NULL
  char *stderr_text = NULL
  if (valid && so.st_size >= 0 && se.st_size >= 0 && (uintmax_t)so.st_size <= c->max_output
      && (uintmax_t)se.st_size <= c->max_output)
    stdout_text = nc_alloc(c, (size_t)so.st_size + 1)
    stderr_text = nc_alloc(c, (size_t)se.st_size + 1)
    valid = lseek(out, 0, SEEK_SET) >= 0 && lseek(err, 0, SEEK_SET) >= 0
    size_t sizes[] = {(size_t)so.st_size, (size_t)se.st_size}
    int fds[] = {out, err}
    char *texts[] = {stdout_text, stderr_text}
    for (size_t i = 0; valid && i < 2; ++i)
      for (size_t n = 0; n < sizes[i];)
        ssize_t got = read(fds[i], texts[i] + n, sizes[i] - n)
        if (got < 0 && errno == EINTR)
          continue
        if (got <= 0)
          valid = 0; break
        n += (size_t)got
  else
    valid = 0
  close(out)
  close(err)
  unlink(out_path)
  unlink(err_path)
  if (! valid)
    nc_fail(c, line, "command capture failed or output limit exceeded")
  if (strlen(stdout_text) != (size_t)so.st_size || strlen(stderr_text) != (size_t)se.st_size)
    nc_fail(c, line, "command output must be text (NUL byte found)")
  NcValues result = {0}
  NC_PUSH(c, result, nc_integer(WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status)))
  NC_PUSH(c, result, nc_value_text(NC_STRING, stdout_text))
  NC_PUSH(c, result, nc_value_text(NC_STRING, stderr_text))
  return nc_list(result)

#endif
