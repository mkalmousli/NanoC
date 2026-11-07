@lang 1
+ "test.h"

f test_preservation(void) -> void
  const char *sources[] = {"", "int main(void){return 0;}\n", "int fn, let, macro;\n",
      "// @fn ignored\nconst char *s=\"@let x:int;\";\n", "/* @ct { bad } */\nchar c='@';\n",
      "#define F(x) @x \\\n@another\nint x;\n", "// comment \\\n@still_comment\nint x;\n",
      "const char*s = u8\"@fn\";\n", "#define TEXT \"@fn\" \\\n \"@ct\"\n"}
  for (size_t i = 0; i < sizeof sources / sizeof *sources; ++i)
    CHECK(!strcmp(test_translate(sources[i], 0), sources[i]))
  const char *raw = "auto s = u8R\"tag(@ct { \\\" })tag\";\n"
  CHECK(!strcmp(test_translate(raw, 1), raw))
  char *output = test_translate("@m x(){$fresh(v)} @x() @x()", 0)
  CHECK(strstr(output, "nanoc_v_1") && strstr(output, "nanoc_v_2"))
  output = test_translate("@ct { if (-9223372036854775808 < 0) { emit(\"int minimum;\"); } }", 0)
  CHECK(strstr(output, "int minimum;") != NULL)
  puts("[OK] unchanged C/C++ tokens, raw strings, fresh names and minimum integer")

