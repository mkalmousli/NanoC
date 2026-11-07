@lang 1
+ "nanoc/nanoc.h"
// Shared test types and CHECK; prototypes for every *.test.nc function are appended by the build.
+ "nanoc/nanoc.h"

#include <unistd.h>
#include <sys/stat.h>
s TestResult
  status:int
  char *out, *err

s TestState
  mem:*NcContext
  dir:*char
  assertions:size_t

extern TestState test_state;
#define CHECK(x) test_check((x), #x, __FILE__, __LINE__)
