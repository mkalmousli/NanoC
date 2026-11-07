// Canonical v1 control sigils, function defaults, and preserved C interoperability.
@lang 1
+ "test.h"

// Executes default and explicit return types and rejects superseded runtime spellings.
f test_syntax_v1()
  test_program("+ <stdio.h>\nf greet()\n  puts(\"ok\")\nf count() int\n  < 7\nf main()\n  greet()\n  < count()!=7\n", "ok\n", 0)
  test_program("f noop() void\n  <\nf main() int\n  noop()\n", "", 0)
  test_program("f main()\n  n:=0\n  for i:=0; i<8; ++i\n    if i==1\n      ^\n    if i==4\n      !\n    n+=i\n  < n!=5\n", "", 0)
  test_program("f main()\n  if (1+1) > 1\n    < 0\n  < 1\n", "", 0)
  test_program("int main(void) { return 0; }\n", "", 0)
  test_program("@c { int answer(void) { return 42; } }\nf main()\n  < answer()!=42\n", "", 0)
  test_reject("f main()\n  return 0\n", "uses '< value'", 0, 0, 0)
  test_reject("f main()\n  while 1\n    break\n", "uses '< value'", 0, 0, 0)
  test_reject("f main()\n  while 1\n    continue\n", "uses '< value'", 0, 0, 0)
  test_reject("f main() -> int\n  < 0\n", "omit ->", 0, 0, 0)
  test_reject("f main()\n  if (1)\n    < 0\n", "omit outer parentheses", 0, 0, 0)
  test_reject("f main()\n  while (1)\n    !\n", "omit outer parentheses", 0, 0, 0)
  test_reject("f main()\n  for (;;)\n    !\n", "omit outer parentheses", 0, 0, 0)
  test_reject("f main() = 0\n", "indentation and <", 0, 0, 0)
  puts("[OK] canonical v1 sigils, optional return types, main default and raw C")
