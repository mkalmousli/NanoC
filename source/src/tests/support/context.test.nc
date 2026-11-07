@lang 1
+ "test.h"

TestState test_state;
f test_check(bool ok, const char *expression, const char *file, int line)
  ++test_state.assertions
  if !ok
    fprintf(stderr, "%s:%d: FAIL: %s\n", file, line, expression)
    exit(1)

f test_path(const char *name) char *
  <  nc_format(test_state.mem, "%s/%s", test_state.dir, name)

f test_read(const char *path) char *
  <  nc_read(test_state.mem, path)

f test_write(const char *path, const char *s)
  nc_write(test_state.mem, path, s)

f test_exists(const char *path) bool
  struct stat st
  <  lstat(path, &st) == 0

f test_translate(const char *source, bool cpp) char *
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != NULL)
  nc_init(c, "test.nc")
  c->cpp = cpp
  if setjmp(c->trap)
    fprintf(stderr, "%s\nSource:\n%s\n", c->error, source)
    CHECK(0)
  char *generated = nc_transpile(c, source)
  char *out = nc_string(test_state.mem, generated, strlen(generated))
  nc_dispose(c)
  free(c)
  <  out

f test_reject(const char *source, const char *fragment, size_t depth, size_t steps, size_t output)
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != NULL)
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
    CHECK(strstr(c->error, fragment) != NULL)
  else
    (void)nc_transpile(c, source)
    fprintf(stderr, "expected: %s\n", fragment)
    CHECK(0)
  nc_dispose(c)
  free(c)

