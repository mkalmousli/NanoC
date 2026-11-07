@lang 1
+ "test.h"

f test_generated(void) -> void
  NcContext *c = test_state.mem
  NcBuffer source = {0}, checks = {0}
  uint32_t seed = 918237
  for (int i = 0; i < 200; ++i)
    seed = seed * 1664525u + 1013904223u
    int a = 1 + (int)(seed % 15), b = (int)(seed >> 8) % 41 - 20
    int x = (int)(seed >> 16) % 101 - 50
    int indent = 1 + (int)(seed % 6)
    if (i % 2 == 0)
      nc_printf(c, &source, "f h%d(x:int) -> int = x*%d+(%d)\n", i, a, b)
    else
      nc_printf(c, &source, "f h%d(x:int) -> int\n%*sif x>=0\n%*sreturn x*%d+(%d)\n%*selse\n%*sreturn x*%d+(%d)\n",
              i, indent, "", indent * 2, "", a, b, indent, "", indent * 2, "", a, b)
    if (i)
      nc_add(c, &checks, " ||\n    ")
    nc_printf(c, &checks, "h%d(%d) != %d", i, x, x * a + b)
  nc_printf(c, &source, "f main() -> int\n  return (%s)\n", checks.v)
  test_program(source.v, "", 0)
  for (int i = 1; i <= 40; ++i)
    char *bad = nc_format(c, "f f() -> int\n%*sif true\n%*sreturn 1\n", i, "", i, "")
    test_reject(bad, "indented block", 0, 0, 0)
  puts("[OK] 200 generated functions and 40 malformed-indentation cases")

