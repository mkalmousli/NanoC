// Shared test types and CHECK; prototypes for every *.test.nc function are appended by the build.
#include "nanoc/nanoc.h"
#include <unistd.h>
#include <sys/stat.h>
typedef struct { int status; char *out, *err; } TestResult;
typedef struct { NcContext *mem; char *dir; size_t assertions; } TestState;
extern TestState test_state;
#define CHECK(x) test_check((x), #x, __FILE__, __LINE__)
