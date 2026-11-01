@use "test", errno, sys/wait, fcntl
@f test_run(cstr const *args) TestResult
  char *out_path = test_path("stdout-XXXXXX"), *err_path = test_path("stderr-XXXXXX")
  int out = mkstemp(out_path), err = mkstemp(err_path)
  CHECK(out >= 0 and err >= 0)
  pid_t pid = fork()
  CHECK(pid >= 0)
  if !pid
    if dup2(out, STDOUT_FILENO) < 0 or dup2(err, STDERR_FILENO) < 0
      _exit(126)
    close(out)
    close(err)
    execvp(args[0], (char *const *)args)
    _exit(127)
  close(out)
  close(err)
  int status
  while waitpid(pid, &status, 0) < 0
    CHECK(errno == EINTR)
  TestResult result = {WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status),
    test_read(out_path), test_read(err_path)}
  CHECK(unlink(out_path) == 0)
  CHECK(unlink(err_path) == 0)
  ret result
@f test_command(cstr const *args) TestResult
  TestResult r = test_run(args)
  if r.status
    fprintf(stderr, "%s exited %d\n%s%s", args[0], r.status, r.out, r.err)
    CHECK(false)
  ret r
