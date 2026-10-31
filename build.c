#define _POSIX_C_SOURCE 200809L
#include "tools/build/build.h"
#include "tools/build/process.c"
#include "tools/build/walk.c"
#include "tools/build/compile.c"
#include "tools/build/copy.c"
#include "tools/build/install.c"
#include "tools/build/lines.c"
int main(int argc, char **argv) {
    BOptions opts = {.cc = getenv("CC") ? getenv("CC") : "cc"};
    const char *action = "build", *prefix = NULL;
    char default_prefix[PATH_MAX];
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--prefix")) {
            if (++i == argc) b_die("missing --prefix value");
            prefix = argv[i];
        } else if (!strcmp(argv[i], "--sanitize")) opts.sanitize = true;
        else if (!strcmp(argv[i], "build") || !strcmp(argv[i], "test") || !strcmp(argv[i], "bench") ||
                 !strcmp(argv[i], "clean") || !strcmp(argv[i], "install") || !strcmp(argv[i], "uninstall")) action = argv[i];
        else b_die("usage: builder [build|test|bench|clean|install|uninstall] [--prefix PATH] [--sanitize]");
    }
    if (!prefix && (!strcmp(action, "install") || !strcmp(action, "uninstall"))) {
        const char *home = getenv("HOME");
        if (!home || !*home) b_die("HOME is unset; use --prefix");
        b_path(default_prefix, home, ".local");
        prefix = default_prefix;
    }
    if (!strcmp(action, "clean")) { b_remove("build"); return 0; }
    if (!strcmp(action, "uninstall")) { b_uninstall(prefix); return 0; }
    b_compile(opts, false);
    if (!strcmp(action, "install")) b_install(prefix);
    else if (!strcmp(action, "test") || !strcmp(action, "bench")) {
        b_line_check();
        b_compile(opts, true);
        char asan[PATH_MAX];
        const char *previous = getenv("ASAN_OPTIONS");
        if (snprintf(asan, sizeof asan, "%s:detect_leaks=0", previous ? previous : "") >= (int)sizeof asan)
            b_die("ASAN_OPTIONS is too long");
        if (setenv("ASAN_OPTIONS", asan, 1)) b_die("cannot configure test sanitizer environment");
        char *args[] = {"build/tests", !strcmp(action, "bench") ? "--bench" : NULL, NULL};
        return b_run(args);
    }
    return 0;
}
