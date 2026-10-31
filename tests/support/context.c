#include "test.h"
TestState test_state;
void test_check(bool ok, const char *expression, const char *file, int line) {
    ++test_state.assertions;
    if (!ok) { fprintf(stderr, "%s:%d: FAIL: %s\n", file, line, expression); exit(1); }
}
char *test_path(const char *name) { return nc_format(test_state.mem, "%s/%s", test_state.dir, name); }
char *test_read(const char *path) { return nc_read(test_state.mem, path); }
void test_write(const char *path, const char *s) { nc_write(test_state.mem, path, s); }
bool test_exists(const char *path) { struct stat st; return lstat(path, &st) == 0; }
char *test_translate(const char *source, bool cpp) {
    NcContext *c = calloc(1, sizeof *c);
    CHECK(c != NULL);
    nc_init(c, "test.nc");
    c->cpp = cpp;
    if (setjmp(c->trap)) { fprintf(stderr, "%s\n", c->error); CHECK(false); }
    char *generated = nc_transpile(c, source);
    char *out = nc_string(test_state.mem, generated, strlen(generated));
    nc_dispose(c);
    free(c);
    return out;
}
void test_reject(const char *source, const char *fragment, size_t depth, size_t steps, size_t output) {
    NcContext *c = calloc(1, sizeof *c);
    CHECK(c != NULL);
    nc_init(c, "test.nc");
    if (depth) c->max_depth = depth;
    if (steps) c->max_steps = steps;
    if (output) c->max_output = output;
    if (setjmp(c->trap)) {
        if (!strstr(c->error, fragment)) fprintf(stderr, "expected '%s', got:\n%s\n", fragment, c->error);
        CHECK(strstr(c->error, fragment) != NULL);
    }
    else { (void)nc_transpile(c, source); fprintf(stderr, "expected: %s\n", fragment); CHECK(false); }
    nc_dispose(c);
    free(c);
}
