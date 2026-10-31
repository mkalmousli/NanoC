#include "test.h"
void test_integrity(void) {
    const char *args[] = {"sha256sum", "-c", "tests/corpus/SHA256SUMS", NULL};
    (void)test_command(args);
    puts("[OK] pinned upstream corpus SHA-256 integrity");
}
void test_corpus(void) {
    NcContext *c = test_state.mem;
    const char *names[] = {"memcmp", "memchr", "strlen", "strspn", "bsearch"};
    for (size_t i = 0; i < 5; ++i) {
        char *path = nc_format(c, "tests/corpus/%s.c", names[i]);
        char *original = test_read(path);
        CHECK(!strcmp(test_translate(original, false), original));
        char *slow = nc_format(c, "%s\n/* @opaque triggers the full scanner */\n", original);
        CHECK(!strcmp(test_translate(slow, false), slow));
    }
    const char *compilers[] = {"gcc", "clang"};
    for (size_t cc = 0; cc < 2; ++cc) for (size_t opt = 0; opt < 2; ++opt) {
        char *objects[5];
        for (size_t i = 0; i < 5; ++i) {
            char *original = test_read(nc_format(c, "tests/corpus/%s.c", names[i]));
            char *mixed = nc_format(c, "%s\n@fn probe_%s():int = 1\n", original, names[i]);
            char *file = test_path(nc_format(c, "%s.c", names[i]));
            objects[i] = test_path(nc_format(c, "%s.o", names[i]));
            test_write(file, test_translate(mixed, false));
            const char *args[] = {compilers[cc], "-std=c11", opt ? "-O2" : "-O0", "-fno-builtin", "-g",
                "-fsanitize=address,undefined", "-fno-sanitize-recover=all", "-fno-omit-frame-pointer",
                "-fno-pie", "-no-pie", nc_format(c, "-D%s=nc_%s", names[i], names[i]), "-c", file, "-o", objects[i], NULL};
            (void)test_command(args);
        }
        char *exe = test_path("differential");
        const char *link[] = {compilers[cc], "-std=c11", opt ? "-O2" : "-O0", "-fno-builtin", "-g",
            "-fsanitize=address,undefined", "-fno-sanitize-recover=all", "-fno-omit-frame-pointer", "-fno-pie", "-no-pie",
            "tests/integration/corpus_driver.c", objects[0], objects[1], objects[2], objects[3], objects[4], "-o", exe, NULL};
        (void)test_command(link);
        const char *run[] = {exe, NULL};
        (void)test_command(run);
    }
    puts("[OK] real musl C: 400000 libc comparisons, GCC/Clang O0/O2, ASan+UBSan");
}
