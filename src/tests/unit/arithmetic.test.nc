@lang 1
+ "test.h"

f test_arithmetic(void)
  const char * invalid[] = {
      "@ct { 9223372036854775807+1; }", "@ct { -9223372036854775808-1; }",
      "@ct { -9223372036854775808/-1; }", "@ct { -9223372036854775808%-1; }",
      "@ct { 9223372036854775807*2; }", "@ct { -9223372036854775808*-1; }",
      "@ct { -9223372036854775808*2; }", "@ct { 9223372036854775807*(-2); }"
      }
  for size_t i = 0; i < sizeof invalid / sizeof *invalid; ++i
    test_reject(invalid[i], "overflow", 0, 0, 0)
  const char *valid = "@ct { if (-9223372036854775808*0 == 0 && " "9223372036854775807*1 == 9223372036854775807 && " "-9223372036854775808*1 == -9223372036854775808 && -3*-3==9) {emit(\"int good;\");} }"
  CHECK(strstr(test_translate(valid, 0), "int good;") != NULL)
  puts("[OK] checked signed arithmetic at INT64 boundaries")

