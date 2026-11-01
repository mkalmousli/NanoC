@use "test"
@f test_program(cstr source, cstr expected, bool cpp) void
  char *file = test_path(cpp ? "program.cpp" : "program.c")
  char *exe = test_path("program")
  test_write(file, test_translate(source, cpp))
  const char *ccs[] = {cpp ? "g++" : "gcc", cpp ? "clang++" : "clang"}
  for size_t i = 0; i < 2; ++i
    const char *args[] = {ccs[i], cpp ? "-std=c++17" : "-std=c11", "-O2", "-Wall", "-Wextra",
      "-Werror", "-pedantic-errors", file, "-o", exe, NULL}
    (void)test_command(args)
    cstr run[] = {exe, nil}
    TestResult result = test_command(run)
    CHECK(!strcmp(result.out, expected))
