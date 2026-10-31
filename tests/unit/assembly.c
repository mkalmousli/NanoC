#include "test.h"
void test_assembly(void) {
    const char *card[] = {"build/nanoc", "--describe", "asm", NULL};
    TestResult description = test_command(card);
    CHECK(test_json(description.out) && strstr(description.out, "clobber") && strstr(description.out, "labels"));
    const char *portable = "@f main int\n  n:=42\n  @asm volatile\n"
        "    \"\"\n    out \"+r\"(n)\n    clobber \"memory\"\n  n!=42\n";
    test_program(portable, "", false);
    test_program(portable, "", true);
    test_program("@asm\n  \"\"\n@f main int\n  @asm inline\n    \"\"\n  0\n", "", false);
#if defined(__x86_64__)
    const char *arithmetic = "@f main int\n  x:=7\n  int y\n  @asm\n"
        "    movl %[src],%[dst]\n    addl $5,%[dst]\n"
        "    out [dst] \"=&r\"(y)\n    in [src] \"r\"(x)\n    clobber \"cc\"\n  y!=12\n";
    test_program(arithmetic, "", false);
    test_program(arithmetic, "", true);
    test_program("@f main int\n  @asm\n    nop # @bt @ct\n  0\n", "", false);
    test_program("@f main int\n  x:=0\n  @asm volatile\n    movl $9,%0\n"
        "    out \"=m\"(x)\n    clobber \"memory\"\n  x!=9\n", "", false);
    test_program("int main(void) {\n  @asm goto\n    jmp %l[done]\n    labels done\n"
        "  return 1;\n done: return 0;\n}\n", "", false);
    test_program("@asm\n  .text\n  .globl assembly_sum\n  assembly_sum:\n"
        "  leal (%rdi,%rsi),%eax\n  ret\nint assembly_sum(int,int);\n"
        "@f main int = assembly_sum(20,22)!=42\n", "", false);
    test_program("@m inc($x)\n  @asm\n    addl $$1,%0\n    out \"+r\"($x)\n"
        "    clobber \"cc\"\n@f main int\n  x:=4\n  @inc(x)\n  x!=5\n", "", false);
#endif
    test_reject("@f main int\n  @asm wrong\n    nop\n  0\n", "qualifier", 0, 0, 0);
    test_reject("@asm volatile volatile\n  nop\n", "repeated", 0, 0, 0);
    test_reject("@asm\n  out \"=r\"(x)\n", "needs instructions", 0, 0, 0);
    test_reject("@asm goto\n  nop\n", "needs labels", 0, 0, 0);
    test_reject("@asm\n  nop\n  labels end\n", "require goto", 0, 0, 0);
    test_reject("@asm\n  nop\n  in \"r\"(x)\n  out \"=r\"(y)\n", "once each", 0, 0, 0);
    test_reject("@asm\n  nop\n  clobber\n", "empty assembly section", 0, 0, 0);
    test_reject("@asm\n  nop\n  clobber \"cc\"\n  nop\n", "precede", 0, 0, 0);
    test_reject("@asm\n  nop\n    nop\n", "assembly indentation", 0, 0, 0);
    puts("[OK] indented assembly, constraints, registers, memory, goto, full functions and macro generation");
}
