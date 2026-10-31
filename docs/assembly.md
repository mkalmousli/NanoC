# Assembly card

`@asm` + indented instructions; no block punctuation or instruction strings needed.
Optional header qualifiers: `volatile`, `inline`, `goto`.

```c
@f add5(int x) int
  int y
  @asm
    movl %[src],%[dst]
    addl $5,%[dst]
    out [dst] "=&r"(y)
    in [src] "r"(x)
    clobber "cc"
  y
```

Example targets x86. NanoC forwards instructions to the target assembler unchanged.
Each raw instruction gets a newline; quoted C strings are accepted verbatim too.
Quote an instruction starting with a reserved section word below.

Optional sections, once each, in this order (omitted sections become empty):

| Word | Payload |
|---|---|
| `out` | C output constraints, e.g. `"+r"(x), "=m"(memory)` |
| `in` | C input constraints, e.g. `"r"(x), "i"(42)` |
| `clobber` | Changed registers, `"cc"`, `"memory"` |
| `labels` | C jump labels; requires `@asm goto` |

Supports named operands, fixed-register constraints, matching operands, early
clobbers and compiler attributes through ordinary C. Macros/CT can generate blocks.
Top-level basic blocks support assembler directives and entire assembly functions.
Native C/C++ assembly syntax also passes through unchanged.

Emits `__asm__`; requires a backend supporting GNU assembly (GCC/Clang tested).
Instruction set, ABI, dialect and constraints belong to the chosen target compiler.
Use backend flags such as `-masm=intel` when compiling emitted C/C++.
Declare actual side effects with operands/clobbers; `volatile` retains side effects,
`"memory"` is a compiler memory barrier, not a hardware fence.
[Backend contract](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html).
