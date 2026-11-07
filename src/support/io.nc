// Whole-file read and write.
@lang 1
+ "nanoc/nanoc.h"

+ <errno.h>

// Reads a whole file.
f nc_read(NcContext *c, const char *path) char *
  struct stat st
  if stat(path, &st)
    nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  if st.st_size < 0 || (uintmax_t)st.st_size > c->max_output
    nc_fail(c, 1, "input limit exceeded")
  FILE *f = fopen(path, "rb")
  if ! f
    nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  NcBuffer b = {0}
  char block[8192]
  size_t n
  while (n = fread(block, 1, sizeof block, f)) != 0
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
  < b.v

// Writes a whole file.
f nc_write(NcContext *c, const char *path, const char *contents)
  char *temporary = nc_format(c, "%s.nanoc-XXXXXX", path)
  int fd = mkstemp(temporary)
  if fd < 0
    nc_fail(c, 0, "cannot create output %s: %s", path, strerror(errno))
  size_t n = strlen(contents), done = 0
  bool bad = 0
  while done < n
    ssize_t written = write(fd, contents + done, n - done)
    if written < 0 && errno == EINTR
      ^
    if written <= 0
      bad = 1
      !
    done += (size_t)written
  if close(fd)
    bad = 1
  if !bad && !rename(temporary, path)
    <
  int saved = errno
  remove(temporary)
  nc_fail(c, 0, "cannot write output %s: %s", path, strerror(saved))
