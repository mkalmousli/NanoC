#include "build.h"
void b_die(const char *message) { fprintf(stderr, "%s\n", message); exit(1); }
int b_run(char *const *args) {
    pid_t pid = fork();
    if (pid < 0) b_die("cannot fork build command");
    if (!pid) { execvp(args[0], args); perror(args[0]); _exit(127); }
    int status;
    while (waitpid(pid, &status, 0) < 0) if (errno != EINTR) b_die("cannot wait for build command");
    return WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
}
void b_path(char *out, const char *a, const char *b) {
    if (snprintf(out, PATH_MAX, "%s/%s", a, b) >= PATH_MAX) b_die("path is too long");
}
bool b_exists(const char *path) {
    struct stat st;
    return lstat(path, &st) == 0;
}
void b_mkdir(const char *path) {
    char buf[PATH_MAX];
    if (strlen(path) >= sizeof buf) b_die("directory path too long");
    strcpy(buf, path);
    for (char *s = buf + 1; ; ++s) {
        if (*s != '/' && *s) continue;
        char end = *s;
        *s = 0;
        if (*buf && mkdir(buf, 0755) && errno != EEXIST) b_die("cannot create directory");
        *s = end;
        if (!end) break;
    }
}
