// Runs host processes for BT (POSIX: fork and exec; Windows: see host_run_win.nc).
@use errno
#ifndef _WIN32
#include <fcntl.h>
// Runs a host command, captures it.
@f nc_host_run(NcMachine *m, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  if a.n != 1 and a.n != 2 then nc_fail(c, line, "run/exec expects argv[,cwd]")
  if a.v[0].kind != NC_LIST or !a.v[0].count then nc_fail(c, line, "command requires a nonempty argument list")
  NcValue list = a.v[0]
  char **argv = nc_alloc(c, (list.count + 1) * sizeof *argv)
  for i:usize in 0..list.count then argv[i] = (char *)nc_meta_text(c, list.items[i], line)
  cstr cwd = a.n == 2 ? nc_meta_text(c, a.v[1], line) : nil
  char out_path[32]
  char err_path[32]
  strcpy(out_path, "/tmp/nanoc-out-XXXXXX")
  strcpy(err_path, "/tmp/nanoc-err-XXXXXX")
  int out = mkstemp(out_path), err = mkstemp(err_path)
  if out < 0 or err < 0
    if out >= 0 then close(out); unlink(out_path)
    if err >= 0 then close(err); unlink(err_path)
    nc_fail(c, line, "cannot create process capture files")
  pid_t pid = fork()
  if not pid
    if dup2(out, 1) < 0 or dup2(err, 2) < 0 then _exit(126)
    close(out)
    close(err)
    if cwd and chdir(cwd) then _exit(126)
    execvp(argv[0], argv)
    _exit(127)
  if pid < 0
    close(out)
    close(err)
    unlink(out_path)
    unlink(err_path)
    nc_fail(c, line, "cannot fork build command")
  int status = 0
  pid_t waited
  while 1
    waited = waitpid(pid, &status, 0)
    if !(waited < 0 and errno == EINTR) then break
  struct stat so, se
  bool valid = waited >= 0 and !fstat(out, &so) and !fstat(err, &se)
  char *stdout_text = nil
  char *stderr_text = nil
  if (valid and so.st_size >= 0 and se.st_size >= 0 and (uintmax_t)so.st_size <= c->max_output
    and (uintmax_t)se.st_size <= c->max_output)
    stdout_text = nc_alloc(c, (usize)so.st_size + 1)
    stderr_text = nc_alloc(c, (usize)se.st_size + 1)
    valid = lseek(out, 0, SEEK_SET) >= 0 and lseek(err, 0, SEEK_SET) >= 0
    usize sizes[] = {(usize)so.st_size, (usize)se.st_size}
    int fds[] = {out, err}
    char *texts[] = {stdout_text, stderr_text}
    for usize i = 0; valid and i < 2; ++i
      for usize n = 0; n < sizes[i];
        ssize_t got = read(fds[i], texts[i] + n, sizes[i] - n)
        if got < 0 and errno == EINTR then continue
        if got <= 0 then valid = false; break
        n += (usize)got
  else valid = false
  close(out)
  close(err)
  unlink(out_path)
  unlink(err_path)
  if not valid then nc_fail(c, line, "command capture failed or output limit exceeded")
  if strlen(stdout_text) != (usize)so.st_size or strlen(stderr_text) != (usize)se.st_size
    nc_fail(c, line, "command output must be text (NUL byte found)")
  NcValues result = {0}
  NC_PUSH(c, result, nc_integer(WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status)))
  NC_PUSH(c, result, nc_value_text(NC_STRING, stdout_text))
  NC_PUSH(c, result, nc_value_text(NC_STRING, stderr_text))
  nc_list(result)
#endif
