// Shared test types and CHECK; prototypes for every *.test.nc function are appended by the build.
#include "nanoc/nanoc.h"
#include <unistd.h>
#include <sys/stat.h>
@s TestResult status:i32; char *out, *err
@s TestState mem:*NcContext; dir:*char; assertions:usize
extern TestState test_state;
#define CHECK(x) test_check((x), #x, __FILE__, __LINE__)
