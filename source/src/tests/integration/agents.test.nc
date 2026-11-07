// Structured discovery and diagnostic streams used by coding agents.
@lang 1
+ "test.h"
// Checks deterministic JSON, explicit functions, source ranges and bounded TT.
f test_agents()
  const char *describe[] = {"build/nanoc", "--describe", NULL}
  char *data = test_command(describe).out
  CHECK(test_json(data) && strstr(data, "\"implementation\":\"NanoC\""))
  char *input = test_path("agent.nc"), *output = test_path("agent.c")
  test_write(input, "f add(a: int, b: int) int\n  < a+b\n")
  test_write(output, "sentinel")
  const char *args[] = {"build/nanoc", input, "--check", "--diagnostics", "json", "-o", output, NULL}
  TestResult r = test_command(args)
  CHECK(test_json(r.out) && !*r.err)
  CHECK(strstr(r.out, "\"ok\":true") && strstr(r.out, "\"name\":\"add\""))
  CHECK(strstr(r.out, "expansion-only"))
  CHECK(!strcmp(test_read(output), "sentinel"))
  CHECK(!strcmp(test_command(args).out, r.out))
  test_write(input, "f bad() int\n  if true:\n    < 1\n")
  r = test_run(args)
  CHECK(r.status != 0 && !*r.out && test_json(r.err))
  CHECK(strstr(r.err, "NC_SYNTAX") && strstr(r.err, "\"line\":2"))
  test_write(input, "@tt { while (true) {} }")
  const char *limits[] = {"build/nanoc", input, "--max-steps", "40", "--diagnostics", "json", NULL}
  r = test_run(limits)
  CHECK(r.status != 0 && test_json(r.err) && strstr(r.err, "NC_LIMIT"))
  const char *bad[] = {"build/nanoc", "--max-steps", "-1", "--diagnostics", "json", NULL}
  r = test_run(bad)
  CHECK(r.status != 0 && test_json(r.err))
  test_write(input, "f main()\n  < 0\n")
  const char *generate[] = {"build/nanoc", input, "--diagnostics", "json", NULL}
  r = test_command(generate)
  CHECK(!*r.err && strstr(r.out, "return 0;"))
  puts("[OK] JSON discovery, signatures, deterministic checks and diagnostics")
