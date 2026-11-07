// Short headers, shared parameter types, implicit results and compact header lists.
@lang 1
+ "test.h"

// Executes the short syntax across value functions, conditional tails and declarators.
f test_smarter()
  const char *shorts = "+stdio,stdlib\nf get int;\nf get int\n  42\nf clamp(int x,lo,hi) int\n  if x<lo\n    lo\n  elif x>hi\n    hi\n  else\n    x\nf main\n  total:=0\n  for i:=0; i<10; i++\n    total+=clamp(i,2,7)\n  total!=45 || get()!=42\n"
  test_program(shorts, "", 0)
  test_program(shorts, "", 1)
  test_program("f mix(int x,y,double z,w) int\n  x+y+(int)(z+w)\nf main\n  mix(1,2,3.0,4.0)!=10\n", "", 0)
  test_program("f sum(int *x,y) int\n  *x+*y\nf main\n  a:=2\n  b:=3\n  sum(&a,&b)!=5\n", "", 0)
  test_program("f choose(int x) int\n  x ? 7 : 9\nf main\n  choose(0)!=9\n", "", 0)
  test_program("f stop\n  <\nf main\n  stop()\n", "", 0)
  test_program("f main\n  struct Local { int x; }\n", "", 0)
  CHECK(strstr(test_translate("+stdio stdlib,stdint.h\nf main\n  0\n", 0), "#include <stdint.h>"))
  CHECK(strstr(test_translate("+<stdio.h>,\"local.h\"\n", 0), "#include \"local.h\""))
  test_reject("+stdio,\n", "missing include after comma", 0, 0, 0)
  test_program("f inverse(int x) int\n  !x\nf main\n  inverse(0)!=1\n", "", 0)
  test_reject("@ct {emit(\"int x;\");}", "use @tt", 0, 0, 0)
  test_program("+stddef\nf bytes(int n) size_t\n  sizeof n\nf main\n  bytes(1)!=sizeof(int)\n", "", 0)
  test_program("+<algorithm>\nf low(int a,b) int\n  std::min(a,b)\nf main\n  low(1,2)!=1\n", "", 1)
  puts("[OK] short headers, shared parameter types, implicit results and include lists")
