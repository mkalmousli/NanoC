@use "test"
@f test_cli void
  const char *help[] = {"build/nanoc", "--help", NULL}
  (void)test_command(help)
  const char *version[] = {"build/nanoc", "--version", NULL}
  CHECK(!strcmp(test_command(version).out, "nanoc " NC_VERSION "\n"))
  const char *bad[][6] = {{"build/nanoc", NULL}, {"build/nanoc", "--lang", "rust", "x.nc", NULL},
    {"build/nanoc", "--max-steps", "-1", "x.nc", NULL}, {"build/nanoc", "-o", NULL},
    {"build/nanoc", "--bad", NULL}}
  for size_t i = 0; i < 5; ++i
    CHECK(test_run(bad[i]).status != 0)
  char *input = test_path("input $ space.nc"), *output = test_path("output space.c")
  test_write(input, "int x;\n")
  const char *stdout_args[] = {"build/nanoc", input, NULL}
  CHECK(!strcmp(test_command(stdout_args).out, "int x;\n"))
  const char *args[] = {"build/nanoc", input, "-o", output, NULL}
  (void)test_command(args)
  CHECK(!strcmp(test_read(output), "int x;\n"))
  test_write(input, "@fn broken(")
  CHECK(test_run(args).status != 0)
  CHECK(!strcmp(test_read(output), "int x;\n"))
  CHECK(unlink(input) == 0)
  CHECK(test_run(args).status != 0)
  CHECK(!strcmp(test_read(output), "int x;\n"))
  test_write(input, "int y;\n")
  (void)test_command(args)
  CHECK(!strcmp(test_read(output), "int y;\n"))
  const char *missing[] = {"build/nanoc", input, "-o", test_path("missing/out.c"), NULL}
  CHECK(test_run(missing).status != 0)
  test_write(input, "int a; int b; int c;\n")
  const char *limited[] = {"build/nanoc", input, "--max-output", "10", "-o", output, NULL}
  CHECK(test_run(limited).status != 0)
  CHECK(!strcmp(test_read(output), "int y;\n"))
  puts("[OK] CLI arguments, spaces, missing files and atomic output preservation")
