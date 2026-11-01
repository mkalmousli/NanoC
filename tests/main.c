#include "test.h"
int main(int argc, char **argv) {
    test_state.mem = calloc(1, sizeof *test_state.mem);
    if (!test_state.mem) return 1;
    nc_init(test_state.mem, "tests");
    if (setjmp(test_state.mem->trap)) { fprintf(stderr, "%s\n", test_state.mem->error); return 1; }
    char template[] = "/tmp/nanoc-c-tests-XXXXXX";
    test_state.dir = mkdtemp(template);
    CHECK(test_state.dir != NULL);
    char *asan = nc_format(test_state.mem, "%s:detect_leaks=0", getenv("ASAN_OPTIONS") ? getenv("ASAN_OPTIONS") : "");
    CHECK(setenv("ASAN_OPTIONS", asan, 1) == 0);
    if (argc > 1 && !strcmp(argv[1], "--bench")) test_benchmark();
    else {
        test_preservation();
        test_emit();
        test_arithmetic();
        test_invalid();
        test_programs();
        test_generated();
        test_meta();
        test_build_programs();
        test_terse();
        test_terse_meta();
        test_assembly();
        test_bootstrap();
        test_cli();
        test_agents();
        test_install();
        test_interop();
        test_integrity();
        test_corpus();
        printf("All C test suites passed (%zu assertions).\n", test_state.assertions);
    }
    test_remove(test_state.dir);
    nc_dispose(test_state.mem);
    free(test_state.mem);
    return 0;
}
