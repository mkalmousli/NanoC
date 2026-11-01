// Whole-file read and write.
@use "nanoc/nanoc", sys/stat, unistd, errno
// Reads a whole file.
@f nc_read(NcContext *c, cstr path) char *
  struct stat st
  if stat(path, &st) then nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  if st.st_size < 0 or (uintmax_t)st.st_size > c->max_output then nc_fail(c, 1, "input limit exceeded")
  FILE *f = fopen(path, "rb")
  if not f then nc_fail(c, 0, "cannot read %s: %s", path, strerror(errno))
  NcBuffer b = {0}
  char block[8192]
  usize n
  while (n = fread(block, 1, sizeof block, f)) != 0
    if b.n > c->max_output or n > c->max_output - b.n
      fclose(f)
      nc_fail(c, 1, "input limit exceeded")
    nc_addn(c, &b, block, n)
  bool bad = ferror(f)
  fclose(f)
  if bad then nc_fail(c, 0, "cannot read %s", path)
  nc_add(c, &b, "")
  if strlen(b.v) != b.n then nc_fail(c, 1, "NUL byte in source input")
  b.v
// Writes a whole file.
@f nc_write(NcContext *c, cstr path, cstr contents) void
  char *temporary = nc_format(c, "%s.nanoc-XXXXXX", path)
  int fd = mkstemp(temporary)
  if fd < 0 then nc_fail(c, 0, "cannot create output %s: %s", path, strerror(errno))
  usize n = strlen(contents), done = 0
  bool bad = false
  while done < n
    ssize_t written = write(fd, contents + done, n - done)
    if written < 0 and errno == EINTR then continue
    if written <= 0
      bad = true
      break
    done += (usize)written
  if close(fd) then bad = true
  if !bad and !rename(temporary, path) then return
  int saved = errno
  unlink(temporary)
  nc_fail(c, 0, "cannot write output %s: %s", path, strerror(saved))
