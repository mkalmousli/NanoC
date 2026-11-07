@lang 1
+ "test.h"

f test_terse_meta(void) -> void
  test_program("@ct\n  f answer()\n    f:=42\n    f\n  n:=answer()\n" "  emit(quote(int n=$n;))\nf main() -> int = n!=42\n", "", 0)
  test_program("@ct\n  f fact(n)\n    if n<=1\n      1\n    else\n      n*fact(n-1)\n" "  n:=fact(5)\n  emit(quote(int n=$n;))\nf main() -> int = n!=120\n", "", 0)
  test_program("@ct\n  f sign(n)\n    if n>0\n      1\n    elif n<0\n      -1\n    else\n      0\n" "  assert(sign(-2)==-1 && sign(0)==0 && sign(2)==1)\n" "  total:=0\n  for i 1..5\n    if i==2\n      continue\n    total+=i\n" "  emit(quote(int answer=$total;))\nf main() -> int = answer!=8\n", "", 0)
  test_program("@m declarations($items...) =\n  for i range(len(items))\n" "    name:=ident(\"v\"+str(i))\n    value:=items[i]\n    emit(quote(int $name=$value;))\n" "@declarations(2,3,5)\nf main() -> int = v0+v1+v2!=10\n", "", 0)
  test_program("@ct\n  n:=0\n  for(i:=0;i<5;i++)\n    n+=i\n  while n>8\n    n--\n" "  emit(quote(int n=$n;))\nf main() -> int = n!=8\n", "", 0)
  test_program("@ct\n  n:=0\n  for i:=0;i<4;i++\n    n+=i\n" "  emit(quote(int n=$n;))\nf main() -> int = n!=6\n", "", 0)
  NcContext *c = test_state.mem
  char *input = test_path("terse-meta.nc")
  test_write(input, "f add(\n  int a,\n  int b\n) -> int\n  return a+b\n")
  const char *symbols[] = {"build/nanoc", input, "--check", "--diagnostics", "json", NULL}
  TestResult indexed = test_command(symbols)
  CHECK(test_json(indexed.out) && strstr(indexed.out, "\"name\":\"add\",\"line\":1"))
  test_write(input, "@ct\n  if true\n    x:=1\n\n  fail(\"bad\")\n")
  const char *diagnostic[] = {"build/nanoc", input, "--check", "--diagnostics", "json", NULL}
  TestResult error = test_run(diagnostic)
  CHECK(error.status != 0 && test_json(error.err) && strstr(error.err, "\"line\":5"))
  char *library = test_path("terse-library.meta")
  test_write(library, "f square(n)\n  n*n\n")
  test_program(nc_format(c, "@ct\n  eval(read(%s))\n  n:=square(7)\n  emit(quote(int n=$n;))\n" "f main() -> int = n!=49\n", nc_quote(c, library)), "", 0)
  puts("[OK] indented CT/program macros, short loops, quoting and source libraries")

