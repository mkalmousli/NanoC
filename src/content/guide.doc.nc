lesson hello START | NanoC v1 | Hello
  p NanoC is a programmable frontend for C. Runtime constructs become ordinary C with no mandatory runtime, VM, garbage collector or hidden allocation. The C compiler checks C symbols and types. The programmer owns memory, cleanup, undefined behavior and correctness. This is pre-release v1: obsolete syntax has been removed, with no compatibility or migration mode.
  code nanoc c
    + <stdio.h>
    f main() -> int
      puts("Hello from NanoC!")
      return 0
  note Run `nanoc emit hello.nc -o hello.c`, then `cc -std=c11 hello.c -o hello && ./hello`. `nanoc run hello.nc` performs both explicit steps without a shell.
lesson functions FUNCTIONS | Functions and declarations | Functions
  p `f name(parameters) -> CType` requires parentheses and an explicit C return type, including void. Parameters use `name: CType` or exact C declarators. Each C parameter needs its own type. Returns are explicit: `return expression` or `return`. A one-line expression definition uses `f add(a: int, b: int) -> int = a+b`. A semicolon after the header declares a prototype.
  code nanoc c
    f add(a: int, b: int) -> int
      return a+b
    f greet() -> void
      return
    f main() -> int
      n := 2
      result: int = add(n,3)
      greet()
      return result != 5
  p `:=` infers scalar literals only in C mode. Calls, arithmetic, names and array literals require an explicit type. Use `int nums[] = {1,2,3}` for arrays and exact C declarations for complex declarators. Integer literal inference uses int for the guaranteed signed 16-bit range, long for the guaranteed signed 32-bit range, and long long outside it in C99 onward. Floating literals infer double and C character literals infer int. C++17 additionally permits auto inference. No typeof extension is emitted. No short type aliases are provided; use C types or typedefs from headers.
lesson controls CONTROL FLOW | Compact declarations and word controls | Controls
  code nanoc c
    f sum(a: *int, n: int) -> int
      total := 0
      for i := 0; i < n; i++
        if a[i] < 0
          continue
        elif a[i] == 0
          break
        else
          total += a[i]
      while total > 10
        total--
      return total
  table Syntax | C translation
    `f name(args) -> T` | Function definition; empty C parameter lists become void
    `s Name` / `u Name` / `e Name` | Struct / union / enum with a typedef
    `name := literal` | Declaration with literal-derived C type
    `name: CType = expression` | Explicit C declaration
    `return expression` / `return` | Return a value / void
    `if condition` / `elif condition` / `else` | if / else if / else
    `while condition` | while
    `for init; condition; step` | for
    `break` / `continue` | break / continue
    `+ <header.h>` / `+ "local.h"` | C include
  p Indentation uses spaces. A body must be deeper than its header, siblings align, and dedents must match an enclosing level. Canonical formatting uses two spaces. Missing, empty or inconsistently indented bodies are rejected. Runtime branches match an if at the same indentation. Block colons and inline then spellings are not part of v1. C expressions retain C operator spelling, precedence and evaluation rules: !x, !!x, ~x, a^b, a?b:c and x=y are expressions. Word controls avoid collisions with these operators.
lesson records RECORDS | Structs, unions and enums | Records
  code nanoc c
    s Point
      x,y: double
    u Number
      i: int
      d: double
    e Color red,green=5,blue
    f main() -> int
      Point p={1,2}
      Number n
      n.i=3
      return p.x+p.y != n.i || blue != 6
  p Types are C types, without header parsing. Named type positions also accept prefix pointers, for example `next: *Node`. Complex declarators, arrays, function pointers and attributes use exact C declarations or raw C. Grouped named fields are supported; initialized local declarations require one name to avoid duplicated evaluation.
lesson preprocessor PREPROCESSOR | C preprocessing | Preprocessor
  p Preprocessor sigils emit directives for the C preprocessor; NanoC never evaluates their conditions. Indentation closes conditional chains with endif, with no C braces. A lone colon is exclusively a preprocessor else. Runtime else uses the word else.
  code nanoc c
    + <stdio.h>
    ?+ _WIN32
      $ PLATFORM = "Windows"
    :# defined(__linux__)
      $ PLATFORM = "Linux"
    :
      $ PLATFORM = "Other"
    f main() -> int
      puts(PLATFORM)
      return 0
  table Syntax | C directive
    `?+ NAME` | ifdef NAME
    `?- NAME` | ifndef NAME
    `?# expression` | if expression
    `:# expression` | elif expression
    `:` | else in a preprocessor chain
    Dedent after a chain | endif
    `$ NAME = replacement` | define NAME replacement
    `$ NAME(args) = replacement` | Function-like define; keep NAME and ( adjacent
    `$- NAME` | undef NAME
    `+ <header.h>` / `+ "local.h"` | include
    `!! "message"` | error; adjacent exclamation marks and a string literal
    `$! payload` | pragma payload; support depends on the C compiler
  p Conditions can nest at file scope or inside functions, mixing with runtime blocks. Declarations may differ between configurations. Directive ordering, # stringification and ## token pasting are retained. Use raw C for multiline replacement lists, unusual include operands or configurations with different brace structure. Test each configuration you ship. NanoC expands macros and CT in every preprocessor branch, even `?# 0`, before the C preprocessor runs. Use C macros for C-configuration-dependent definitions.
lesson raw RAW C | C interoperability | Raw C
  p C headers, libraries, functions, pointers, arrays, structs, unions, enums, typedefs, function pointers and platform APIs remain available. Includes do not require NanoC to parse the declarations in a header. Link through the C compiler's normal flags, for example `nanoc build main.nc --cflag -lm`. C++17 remains a secondary output target, with no additional NanoC C++ type subsystem.
  code nanoc c
    + <stdlib.h>
    f main() -> int
      ptr: void * = malloc(128)
      if ptr == NULL
        return 1
      free(ptr)
      return 0
  p `@c` consumes a balanced braced island, an indented island, or a quoted C source string. The payload bypasses NanoC expansion and output reformatting. Indented and quoted islands can represent preprocessing alternatives whose physical braces do not balance; braced islands require balanced delimiters. Assembly inside raw C is the C compiler's responsibility. Dedicated NanoC @asm and @bt produce removal diagnostics. Raw C is not portable merely because NanoC can pass it through.
  code nanoc c
    @c {
      static int apply(int (*fn)(int), int x) { return fn(x); }
    }
    f twice(x: int) -> int = x*2
    f main() -> int
      int (*fn)(int)=twice
      return apply(fn,21)!=42
lesson macros MACROS | NanoC templates | Macros
  p `@m` transforms NanoC tokens; it is separate from emitted `$` C preprocessor definitions. Captures use `$name`; typed capture kinds include ident, tokens and block. Variadic captures use `...`; repetition uses `$(...)*` and optional separators. `$fresh(name)` creates deterministic unique identifiers. Macro expansion does not promise to evaluate arguments once: that is the macro author's responsibility.
  code nanoc c
    @m identity($x)
      ($x)
    @m getter($name,$field)
      f $name(p: *Point) -> int = p->$field
    s Point
      x: int
    @getter(get_x,x)
    f main() -> int
      Point p={42}
      return @identity(get_x(&p))!=42
  p An executable macro uses `@m name($x) =` followed by an indented compile-time program. Use quote, emit, token inspection and existing transformations for library abstractions. No defer, ownership or container runtime is built in. Escape a literal dollar through `$$` inside a template, so C macro definitions can be generated.
lesson ct COMPILE TIME | Compile-time generation | Compile time
  p `@ct` executes a bounded source-transformation program. This phase has dynamic values, list/string operations, source/token operations, functions `f name(args)`, loops, explicit or final-value returns, quote and emit. This dynamic evaluator is not the runtime C grammar. `eval(read(path))` loads a source library explicitly. Read/exists/env are inputs; write/mkdir/remove/run/exec/sh are not compiler builtins. No external process or filesystem mutation is introduced through another compiler directive.
  code nanoc c
    @ct
      f square(n) = n*n
      values:=[]
      for i range(4)
        values=push(values,str(square(i)))
      emit("static const int squares[]={"+join(values,",")+"};")
    f main() -> int = squares[3]!=9
  p The pipeline expands until stable. rewrite replaces source; again requests another pass. Defaults bound steps, passes, nesting and output. Zero step/pass limits explicitly disable those counters. Host development scripts under *.tool.nc use a separate uninstalled nctool interpreter; the language compiler cannot invoke that runner through a directive.
lesson output OUTPUT | Emission, tools and portability | Output
  p `nanoc emit file.nc --to c -o file.c` writes deterministic readable C; --emit mini compacts non-raw C. `--line-directives` emits C #line markers where available. C diagnostics can refer to NanoC source, but this is not a guarantee of debugger compatibility. `--check` validates expansion only; compile and execute tests separately.
  p `--std c89|c99|c11|c17` selects output restrictions. C89 lowers for initializers into an enclosing scope; inferred long long and unsupported literal forms are rejected. General C source still must obey the selected standard, including mixed-declaration restrictions. Raw C is never silently rewritten to downlevel it. GCC and Clang integration tests cover representative portable programs; universal C implementation support is not claimed.
  p `expand file.nc --json` exports compiler operation events, parent IDs, pass numbers, source ranges, captures, generated identifiers and CT results. `emit file.nc --map file.map.json` adds actual final C byte ranges. `explain file.nc --line N`, --symbol NAME or --generated-offset BYTE filters records. Source coordinates and offsets count UTF-8 bytes. Synthetic expansion positions refer to generated fragments; follow parent relationships to original source. This is operation provenance, not character-perfect macro reconstruction.
  p `fmt file.nc`, --write and --check perform lexical canonical indentation without executing CT. `tokens file.nc --json` reports lexical tokens; --encoding requires optional pinned tiktoken tooling and reports actual text token counts. `convert file.c --to nanoc --conservative` produces an opaque raw C island without dependencies. --compact optionally uses Clang ASTs and preserves unsupported or configuration-sensitive constructs as raw C. It does not restore original formatting or recover former macro abstractions.
