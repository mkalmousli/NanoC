#include "test.h"
@f test_generated void
  NcContext *c = test_state.mem
  NcBuffer source = {0}, checks = {0}
  uint32_t seed = 918237
  for int i = 0; i < 200; ++i
    seed = seed * 1664525u + 1013904223u
    int a = 1 + (int)(seed % 15), b = (int)(seed >> 8) % 41 - 20
    int x = (int)(seed >> 16) % 101 - 50
    int indent = 1 + (int)(seed % 6)
    if i % 2 == 0
      nc_printf(c, &source, "@fn h%d(x:int):int = x*%d+(%d)\n", i, a, b)
    else
      nc_printf(c, &source, "@fn h%d(x:int):int =\n%*sif x>=0:\n%*sx*%d+(%d)\n%*selse:\n%*sx*%d+(%d)\n",
        i, indent, "", indent * 2, "", a, b, indent, "", indent * 2, "", a, b)
    if i
      nc_add(c, &checks, " or\n    ")
    nc_printf(c, &checks, "h%d(%d) != %d", i, x, x * a + b)
  nc_printf(c, &source, "@fn main():int =\n  (%s)\n", checks.v)
  test_program(source.v, "", false)
  for int i = 1; i <= 40; ++i
    char *bad = nc_format(c, "@fn f():int =\n%*sif true:\n%*s1\n", i, "", i, "")
    test_reject(bad, "indented block", 0, 0, 0)
  puts("[OK] 200 generated functions and 40 malformed-indentation cases")
