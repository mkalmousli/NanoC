#include "build.h"
void b_walk(BPaths *out, const char *root, const char *suffix) {
    DIR *dir = opendir(root);
    if (!dir) b_die("cannot read project directory");
    struct dirent *entry;
    while ((entry = readdir(dir))) {
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) continue;
        char path[PATH_MAX];
        b_path(path, root, entry->d_name);
        struct stat st;
        if (lstat(path, &st)) b_die("cannot inspect project file");
        if (S_ISDIR(st.st_mode)) b_walk(out, path, suffix);
        else if (S_ISREG(st.st_mode)) {
            size_t n = strlen(path), len = strlen(suffix);
            if (n < len || strcmp(path + n - len, suffix)) continue;
            if (!strcmp(suffix, ".nc") && n > 6 && !strcmp(path + n - 6, ".bt.nc")) continue;
            if (out->n == 512) b_die("too many project files");
            out->v[out->n] = strdup(path);
            if (!out->v[out->n++]) b_die("out of memory");
        }
    }
    closedir(dir);
}
void b_paths_free(BPaths *p) {
    for (size_t i = 0; i < p->n; ++i) free(p->v[i]);
    p->n = 0;
}
void b_remove(const char *path) {
    struct stat st;
    if (lstat(path, &st)) { if (errno == ENOENT) return; b_die("cannot inspect build artifact"); }
    if (!S_ISDIR(st.st_mode)) { if (unlink(path)) b_die("cannot remove build artifact"); return; }
    DIR *dir = opendir(path);
    if (!dir) b_die("cannot read build directory");
    struct dirent *entry;
    while ((entry = readdir(dir))) {
        if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) continue;
        char child[PATH_MAX];
        b_path(child, path, entry->d_name);
        b_remove(child);
    }
    closedir(dir);
    if (rmdir(path)) b_die("cannot remove build directory");
}
