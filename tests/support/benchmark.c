#include "test.h"
#include <time.h>
#include <errno.h>
static double seconds(struct timespec start) {
    struct timespec end;
    CHECK(clock_gettime(CLOCK_MONOTONIC, &end) == 0);
    return (double)(end.tv_sec - start.tv_sec) + (double)(end.tv_nsec - start.tv_nsec) / 1e9;
}
static size_t translation_size(const char *source, const char *file) {
    NcContext *c = calloc(1, sizeof *c);
    CHECK(c != NULL);
    nc_init(c, file);
    if (setjmp(c->trap)) { fprintf(stderr, "%s\n", c->error); exit(1); }
    size_t size = strlen(nc_transpile(c, source));
    nc_dispose(c);
    free(c);
    return size;
}
void test_benchmark(void) {
    CHECK(mkdir("build/bench-data", 0755) == 0 || errno == EEXIST);
    NcBuffer results = {0};
    const char *cases[] = {"plain", "shorthand", "indentation", "macros", "native"};
    const char *header = "case,input bytes,output bytes,warm MiB/s,process ms,process peak RSS KiB\n";
    fputs(header, stdout);
    nc_add(test_state.mem, &results, header);
    for (size_t k = 0; k < 5; ++k) {
        NcBuffer source = {0};
        if (k == 3) nc_add(test_state.mem, &source, "@macro twice($x:tokens){(($x)+($x))}\n");
        for (int i = 0; i < 10000; ++i) {
            const char *formats[] = {"int f%d(int x){return x+%d;}\n", "@fn f%d(x:int)->int{return x+%d;}\n",
                "@fn f%d(x:int):int = x+%d\n", "int f%d(int x){return @twice!(x+%d);}\n",
                "@f f%d(int x) int = x+%d\n"};
            nc_printf(test_state.mem, &source, formats[k], i, i);
        }
        size_t size = 0;
        char *input = nc_format(test_state.mem, "build/bench-data/%s.nc", cases[k]);
        char *output = nc_format(test_state.mem, "build/bench-data/%s.c", cases[k]);
        (void)translation_size(source.v, input);
        struct timespec start;
        CHECK(clock_gettime(CLOCK_MONOTONIC, &start) == 0);
        for (int round = 0; round < 5; ++round) size = translation_size(source.v, input);
        double warm = seconds(start);
        test_write(input, source.v);
        const char *args[] = {"build/nanoc", input, "-o", output, NULL};
        CHECK(clock_gettime(CLOCK_MONOTONIC, &start) == 0);
        (void)test_command(args);
        double process = seconds(start);
        const char *time[] = {"/usr/bin/time", "-f", "%M", "-o", test_path("memory.txt"),
            "build/nanoc", input, "-o", output, NULL};
        (void)test_command(time);
        char *row = nc_format(test_state.mem, "%s,%zu,%zu,%.2f,%.2f,%s", cases[k], source.n, size,
            (double)source.n * 5 / warm / 1048576, process * 1000, test_read(test_path("memory.txt")));
        fputs(row, stdout);
        nc_add(test_state.mem, &results, row);
    }
    struct timespec start;
    CHECK(clock_gettime(CLOCK_MONOTONIC, &start) == 0);
    const char *version[] = {"build/nanoc", "--version", NULL};
    for (int i = 0; i < 20; ++i) (void)test_command(version);
    printf("Average startup (20 launches): %.2f ms\n", seconds(start) * 1000 / 20);
    test_write("build/bench-data/results.csv", results.v);
}
