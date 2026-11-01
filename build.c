/* Bootstrap only: compile the C seed, then let NanoC run the build workflow in src/build.bt.nc. */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SEED "mkdir -p build && { [ -x build/stage0 ] && [ -z \"$(find bootstrap build.c -newer build/stage0)\" ] || " \
             "$CC -std=c11 -D_POSIX_C_SOURCE=200809L -O2 -Ibootstrap/include $(find bootstrap/src -name '*.c') -o build/stage0; }"
int main(int argc, char **argv) {
    char args[4096] = "";
    for (int i = 1; i < argc; ++i) {
        if (strlen(args) + strlen(argv[i]) + 2 > sizeof args) return fputs("arguments too long\n", stderr), 1;
        strcat(strcat(args, argv[i]), "\n");
    }
    if (!getenv("CC")) setenv("CC", "cc", 1);
    setenv("NC_ARGS", args, 1);
    if (system(SEED)) return 1;
    return system("build/stage0 --max-steps 0 --max-passes 0 src/build.bt.nc -o build/build.c") != 0;
}
