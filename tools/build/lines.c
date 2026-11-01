#include "build.h"
static void check_file(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) b_die("cannot read source for line check");
    size_t count = 0, col = 0;
    int ch, last = '\n';
    size_t n = strlen(path);
    bool narrow = !strncmp(path, "src/", 4) && n > 3 && !strcmp(path + n - 3, ".nc");
    while ((ch = fgetc(f)) != EOF) {
        if (ch == '\n') { ++count; col = 0; }
        else if (narrow && (ch & 0xC0) != 0x80 && ++col > 60) { fprintf(stderr, "%s:%zu: wider than 60 columns\n", path, count + 1); exit(1); }
        last = ch;
    }
    if (last != '\n') ++count;
    fclose(f);
    if (count > 200) { fprintf(stderr, "%s: %zu physical lines (limit 200)\n", path, count); exit(1); }
}
void b_line_check(void) {
    const char *roots[] = {"include", "src", "tools", "tests", "examples"};
    const char *exts[] = {".c", ".h", ".nc", ".cpp", ".hpp"};
    check_file("build.c");
    for (size_t r = 0; r < 5; ++r) for (size_t e = 0; e < 5; ++e) {
        BPaths paths = {0};
        b_walk(&paths, roots[r], exts[e]);
        for (size_t i = 0; i < paths.n; ++i) check_file(paths.v[i]);
        b_paths_free(&paths);
    }
}
