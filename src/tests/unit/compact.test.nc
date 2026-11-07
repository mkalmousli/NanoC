@lang 1
// Compact grammar, emitted C goldens, portable backends and configuration integration.
+ "test.h"

extern int nc_std;
// Compares reviewed output exactly and verifies deterministic repeated translation.
f golden(const char *name) static char *
  char *source = test_read(nc_format(test_state.mem, "tests/fixtures/compact/%s.nc", name))
  char *expected = test_read(nc_format(test_state.mem, "tests/fixtures/compact/%s.expected", name))
  char *out = test_translate(source, 0)
  if strcmp(out, expected)
    fprintf(stderr, "golden mismatch %s:\n%s\n", name, out)
  CHECK(!strcmp(out, expected))
  CHECK(!strcmp(out, test_translate(source, 0)))
  < source

// Compiles emitted code with each standard and with both independent C compilers.
f portable(const char *source, const char *expected) static void
  int levels[] = {89, 99, 11, 17}
  const char *standards[] = {"-std=c89", "-std=c99", "-std=c11", "-std=c17"}
  const char *compilers[] = {"gcc", "clang"}
  char *file = test_path("compact-portable.c"), *exe = test_path("compact-portable")
  for size_t i = (0), nanoc_bound_1 = (4); i < nanoc_bound_1; ++i
    nc_std = levels[i]
    test_write(file, test_translate(source, 0))
    for size_t j = (0), nanoc_bound_2 = (2); j < nanoc_bound_2; ++j
      const char *args[] = {compilers[j], standards[i], "-Wall", "-Wextra", "-Werror", "-pedantic-errors", file, "-o", exe, NULL}
      (void)test_command(args)
      const char *run[] = {exe, NULL}
      CHECK(!strcmp(test_command(run).out, expected))
  nc_std = 0

// Builds conditional declarations that intentionally have different types in each configuration.
f configurations(const char *source) static void
  char *file = test_path("compact-config.c"), *exe = test_path("compact-config")
  const char *compilers[] = {"gcc", "clang"}
  const char *flags[] = {"-DFIRST", "-DSECOND", "-DNEITHER"}
  const char *expect[] = {"-DEXPECTED=1", "-DEXPECTED=2", "-DEXPECTED=3"}
  const char *outputs[] = {"1 hello 9\n", "2 hello 9\n", "3 hello 9\n"}
  for size_t mini = (0), nanoc_bound_3 = (2); mini < nanoc_bound_3; ++mini
    NcContext *c = calloc(1, sizeof *c)
    CHECK(c != NULL)
    nc_init(c, "config.nc")
    c->mini = mini != 0
    if setjmp(c->trap)
      fprintf(stderr, "%s\n", c->error)
      CHECK(0)
    test_write(file, nc_transpile(c, source))
    nc_dispose(c)
    free(c)
    for size_t i = (0), nanoc_bound_4 = (3); i < nanoc_bound_4; ++i
      for size_t j = (0), nanoc_bound_5 = (2); j < nanoc_bound_5; ++j
        const char *args[] = {compilers[j], "-std=c11", "-Wall", "-Wextra", "-Werror", "-pedantic-errors", flags[i], expect[i], file, "-o", exe, NULL}
        (void)test_command(args)
        const char *run[] = {exe, NULL}
        CHECK(!strcmp(test_command(run).out, outputs[i]))

// Exercises the full compact runtime grammar, metaprogramming, diagnostics and raw C.
f test_compact(void)
  char *core = golden("core"), *pp = golden("preprocessor")
  portable(core, "ok\n")
  portable("f main()\n  n := 0\n  for i := 0; i < 3; i++\n    n += i\n  < n != 3\n", "")
  configurations(pp)
  portable("f truth(x: int) int\n  < x\nf main() int\n  flag := true\n  < !truth(flag)\n", "")
  test_program(core, "ok\n", 1)
  test_program("f abs(x: int) int;\nf main() int\n  < abs(-7) != 7\n", "", 0)
  test_program("f identity(p: *int) *int\n  < p\nf main() int\n  n := 7\n  < *identity(&n) != 7\n", "", 0)
  test_program("+ <stdlib.h>\nf main() int\n  ptr: void* = malloc(128)\n  if ptr == NULL\n    < 1\n  free(ptr)\n  < 0\n", "", 0)
  test_program("f main()\n  x := 0\n  for ; x < 3; x++\n    if x == 2\n      !\n  < x != 2\n", "", 0)
  test_program("@m make($name)\n  f $name(x: int) int\n    < x*2\n@make(twice)\n@ct\n  emit(\"f answer() int\\n  < 42\\n\")\nf main() int\n  < twice(21) != answer()\n", "", 0)
  test_program("@m repeat($body:block)\n  for i := 0; i < 3; i++\n    $body\nf main() int\n  n := 0\n  @repeat\n    if i > 0\n      n += i\n  < n != 3\n", "", 0)
  test_program("@m early($x)\n  if $x\n    < 7\nf pick(x: int) int\n  @early(x)\n  < 0\nf main() int\n  < pick(1) != 7 || pick(0) != 0\n", "", 0)
  test_program("@m define($value)\n  $$ VALUE = $value\n@define(42)\nf main() int\n  < VALUE != 42\n", "", 0)
  test_program("@c { static int apply(int (*fn)(int), int x) { return fn(x); } }\nf twice(x: int) int\n  < x*2\nf main() int\n  int (*fn)(int) = twice\n  < apply(fn,21) != 42\n", "", 0)
  test_program("f main()\n  @c { int and = 7; __asm__ volatile(\"\"); }\n  @c { return and != 7; }\n", "", 0)
  test_program("@c\n  #if 1\n  static int choose(void) {\n  #else\n  static int alternate(void) {\n  #endif\n    return 7;\n  }\nf main() int\n  < choose() != 7\n", "", 0)
  test_program("f main()\n  @c\n    #if 1\n    if (1) {\n    #else\n    if (0) {\n    #endif\n      return 0;\n    }\n  < 1\n", "", 0)
  test_program("@c\n  # if 1\n  # define RAW_VALUE 42\n  # endif\nf main() int\n  < RAW_VALUE != 42\n", "", 0)
  test_program("@c\n  #define RAW \"@bt @asm ?+ $ ! ^\"\nf main() int\n  < RAW[0] != '@'\n", "", 0)
  char *operators = test_translate("f main()\n  x := 1\n  !x\n  !!x\n  ~x\n  x ^= 3\n  x = x ? 0 : 1\n  < x\n", 0)
  CHECK(strstr(operators, "!x;") && strstr(operators, "!!x;") && strstr(operators, "~x;") && strstr(operators, "x ^= 3;"))
  CHECK(strstr(test_translate("f main()\n  for 0; 0; 0\n    !\n  < 0\n", 0), "for (0; 0; 0)"))
  char *bitwise = "f main()\n  x := 1\n  x <<= 3\n  x >>= 1\n  x ^= 7\n  x |= 8\n  x &= 3\n  < x != 3\n"
  test_program(bitwise, "", 0)
  test_program(nc_mini(test_state.mem, test_translate(bitwise, 0)), "", 0)
  test_program("@ct {put(\"seen\",0); }\n?# 0\n  @ct {put(\"seen\",1); }\n@ct {assert(get(\"seen\",0)==1); }\nf main() int\n  < 0\n", "", 0)
  test_program("?# 1\n  f answer() int\n    < 42\n:\n  f answer() int\n    < 0\nf main() int\n  < answer() != 42\n", "", 0)
  test_reject("f main()\n  x := [1,2]\n  < 0\n", "type needed", 0, 0, 0)
  test_reject("f main()\n  x := call()\n  < 0\n", "type needed", 0, 0, 0)
  test_reject("f main()\n  if 1\n    < 0\n   < 1\n", "inconsistent indentation", 0, 0, 0)
  test_reject("f main()\n\treturn 0\n", "spaces", 0, 0, 0)
  test_reject("f main()\n  if 1\n  < 0\n", "indented", 0, 0, 0)
  test_reject("?+ X\n$ X = 1\n", "indented", 0, 0, 0)
  test_reject(":# X\n  int x\n", "without matching", 0, 0, 0)
  test_reject("f main()\n  :# X\n    < 0\n", "without matching", 0, 0, 0)
  test_reject("?+ X\n  int x;\n:\n  int y;\n:# Y\n  int z;\n", "branch after", 0, 0, 0)
  puts("[OK] compact sigils, C goldens, GCC/Clang C89-C17, C++17 and preprocessor configurations")

