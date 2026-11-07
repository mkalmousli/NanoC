lesson hello START | NanoC v1 | Hello
  p NanoC is a programmable frontend for C. Runtime constructs become ordinary C with no mandatory runtime, VM, garbage collector or hidden allocation. The C compiler checks C symbols and types. The programmer owns memory, cleanup, undefined behavior and correctness. This is pre-release v1: obsolete syntax has been removed, with no compatibility or migration mode.
  code nanoc c
    +stdio
    f main
      puts("Hello from NanoC!")
      0
  note Run `nanoc emit hello.nc -o hello.c`, then `cc -std=c11 hello.c -o hello && ./hello`. `nanoc run hello.nc` performs both explicit steps without a shell.
lesson functions FUNCTIONS | Functions and declarations | Functions
  p Zero-argument functions can omit parentheses: `f get int`. With parameters, write `f clamp(int x,lo,hi) int` or name-first parameters such as `x,y:int`. Bare parameter names inherit the preceding C parameter type. The optional return type follows the name or parameter list directly: void by default, int for main. The final value expression in a non-void function returns automatically, including final if/elif/else branches. Use `< value` for an early return and `<` for a void return. End an expression with a semicolon to make it a statement instead. Declarations, assignments, loops and directives do not become implicit results. A semicolon after a function header declares a prototype.
  code nanoc c
    f add(a: int, b: int) int
      < a+b
    f greet()
      <
    f main()
      n := 2
      result: int = add(n,3)
      greet()
      < result != 5
  p `:=` infers scalar literals only in C mode. Calls, arithmetic, names and array literals require an explicit type. Use `int nums[] = {1,2,3}` for arrays and exact C declarations for complex declarators. Integer literal inference uses int for the guaranteed signed 16-bit range, long for the guaranteed signed 32-bit range, and long long outside it in C99 onward. Floating literals infer double and C character literals infer int. C++17 additionally permits auto inference. No typeof extension is emitted. No short type aliases are provided; use C types or typedefs from headers.
lesson controls CONTROL FLOW | Compact declarations and word controls | Controls
  code nanoc c
    f sum(a: *int, n: int) int
      total := 0
      for i := 0; i < n; i++
        if a[i] < 0
          ^
        elif a[i] == 0
          !
        else
          total += a[i]
      while total > 10
        total--
      < total
  table Syntax | C translation
    `f name T` / `f name(args) T` | Function with optional return type
    `int x,y,z` | Shared C parameter type
    final value expression | Implicit return in non-void functions
    `s Name` / `u Name` / `e Name` | Struct / union / enum with a typedef
    `name := literal` | Declaration with literal-derived C type
    `name: CType = expression` | Explicit C declaration
    `< expression` / `<` | Early value return / void return
    `if condition` / `elif condition` / `else` | if / else if / else
    `while condition` | while
    `for init; condition; step` | for
    `!` / `^` | break / continue
    `+stdio,stdlib` / `+<header.h>,"local.h"` | Multiple C includes; bare names add .h
  p Indentation uses spaces. A body must be deeper than its header, siblings align, and dedents must match an enclosing level. Canonical formatting uses two spaces. Missing, empty or inconsistently indented bodies are rejected. Runtime branches match an if at the same indentation. Block colons and inline then spellings are not part of v1. C expressions retain C operator spelling, precedence and evaluation rules: !x, !!x, ~x, a^b, a?b:c and x=y are expressions. Only a standalone `!` or `^` is a loop-control statement; `!x` and `a^b` remain C expressions. Outer parentheses around control headers are rejected.
lesson records RECORDS | Structs, unions and enums | Records
  code nanoc c
    s Point
      x,y: double
    u Number
      i: int
      d: double
    e Color red,green=5,blue
    f main()
      Point p={1,2}
      Number n
      n.i=3
      < p.x+p.y != n.i || blue != 6
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
    f main()
      puts(PLATFORM)
      < 0
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
  p Conditions can nest at file scope or inside functions, mixing with runtime blocks. Declarations may differ between configurations. Directive ordering, # stringification and ## token pasting are retained. Use raw C for multiline replacement lists, unusual include operands or configurations with different brace structure. Test each configuration you ship. NanoC expands macros and TT in every preprocessor branch, even `?# 0`, before the C preprocessor runs. Use C macros for C-configuration-dependent definitions.
lesson raw RAW C | C interoperability | Raw C
  p C headers, libraries, functions, pointers, arrays, structs, unions, enums, typedefs, function pointers and platform APIs remain available. Includes do not require NanoC to parse the declarations in a header. Link through the C compiler's normal flags, for example `nanoc build main.nc --cflag -lm`. C++17 remains a secondary output target, with no additional NanoC C++ type subsystem.
  code nanoc c
    + <stdlib.h>
    f main()
      ptr: void * = malloc(128)
      if ptr == NULL
        < 1
      free(ptr)
      < 0
  p `@c` consumes a balanced braced island, an indented island, or a quoted C source string. The payload bypasses NanoC expansion and output reformatting. Indented and quoted islands can represent preprocessing alternatives whose physical braces do not balance; braced islands require balanced delimiters. Assembly inside raw C is the C compiler's responsibility. Dedicated NanoC @asm and @bt produce removal diagnostics. Raw C is not portable merely because NanoC can pass it through.
  code nanoc c
    @c {
      static int apply(int (*fn)(int), int x) { return fn(x); }
    }
    f twice(x: int) int
      < x*2
    f main()
      int (*fn)(int)=twice
      < apply(fn,21)!=42
lesson macros MACROS | NanoC templates | Macros
  p `@m` transforms NanoC tokens; it is separate from emitted `$` C preprocessor definitions. Captures use `$name`; typed capture kinds include ident, tokens and block. Variadic captures use `...`; repetition uses `$(...)*` and optional separators. `$fresh(name)` creates deterministic unique identifiers. Macro expansion does not promise to evaluate arguments once: that is the macro author's responsibility.
  code nanoc c
    @m identity($x)
      ($x)
    @m getter($name,$field)
      f $name(p: *Point) int
        < p->$field
    s Point
      x: int
    @getter(get_x,x)
    f main()
      Point p={42}
      < @identity(get_x(&p))!=42
  p An executable macro uses `@m name($x) =` followed by an indented translate-time program. Use quote, emit, token inspection and existing transformations for library abstractions. No defer, ownership or container runtime is built in. Escape a literal dollar through `$$` inside a template, so C macro definitions can be generated.
lesson tt TRANSLATE TIME | Translate-time generation | Translate time
  p `@tt` runs translate-time programs before C is emitted. Use dynamic values, functions, lists, strings, quote and emit, or transform source with rewrite and again. Native TT can read and write files, create directories, remove files, and execute host programs: `run(argv[,cwd])` returns [status,stdout,stderr], `exec(argv[,cwd])` returns stdout or fails, and `sh(command)` runs a shell. `eval(read(path))` loads a TT library. The browser supports pure transformations and context information; host commands and filesystem operations require the native compiler.
  code nanoc c
    @tt
      f square(n) = n*n
      values:=[]
      for i range(4)
        values=push(values,str(square(i)))
      emit("static const int squares[]={"+join(values,",")+"};")
    f main()
      < squares[3]!=9
  p The pipeline expands until stable. rewrite replaces source; again requests another cycle. Defaults bound steps, cycles, nesting and output. `--max-steps 0 --max-passes 0` disables count limits. Native TT executes with the compiler process permissions. `--check` evaluates pure TT and rejects host writes or commands, including calls reached through eval or macros.
  table TT function | Information
    `cycle()` | Current one-based expansion cycle
    `line()` | Source line of the TT call
    `file()` | Input file spelling
    `path()` | Resolved input path when available
    `name()` | Enclosing runtime function name, or empty at file scope
    `target()` | Selected C standard or c++17
  code nanoc c
    f answer int
      @tt
        assert(name()=="answer")
        assert(cycle()>=1)
        log(file()+":"+str(line()))
      42
    f main
      answer()!=42
lesson output OUTPUT | Emission, tools and portability | Output
  p `nanoc emit file.nc --to c -o file.c` writes deterministic readable C; --emit mini compacts non-raw C. `--line-directives` emits C #line markers where available. C diagnostics can refer to NanoC source, but this is not a guarantee of debugger compatibility. `--check` validates expansion only; compile and execute tests separately.
  p `--std c89|c99|c11|c17` selects output restrictions. C89 lowers for initializers into an enclosing scope; inferred long long and unsupported literal forms are rejected. General C source still must obey the selected standard, including mixed-declaration restrictions. Raw C is never silently rewritten to downlevel it. GCC and Clang integration tests cover representative portable programs; universal C implementation support is not claimed.
  p `expand file.nc --json` exports compiler operation events, parent IDs, pass numbers, source ranges, captures, generated identifiers and TT results. `emit file.nc --map file.map.json` adds actual final C byte ranges. `explain file.nc --line N`, --symbol NAME or --generated-offset BYTE filters records. Source coordinates and offsets count UTF-8 bytes. Synthetic expansion positions refer to generated fragments; follow parent relationships to original source. This is operation provenance, not character-perfect macro reconstruction.
  p `fmt file.nc`, --write and --check perform lexical canonical indentation without executing TT. `tokens file.nc --json` reports lexical tokens; --encoding requires optional pinned tiktoken tooling and reports actual text token counts. `convert file.c --to nanoc --conservative` produces an opaque raw C island without dependencies. --compact optionally uses Clang ASTs and preserves unsupported or configuration-sensitive constructs as raw C. It does not restore original formatting or recover former macro abstractions.
