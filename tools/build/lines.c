#include "build.h"
static void check_file(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) b_die("cannot read source for line check");
    size_t count = 0;
    int ch, last = '\n';
    while ((ch = fgetc(f)) != EOF) { if (ch == '\n') ++count; last = ch; }
    if (last != '\n') ++count;
    fclose(f);
    if (count > 100) { fprintf(stderr, "%s: %zu physical lines (limit 100)\n", path, count); exit(1); }
}
void b_line_check(void) {
    const char *roots[] = {"include", "src", "tools", "tests", "examples", "bootstrap"};
    const char *exts[] = {".c", ".h", ".nc", ".cpp", ".hpp"};
    check_file("build.c");
    for (size_t r = 0; r < 6; ++r) for (size_t e = 0; e < 5; ++e) {
        BPaths paths = {0};
        b_walk(&paths, roots[r], exts[e]);
        for (size_t i = 0; i < paths.n; ++i) check_file(paths.v[i]);
        b_paths_free(&paths);
    }
}
