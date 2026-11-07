@lang 1
// Assembly is available only through explicit C integration.
+ "test.h"

// Checks removed syntax and a raw compiler-specific assembly statement.
f test_assembly(void) -> void
  test_reject("@asm\n  nop\n", "asm was removed", 0, 0, 0)
  test_reject("f main() -> int\n  @asm\n    nop\n  return 0\n", "asm was removed", 0, 0, 0)
  test_reject("f main() -> int\n  asm\n    nop\n  return 0\n", "asm was removed", 0, 0, 0)
  test_program("@c { int main(void) { __asm__ volatile(\"\"); return 0; } }\n", "", 0)
  puts("[OK] removed NanoC assembly and raw C escape hatch")

