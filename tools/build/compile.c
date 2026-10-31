#include "build.h"
static int path_order(const void *a, const void *b) {
    return strcmp(*(char *const *)a, *(char *const *)b);
}
static bool stale(const char *binary, const char *config, BPaths *sources) {
    struct stat target, st;
    if (stat(binary, &target)) return true;
    FILE *f = fopen("build/config", "rb");
    char previous[PATH_MAX] = {0};
    if (f) { size_t n = fread(previous, 1, sizeof previous - 1, f); previous[n] = 0; fclose(f); }
    if (strcmp(previous, config)) return true;
    for (size_t i = 0; i < sources->n; ++i) {
        if (stat(sources->v[i], &st)) return true;
        if (st.st_mtim.tv_sec > target.st_mtim.tv_sec ||
            (st.st_mtim.tv_sec == target.st_mtim.tv_sec && st.st_mtim.tv_nsec > target.st_mtim.tv_nsec)) return true;
    }
    return false;
}
void b_compile(BOptions o, bool tests) {
    b_mkdir("build");
    BPaths sources = {0}, deps = {0};
    b_walk(&sources, "src", ".c");
    b_walk(&deps, "include", ".h");
    b_walk(&deps, "src", ".c");
    b_walk(&deps, "tools/build", ".c");
    b_walk(&deps, "tools/build", ".h");
    if (tests) {
        b_walk(&sources, "tests/support", ".c");
        b_walk(&sources, "tests/unit", ".c");
        b_walk(&sources, "tests/integration", ".c");
        b_walk(&sources, "tests", "/main.c");
    }
    char config[PATH_MAX];
    if (snprintf(config, sizeof config, "%s\nsanitize=%d\n", o.cc, o.sanitize) >= (int)sizeof config) b_die("CC path too long");
    const char *binary = tests ? "build/tests" : "build/nanoc";
    if (!tests && !stale(binary, config, &deps)) { puts("NanoC is up to date"); goto done; }
    qsort(sources.v, sources.n, sizeof sources.v[0], path_order);
    char *args[1024];
    size_t n = 0;
    args[n++] = (char *)o.cc;
    args[n++] = "-std=c11";
    args[n++] = "-D_POSIX_C_SOURCE=200809L";
    args[n++] = "-Wall";
    args[n++] = "-Wextra";
    args[n++] = "-Wpedantic";
    args[n++] = "-Werror";
    args[n++] = "-Iinclude";
    args[n++] = "-Itests/support";
    args[n++] = o.sanitize ? "-O1" : "-O2";
    if (o.sanitize) {
        args[n++] = "-g";
        args[n++] = "-fsanitize=address,undefined";
        args[n++] = "-fno-sanitize-recover=all";
        args[n++] = "-fno-omit-frame-pointer";
        args[n++] = "-fno-pie";
        args[n++] = "-no-pie";
    }
    for (size_t i = 0; i < sources.n; ++i) {
        if (tests && (!strcmp(sources.v[i], "src/cli/main.c") || strstr(sources.v[i], "corpus_driver.c"))) continue;
        args[n++] = sources.v[i];
    }
    args[n++] = "-o";
    args[n++] = (char *)binary;
    args[n] = NULL;
    if (b_run(args)) b_die("C compilation failed");
    if (!tests) {
        FILE *f = fopen("build/config", "wb");
        if (!f) b_die("cannot write build configuration");
        if (fputs(config, f) == EOF || fclose(f)) b_die("cannot write build configuration");
    }
done:
    b_paths_free(&sources);
    b_paths_free(&deps);
}
