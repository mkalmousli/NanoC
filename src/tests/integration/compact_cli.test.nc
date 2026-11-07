@lang 1
// End-to-end CLI tracing and removal diagnostics.
+ "test.h"

// Verifies real C compiler diagnostics follow #line back to a compact source line.
f test_compact_cli(void) -> void
  char *input = test_path("compact-map.nc"), *output = test_path("compact-map.c")
  test_write(input, "f main() -> int\n  x := 1\n\n  return missing + x\n")
  const char *emit[] = {"build/nanoc", input, "-o", output, "--line-directives", NULL}
  (void)test_command(emit)
  CHECK(strstr(test_read(output), nc_format(test_state.mem, "#line 4 %s", nc_quote(test_state.mem, input))))
  const char *compile[] = {"cc", "-std=c11", "-c", output, "-o", test_path("compact-map.o"), NULL}
  TestResult r = test_run(compile)
  CHECK(r.status != 0 && strstr(r.err, nc_format(test_state.mem, "%s:4:", input)))
  const char *standard[] = {"build/nanoc", input, "--check", "--std", "c89", "--diagnostics", "json", NULL}
  CHECK(strstr(test_command(standard).out, "\"language\":\"c89\""))
  test_write(input, "@bt {write(\"never\",\"created\");}\n")
  const char *check[] = {"build/nanoc", input, "--check", "--diagnostics", "json", NULL}
  r = test_run(check)
  CHECK(r.status != 0 && test_json(r.err) && strstr(r.err, "@bt was removed"))
  const char *removed[] = {"build/nanoc", input, "--no-effects", NULL}
  CHECK(test_run(removed).status != 0)
  const char *catalog[] = {"build/nanoc", "--describe", "builtins", NULL}
  char *card = test_command(catalog).out
  CHECK(!strstr(card, "\"name\":\"run\"") && !strstr(card, "\"name\":\"write\""))
  const char *assembly[] = {"build/nanoc", "--describe", "asm", NULL}
  CHECK(test_run(assembly).status != 0)
  puts("[OK] compact CLI source tracing and removed execution/assembly capabilities")

