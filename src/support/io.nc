#include "nanoc/core.h"
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
@f nc_read(NcContext *c, const char *path) char *
  struct stat st
  if stat(path, &st)
    nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  if st.st_size < 0 || (uintmax_t)st.st_size > c->max_output
    nc_fail(c, 1, "input limit exceeded")
  FILE *f = fopen(path, "rb")
  if !f
    nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  NcBuffer b = {0}
  char block[8192]
  size_t n
  while (n = fread(block, 1, sizeof block, f))
    if b.n > c->max_output || n > c->max_output - b.n
      fclose(f)
      nc_fail(c, 1, "input limit exceeded")
    nc_addn(c, &b, block, n)
  bool bad = ferror(f)
  fclose(f)
  if bad
    nc_fail(c, 0, "cannot read %s", path)
  nc_add(c, &b, "")
  if strlen(b.v) != b.n
    nc_fail(c, 1, "NUL byte in source input")
  b.v
@f nc_write(NcContext *c, const char *path, const char *contents) void
  char *temporary = nc_format(c, "%s.nanoc-XXXXXX", path)
  int fd = mkstemp(temporary)
  if fd < 0
    nc_fail(c, 0, "cannot create output %s: %s", path, strerror(errno))
  size_t n = strlen(contents), done = 0
  bool bad = false
  while done < n
    ssize_t written = write(fd, contents + done, n - done)
    if written < 0 && errno == EINTR
      continue
    if written <= 0
      bad = true
      break
    done += (size_t)written
  if close(fd)
    bad = true
  if !bad && !rename(temporary, path)
    return
  int saved = errno
  unlink(temporary)
  nc_fail(c, 0, "cannot write output %s: %s", path, strerror(saved))
