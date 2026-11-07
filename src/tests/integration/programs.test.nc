@lang 1
+ "test.h"

f test_programs(void) -> void
  char *manifest = test_read("tests/fixtures/programs.tsv")
  char *save
  for (char *row = strtok_r(manifest, "\n", &save); row; row = strtok_r(NULL, "\n", &save))
    char *tab = strchr(row, '\t')
    CHECK(tab != NULL)
    *tab++ = 0
    char *expected = nc_string(test_state.mem, row, strlen(row) + 1)
    strcpy(expected + strlen(expected) - 3, ".out")
    test_program(test_read(row), test_read(expected), !strcmp(tab, "c++"))
  puts("[OK] migrated C/C++ runtime fixtures (GCC and Clang)")

f test_invalid(void) -> void
  char *manifest = test_read("tests/fixtures/invalid.tsv")
  char *save
  for (char *row = strtok_r(manifest, "\n", &save); row; row = strtok_r(NULL, "\n", &save))
    char *tab = strchr(row, '\t')
    CHECK(tab != NULL)
    *tab++ = 0
    size_t depth, steps, output
    CHECK(sscanf(tab, "%zu\t%zu\t%zu", &depth, &steps, &output) == 3)
    char *expected = nc_string(test_state.mem, row, strlen(row) + 1)
    strcpy(expected + strlen(expected) - 3, ".err")
    test_reject(test_read(row), test_read(expected), depth, steps, output)
  puts("[OK] migrated malformed syntax, macro and execution-limit fixtures")

