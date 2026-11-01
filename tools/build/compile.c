#include "build.h"
void b_cc(BOptions o, BPaths *sources, const char *binary, const char *include, bool tests) {
    char *args[1024];
    size_t n = 0;
    args[n++] = (char *)o.cc;
    args[n++] = "-std=c11";
    args[n++] = "-D_POSIX_C_SOURCE=200809L";
    args[n++] = "-Wall";
    args[n++] = "-Wextra";
    args[n++] = "-Wpedantic";
    args[n++] = "-Werror";
    args[n++] = (char *)include;
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
    qsort(sources->v, sources->n, sizeof sources->v[0], b_path_order);
    for (size_t i = 0; i < sources->n; ++i) {
        if (tests && (strstr(sources->v[i], "/cli/main.c") || strstr(sources->v[i], "corpus_driver.c"))) continue;
        if (n + 4 >= sizeof args / sizeof *args) b_die("too many compiler arguments");
        args[n++] = sources->v[i];
    }
    args[n++] = "-o";
    args[n++] = (char *)binary;
    args[n] = NULL;
    if (b_run(args)) b_die("C compilation failed");
}
void b_compile(BOptions o, bool tests) {
    b_mkdir("build");
    if (tests) {
        BPaths sources = {0};
        b_walk(&sources, "build/stage2/src", ".c");
        b_walk(&sources, "tests/support", ".c");
        b_walk(&sources, "tests/unit", ".c");
        b_walk(&sources, "tests/integration", ".c");
        b_walk(&sources, "tests", "/main.c");
        b_cc(o, &sources, "build/tests", "-Ibuild/include", true);
        b_paths_free(&sources);
        return;
    }
    char config[PATH_MAX], previous[PATH_MAX] = {0};
    if (snprintf(config, sizeof config, "%s\nsanitize=%d\nselfhost=%016llx\n", o.cc, o.sanitize,
                 (unsigned long long)b_fingerprint()) >= (int)sizeof config) b_die("CC path too long");
    FILE *f = fopen("build/config", "rb");
    if (f) { size_t got = fread(previous, 1, sizeof previous - 1, f); previous[got] = 0; fclose(f); }
    if (!strcmp(config, previous) && b_exists("build/nanoc") && b_exists("build/stage2/src")) {
        puts("Self-hosted NanoC is up to date");
        return;
    }
    b_selfhost(o);
    f = fopen("build/config", "wb");
    if (!f) b_die("cannot write build configuration");
    if (fputs(config, f) == EOF || fclose(f)) b_die("cannot write build configuration");
}
