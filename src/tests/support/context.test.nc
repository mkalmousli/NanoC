@use "test"
TestState test_state;
@f test_check(bool ok, cstr expression, cstr file, int line) void
  ++test_state.assertions
  if !ok
    fprintf(stderr, "%s:%d: FAIL: %s\n", file, line, expression)
    exit(1)
@f test_path(cstr name) char *
  ret nc_format(test_state.mem, "%s/%s", test_state.dir, name)
@f test_read(cstr path) char *
  ret nc_read(test_state.mem, path)
@f test_write(cstr path, cstr s) void
  nc_write(test_state.mem, path, s)
@f test_exists(cstr path) bool
  struct stat st
  ret lstat(path, &st) == 0
@f test_translate(cstr source, bool cpp) char *
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != nil)
  nc_init(c, "test.nc")
  c->cpp = cpp
  if setjmp(c->trap)
    fprintf(stderr, "%s\n", c->error)
    CHECK(false)
  char *generated = nc_transpile(c, source)
  char *out = nc_string(test_state.mem, generated, strlen(generated))
  nc_dispose(c)
  free(c)
  ret out
@f test_reject(cstr source, cstr fragment, size_t depth, size_t steps, size_t output) void
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != nil)
  nc_init(c, "test.nc")
  if depth
    c->max_depth = depth
  if steps
    c->max_steps = steps
  if output
    c->max_output = output
  if setjmp(c->trap)
    if !strstr(c->error, fragment)
      fprintf(stderr, "expected '%s', got:\n%s\n", fragment, c->error)
    CHECK(strstr(c->error, fragment) != nil)
  else
    (void)nc_transpile(c, source)
    fprintf(stderr, "expected: %s\n", fragment)
    CHECK(false)
  nc_dispose(c)
  free(c)
