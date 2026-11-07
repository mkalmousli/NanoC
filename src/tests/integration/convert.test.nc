// Conservative C conversion is dependency-free and preserves opaque compiler-specific syntax.
@lang 1
+ "test.h"
// Round-trips actual C including preprocessing splices, then compiles and executes both outputs.
f test_convert() -> void
  char *original=test_path("convert.c"), *nano=test_path("convert.nc"), *back=test_path("convert-back.c")
  const char *source="#include <stdio.h>\n#define JOIN(a,b) a ## b\n#define STR(x) #x\n#define VALUE 4\\\n2\nint main(void) { puts(STR(hello)); return VALUE != 42; }\n"
  test_write(original,source)
  const char *convert[]={"build/nanoc","convert",original,"--to","nanoc","--conservative","-o",nano,NULL}
  (void)test_command(convert)
  CHECK(strstr(test_read(nano),"@c \""))
  const char *emit[]={"build/nanoc","emit",nano,"--to","c","-o",back,NULL}
  (void)test_command(emit)
  CHECK(!strcmp(test_read(back),source))
  test_program(test_read(nano),"hello\n",false)
  puts("[OK] dependency-free C conversion, exact opaque round-trip and execution")
