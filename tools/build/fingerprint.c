#include "build.h"
static void fingerprint_byte(uint64_t *hash, unsigned char byte) {
    *hash = (*hash ^ byte) * UINT64_C(1099511628211);
}
uint64_t b_fingerprint(void) {
    BPaths files = {0};
    const char *roots[] = {"src", "include", "bootstrap", "tools/build"};
    const char *suffixes[] = {".c", ".h", ".nc"};
    for (size_t r = 0; r < 4; ++r) for (size_t s = 0; s < 3; ++s) b_walk(&files, roots[r], suffixes[s]);
    qsort(files.v, files.n, sizeof files.v[0], b_path_order);
    uint64_t hash = UINT64_C(14695981039346656037);
    for (size_t i = 0; i <= files.n; ++i) {
        const char *path = i == files.n ? "build.c" : files.v[i];
        for (const char *p = path; *p; ++p) fingerprint_byte(&hash, (unsigned char)*p);
        fingerprint_byte(&hash, 0);
        FILE *f = fopen(path, "rb");
        if (!f) b_die("cannot read build input");
        int ch;
        while ((ch = fgetc(f)) != EOF) fingerprint_byte(&hash, (unsigned char)ch);
        if (ferror(f) || fclose(f)) b_die("cannot hash build input");
        fingerprint_byte(&hash, 0);
    }
    b_paths_free(&files);
    return hash;
}
