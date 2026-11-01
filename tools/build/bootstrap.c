#include "build.h"
int b_path_order(const void *a, const void *b) {
    return strcmp(*(char *const *)a, *(char *const *)b);
}
void b_generate(const char *compiler, const char *stage) {
    b_remove(stage);
    BPaths sources = {0};
    b_walk(&sources, "src", ".nc");
    if (!sources.n) b_die("missing NanoC compiler sources");
    qsort(sources.v, sources.n, sizeof sources.v[0], b_path_order);
    for (size_t i = 0; i < sources.n; ++i) {
        char output[PATH_MAX], parent[PATH_MAX];
        b_path(output, stage, sources.v[i]);
        strcpy(output + strlen(output) - 2, "c");
        strcpy(parent, output);
        *strrchr(parent, '/') = 0;
        b_mkdir(parent);
        char *args[] = {(char *)compiler, sources.v[i], "-o", output, NULL};
        if (b_run(args)) b_die("self-host translation failed");
    }
    b_paths_free(&sources);
}
bool b_equal(const char *a, const char *b) {
    FILE *left = fopen(a, "rb"), *right = fopen(b, "rb");
    if (!left || !right) b_die("cannot read bootstrap comparison input");
    bool equal = true;
    int x, y;
    do { x = fgetc(left); y = fgetc(right); if (x != y) { equal = false; break; } } while (x != EOF);
    if (ferror(left) || ferror(right)) b_die("cannot compare bootstrap output");
    fclose(left);
    fclose(right);
    return equal;
}
void b_fixed_point(const char *a, const char *b) {
    BPaths sources = {0};
    b_walk(&sources, a, ".c");
    for (size_t i = 0; i < sources.n; ++i) {
        char other[PATH_MAX];
        b_path(other, b, sources.v[i] + strlen(a) + 1);
        if (!b_equal(sources.v[i], other)) {
            fprintf(stderr, "bootstrap mismatch: %s / %s\n", sources.v[i], other);
            b_die("self-hosted output has not reached a fixed point");
        }
    }
    printf("Verified %zu modules: %s == %s\n", sources.n, a, b);
    b_paths_free(&sources);
}
/* Generate include/nanoc/*.h with the given compiler. */
static void b_headers(const char *compiler, const char *out) {
    if (setenv("NC_BIN", compiler, 1) || setenv("NC_OUT", out, 1)) b_die("cannot set header environment");
    char *args[] = {(char *)compiler, "src/headers.bt.nc", "-o", "build/headers.c", NULL};
    if (b_run(args)) b_die("header generation failed");
}
void b_selfhost(BOptions o) {
    BPaths sources = {0};
    b_walk(&sources, "bootstrap/src", ".c");
    b_cc(o, &sources, "build/stage0", "-Ibootstrap/include", false);
    b_paths_free(&sources);
    b_remove("build/include");
    b_headers("build/stage0", "build/include");
    b_generate("build/stage0", "build/stage1");
    b_walk(&sources, "build/stage1/src", ".c");
    b_cc(o, &sources, "build/stage1-nanoc", "-Ibuild/include", false);
    b_paths_free(&sources);
    b_generate("build/stage1-nanoc", "build/stage2");
    if (!getenv("NC_RESEED")) b_fixed_point("build/stage1", "build/stage2");
    b_walk(&sources, "build/stage2/src", ".c");
    b_cc(o, &sources, "build/nanoc", "-Ibuild/include", false);
    b_paths_free(&sources);
    b_generate("build/nanoc", "build/stage3");
    b_fixed_point("build/stage2", "build/stage3");
    puts("Built self-hosted NanoC (C bootstrap -> NanoC -> NanoC)");
}
