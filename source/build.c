/* Bootstrap only: compile the C seed, then run the separate repository tool interpreter.
   Portable C11: POSIX, macOS, and Windows (MinGW or MSVC with a POSIX shell for the workflow). */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#ifdef _WIN32
#include <direct.h>
#define MKDIR(p) _mkdir(p)
#define SET(k, v) _putenv_s(k, v)
#define STAGE0 "build\\stage0.exe"
#define TOOL0 "build\\nctool.exe"
#define NOFLAGS ""
#else
#define MKDIR(p) mkdir(p, 0755)
#define SET(k, v) setenv(k, v, 1)
#define STAGE0 "build/stage0"
#define TOOL0 "build/nctool"
#define NOFLAGS "-D_POSIX_C_SOURCE=200809L "
#endif
static long mtime(const char *path) {
    struct stat st;
    return stat(path, &st) ? -1 : (long)st.st_mtime;
}
static int seed(const char *cc, int tooling) {
    static char cmd[1 << 16];
    char file[512];
    FILE *list = fopen("bootstrap/sources.txt", "r");
    if (!list) return fputs("bootstrap/sources.txt is missing\n", stderr), 1;
    MKDIR("build");
    long stamp = mtime(tooling ? TOOL0 : STAGE0);
    if (stamp > mtime("bootstrap/sources.txt") && stamp > mtime("build.c") &&
        (!tooling || (stamp > mtime("bootstrap/tools/runner.c") && stamp > mtime("bootstrap/tools/process.c") &&
                      stamp > mtime("bootstrap/tools/host_run.c") && stamp > mtime("bootstrap/tools/host_run_win.c")))) return fclose(list), 0;
    snprintf(cmd, sizeof cmd, "%s -std=c11 " NOFLAGS "-O2 -Ibootstrap/include", cc);
    if (tooling) strcat(cmd, " -DNC_TOOLING");
    while (fgets(file, sizeof file, list)) {
        file[strcspn(file, "\r\n")] = 0;
        if (strlen(cmd) + strlen(file) + 32 > sizeof cmd) return fclose(list), fputs("too many seed files\n", stderr), 1;
        if (tooling && !strcmp(file, "src/cli/main.c")) continue;
        strcat(strcat(cmd, " bootstrap/"), file);
    }
    fclose(list);
    strcat(cmd, tooling ? " bootstrap/tools/host_run.c bootstrap/tools/host_run_win.c bootstrap/tools/process.c bootstrap/tools/runner.c -o build/nctool" : " -o " STAGE0);
    return system(cmd) != 0;
}
int main(int argc, char **argv) {
    char args[4096] = "";
    for (int i = 1; i < argc; ++i) {
        if (strlen(args) + strlen(argv[i]) + 2 > sizeof args) return fputs("arguments too long\n", stderr), 1;
        strcat(strcat(args, argv[i]), "\n");
    }
    const char *cc = getenv("CC") ? getenv("CC") : "cc";
    SET("CC", cc);
    SET("NC_ARGS", args);
    if (seed(cc, 0) || seed(cc, 1)) return 1;
    return system("build/nctool src/build.tool.nc") != 0;
}
