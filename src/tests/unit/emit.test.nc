// Golden C output and lexical output modes.
@lang 1
+ "test.h"
// Verifies explicit returns, formatting, language markers and C89 comments.
f test_emit()
  const char *source = "f pick(int *a, int b) int\n  if b > 0\n    < a[0]\n  else\n    < b\n"
  const char *normal = "int pick(int *a, int b) {\n    if (b > 0) {\n        return a[0];\n    } else {\n        return b;\n    }\n}\n"
  CHECK(!strcmp(test_translate(source, false), normal))
  CHECK(strstr(nc_mini(test_state.mem, normal), "return a[0];"))
  CHECK(strstr(test_translate("f g() int\n  int x[2] = {1, 2}\n  < x[0]\n", false), "{1, 2};"))
  CHECK(strstr(test_translate("// c\n@lang 1\nf g() int\n  < 1\n", false), "int g(void)"))
  test_reject("@lang 99\n", "update nanoc", 0, 0, 0)
  test_reject("@lang x\n", "positive integer", 0, 0, 0)
  test_reject("@f main int = 0\n", "unknown extension", 0, 0, 0)
  test_reject("@fn main():int = 0\n", "unknown extension", 0, 0, 0)
  puts("[OK] explicit v1 function syntax and deterministic output")
