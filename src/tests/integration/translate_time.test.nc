// Native translation-time host capabilities and their read-only check boundary.
@lang 1
+ "test.h"

// Verifies actual command outputs, filesystem mutations, metadata and check-mode rejection.
f test_translate_time()
  char *input = test_path("translate.nc"), *marker = test_path("tt-marker")
  char *source = nc_format(test_state.mem,
    "@tt\n  assert(cycle()==1)\n  assert(line()==3)\n  assert(name()==\"\")\n  assert(file()==\"%s\")\n  assert(path()==file())\n  assert(target()==\"c11\")\n  r:=run([\"sh\",\"-c\",\"printf hello; printf error >&2; exit 3\"])\n  assert(r[0]==3 && r[1]==\"hello\" && r[2]==\"error\")\n  assert(exec([\"printf\",\"ok\"])==\"ok\")\n  assert(sh(\"printf shell\")[1]==\"shell\")\n  write(\"%s\",\"created\")\nf result int\n  @tt\n    assert(name()==\"result\")\n  42\nf main\n  result()!=42\n", input, marker)
  test_write(input, source)
  const char *translate[] = {"build/nanoc", input, "-o", test_path("translate.c"), NULL}
  (void)test_command(translate)
  CHECK(!strcmp(test_read(marker), "created"))
  CHECK(unlink(marker)==0)
  const char *check[] = {"build/nanoc", input, "--check", "--diagnostics", "json", NULL}
  TestResult r = test_run(check)
  CHECK(r.status && test_json(r.err) && strstr(r.err, "host effects are unavailable under --check"))
  CHECK(!test_exists(marker))
  test_write(input, nc_format(test_state.mem, "@tt {eval(\"write(\\\"%s\\\",\\\"no\\\");\");}\n", marker))
  CHECK(test_run(check).status!=0)
  CHECK(!test_exists(marker))
  test_program("@tt\n  f answer\n    42\n  value:=answer()\n  emit(quote(enum {VALUE=$value};))\nf main\n  VALUE!=42\n", "", 0)
  test_program("@tt {f answer {< 42;} n:=answer(); emit(quote(enum {N=$n};));}\nf main\n  N!=42\n", "", 0)
  test_program("f value int\n  if 0\n    < 0\n\n  @tt\n\n    assert(line()==7)\n  42\nf main\n  value()!=42\n", "", 0)
  puts("[OK] translation-time context, actual host commands, file writes and read-only checks")
