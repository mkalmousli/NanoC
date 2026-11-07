@lang 1
+ "test.h"

f unlimited_passes(void) static void
  char *path = test_path("passes.nc")
  test_write(path, "@ct {n:=get(\"n\",0);put(\"n\",n+1);if(n<64){again();}}\nf main() int\n  < 0;\n")
  const char *args[] = {"build/nanoc", path, "--check", "--diagnostics", "json", "--max-passes", "0", "--max-steps", "0", NULL}
  TestResult r = test_command(args)
  CHECK(test_json(r.out) && strstr(r.out, "\"passes\":65"))
  const char *bounded[] = {"build/nanoc", path, "--check", "--max-passes", "2", NULL}
  CHECK(test_run(bounded).status != 0)

// Removed features must fail even when emitted by a template or CT program.
f test_build_programs(void)
  test_reject("@bt\n  write(\"never\",\"created\")\n", "@bt was removed", 0, 0, 0)
  test_reject("@bt {emit(\"int x;\");}", "@bt was removed", 0, 0, 0)
  test_reject("@m old() { @bt {write(\"never\",\"created\");} }\n@old()", "@bt was removed", 0, 0, 0)
  test_reject("@ct {run([\"true\"]);}", "unknown compile-time function", 0, 0, 0)
  test_reject("@ct {write(\"never\",\"created\");}", "unknown compile-time function", 0, 0, 0)
  unlimited_passes()
  puts("[OK] removed build execution, pure CT and unlimited passes")

