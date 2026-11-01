lesson hello START | Hello, NanoC | Hello
  p Save this as `hello.nc`. Lines starting with `#` pass through unchanged, so any C header works.
  code nanoc c
    #include <stdio.h>
    @f main int
      puts("Hello from NanoC!")
      0
  note Build: `nanoc hello.nc -o hello.c && cc hello.c -o hello && ./hello`
lesson functions FUNCTIONS | Bare return types | Functions
  p The return type goes after the parameters, with no arrow. Omit it for `void`. Group parameters that share a type with a comma. A one-line body can be an `=` expression.
  code nanoc c
    #include <stdio.h>
    @f add(int a,b) int = a+b
    @f greet(char *name)
      printf("hi %s\n",name)
    @f main int
      greet("NanoC")
      printf("%d\n",add(2,3))
      0
  list
    An indented body returns its final expression. No `return` needed; `ret x` is the short form when you want one.
    No braces, no semicolons, no parentheses around conditions. Parentheses and brackets keep multiline expressions together.
lesson values VALUES | Blocks produce values | Values
  p An `if`/`elif`/`else` that covers every branch returns the value of whichever branch runs.
  code nanoc c
    @f sign(int x) int
      if x<0
        -1
      elif x>0
        1
      else
        0
    @f main int = sign(-9)!=-1
lesson types SHORT TYPES | Short type names | Types
  p `i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 byte cstr usize isize` are plain C type words inside NanoC code, so the output builds with any C compiler and needs no extra header (`usize`/`isize` need `stddef.h`). Unmarked C is never rewritten.
  code nanoc c
    #include <stdio.h>
    @f add(i32 a,b) i32 = a+b
    @f main int
      u8 x=200
      cstr s="hi"
      printf("%s %d\n",s,add(x,2))
      0
lesson records RECORDS | One-line structs, enums, unions | Records
  p `@s` declares a struct, `@u` a union and `@e` an enum, each with its typedef. Fields are `names:type` (`*T` for pointers), inline separated by `;` or as an indented block.
  code nanoc c
    @s Point x,y:f64
    @s Node
      val:i32
      next:*Node
    @e Color red,green=5,blue
    @f main int
      Point p={1,2}
      Node n={3,NULL}
      Color c=blue
      p.x+p.y!=3 || n.val!=3 || c!=6
lesson say SAY & RAW C | Printing, imports and escape hatch | Say
  p `say a, b` prints values separated by spaces with a newline; formats come from the C11 `_Generic` type of each value. `say` adds `stdio.h` itself. `@use a, b` includes several headers at once, `@use "mine"` is a local `mine.h`, and bundles expand to many: `std` (stdio, stdlib, string), `libc`, `posix`, `cxx`. In C++ the standard headers lose their `.h`: `@use vector`. An indented `@c` block is copied to the C output untouched, for anything NanoC lacks. `--std c89|c99|c11|c17` restricts the output: `i64` becomes `long` in c89 and `say` of values needs c11.
  code nanoc c
    @c
      static int twice(int x) { return x*2; }
    @f main int
      say "twice", twice(21), 1.5
      0
lesson defer DEFER | Cleanup that cannot be forgotten | Defer
  p `defer stmt` runs the statement when its block ends and before every `ret` after it, last deferred first. A returned value is computed before the cleanup runs.
  code nanoc c
    @use stdio
    @f work(int fail) int
      puts("open")
      defer puts("close")
      if fail
        ret 7
      3
    @f main int = work(1)!=7
lesson inline INLINE | One-line blocks | Inline
  p `if c then stmt` puts a single-statement body on the header line. It works for `if`, `elif`, `while`, `for`, `unless` and `until`, and a bare `else stmt` takes a body too, and `if c then a else b` fits on one line. The output is still ordinary braced C.
  code nanoc c
    @f sign(int x) int
      if x < 0 then ret -1
      elif x > 0 then ret 1
      else ret 0
lesson match MATCH | Switch without the noise | Match
  p `match x` takes arms of comma-separated values with an indented body, and `else` for the default. No `break`, no fallthrough. It becomes a plain C `switch`.
  code nanoc c
    @f size(int x) int
      r:=0
      match x
        1, 2
          r=10
        else
          r=-1
      r
    @f main int = size(2)!=10 || size(9)!=-1
lesson locals LOCALS & LOOPS | Inference and ranges | Locals
  p `:=` infers the type of a scalar literal. `for i 1..6` counts from 1 up to but not including 6.
  code nanoc c
    #include <stdio.h>
    @f main int
      total:=0
      for i 1..6
        total+=i
      printf("%d\n",total)
      0
  list
    Spell the type when you need it: `int x=call()`. C++ uses `auto` for `:=`.
    Typed range: `for i:usize 0..n`. Bounds are evaluated once.
    Plain C loops still work: `for int i=0;i<n;i++`. `loop` is `for (;;)`, `unless c` is `if !(c)`, `until c` is `while !(c)`.
    C++ iterates containers: `for value values`.
    Shortcuts: `nil` is NULL, `and`/`or`/`not` are `&&`/`||`/`!`, `@inc stdio, "mine.h", <sys/x.h>` includes headers (bare names become `<name.h>`).
lesson macros MACROS | Token templates | Macros
  p `@m` defines a template. `$x` captures a token. A macro with `=` and no parameters is a named constant.
  code nanoc c
    #include <stdio.h>
    @m twice($x)
      (($x)*2)
    @m answer = 42
    @m maxfn($name,$type)
      @f $name($type a,b) $type = a>b?a:b
    @maxfn(max_int,int)
    @f main int
      printf("%d %d\n",@twice(@answer),max_int(2,3))
      0
  note Use `$fresh(tmp)` for generated names that must not collide. `$$` writes a literal `$`.
  p Captures: `$x` / `$x:tokens`, `$x:ident`, `$x:block`; a last `$xs...` is a list. Templates substitute `$x`, `$($xs),*`, `$fresh(tmp)`. An `=` selects a program: its last expression returns text, tokens, numbers or bools, or it can emit code. A final `$body:block` argument can be an indented body after the call.
lesson ct COMPILE TIME | Generate code with `@ct` | Compile time
  p An indented `@ct` block runs during expansion. `emit` writes NanoC back into the source, so you can generate functions in a loop.
  code nanoc c
    #include <stdio.h>
    @ct
      f square(n) = n*n
      for i 1..5
        emit("@f square_"+str(i)+" int = "+str(square(i))+"\n")
    @f main int
      printf("%d\n",square_4())
      0
  p Programs use int64, bool, text, tokens and lists. Bind `x:=expr`, assign `x=expr`; controls are indented: `for i range(n)`, `if cond`, `while cond`. Functions are `f name(args) = expr` or an indented final expression. `quote(C tokens)` interpolates `$name`, `ident(text)` builds names, `eval(read(path))` loads a program library.
  p CT and macros expand recursively. `source()` reads the current snapshot, `rewrite(text)` repeats only on changed text, `again()` forces another pass, `get`/`put` keep state.
lesson bt BUILD TIME | Files and commands with `@bt` | Build time
  p `@bt` is the only phase that may write files or run host commands. It runs first and is removed; the code it emits prefixes the input. Use `--check` to validate a file without side effects; it rejects these calls.
  code nanoc c
    @bt
      mkdir("build")
      write("build/nanoc-generated.h","#define GENERATED 42\n")
      emit(read("build/nanoc-generated.h"))
    @f main int = GENERATED!=42
  p `run(argv[,cwd])` returns `[status,out,err]`; `exec` returns stdout or fails; `sh` runs a shell line. Defaults: 32 passes, 1M steps, 16 MiB input/output, depth 128 (ceiling 512). `--max-passes 0 --max-steps 0` removes the count limits, not the other resource limits.
lesson asm ASSEMBLY | Inline assembly | Assembly
  p An indented `@asm` block forwards instructions to the GCC or Clang inline assembler, with explicit `out`, `in`, `clobber` and `labels` sections. Assembly is the only place NanoC knows a target; everything else is plain C.
  p Full syntax and examples: `nanoc --describe asm` or the [assembly card](https://github.com/mkalmousli/NanoC/blob/main/docs/assembly.md).
lesson interop INTEROP | C++17 and C headers | Interop
  p Headers work unchanged. Use `--lang c++` to emit C++17 and get range loops over standard containers. `--emit mini` strips comments and layout for the smallest C.
  code nanoc
    #include <vector>
    #include <iostream>
    @f main int
      values:=std::vector<int>(3,2)
      sum:=0
      for value values
        sum+=value
      std::cout<<sum<<'\n'
      0
  note Build: `nanoc app.nc --lang c++ -o app.cc && c++ -std=c++17 app.cc -o app`
lesson cheat REFERENCE | Cheat sheet | Cheat sheet
  table Syntax | Meaning
    `@f name(args) T` | Function; bare return type; `= expr` for one line
    `x:=expr` | Infer a local's type from a scalar literal
    `for i a..b` | Range loop, exclusive upper bound
    `if / elif / else` | Branches; as a final expression they return a value
    `@m name($x) body` | Macro template; `$x` captures, `$fresh(t)`
    `@ct` | Compile-time program; `emit` writes source
    `@bt` | Build-time program; files and commands
    `@asm` | Inline assembly block
  note CLI: `nanoc f.nc -o f.c` · `--check --diagnostics json` · `--lang c++` · `--describe syntax|builtins|asm`
