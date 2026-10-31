#include "build.h"
void b_copy(const char *source, const char *target) {
    char parent[PATH_MAX];
    if (strlen(target) >= sizeof parent) b_die("install path too long");
    strcpy(parent, target);
    char *slash = strrchr(parent, '/');
    if (slash) { *slash = 0; b_mkdir(parent); }
    struct stat st;
    if (stat(source, &st)) b_die("missing installation source");
    FILE *in = fopen(source, "rb"), *out = NULL;
    if (!in) b_die("cannot read installation source");
    if (b_exists(target) && unlink(target)) b_die("cannot replace installed file");
    out = fopen(target, "wb");
    if (!out) b_die("cannot create installed file");
    char buf[8192];
    size_t n;
    while ((n = fread(buf, 1, sizeof buf, in))) if (fwrite(buf, 1, n, out) != n) b_die("installation write failed");
    bool bad = ferror(in);
    if (fclose(in)) bad = true;
    if (fclose(out)) bad = true;
    if (bad || chmod(target, st.st_mode & 0777)) b_die("cannot finish installed file");
}
