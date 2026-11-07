@lang 1
+ "test.h"

f test_interop(void)
  char *header = test_path("api.h"), *source = test_path("api.c"), *object = test_path("api.o")
  test_write(header, "#ifdef __cplusplus\nextern \"C\" {\n#endif\n" "struct Pair {int a,b;};\nint total(struct Pair);\n#ifdef __cplusplus\n}\n#endif\n")
  test_write(source, "#include \"api.h\"\nint total(struct Pair p){return p.a+p.b;}\n")
  const char *compile[] = {"cc", "-std=c11", "-c", source, "-o", object, NULL}
  (void)test_command(compile)
  for int cpp = 0; cpp < 2; ++cpp
    char *main = test_path(cpp ? "abi.cpp" : "abi.c"), *exe = test_path("abi")
    test_write(main, test_translate("#include \"api.h\"\nf main() int\n  struct Pair p={2,3}\n  < total(p)!=5\n", cpp != 0))
    const char *link[] = {cpp ? "c++" : "cc", cpp ? "-std=c++17" : "-std=c11",
          "-pedantic-errors", main, object, "-o", exe, NULL}
    (void)test_command(link)
    const char * run[] = {exe, NULL}
    (void)test_command(run)
  puts("[OK] independent C object ABI linked from generated C and C++")

