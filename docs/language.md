# NanoC language card

Unmarked C/C++ is unchanged. `@` marks extensions; spaces delimit blocks.
Indent consistently (any width); tabs are rejected. Blank lines/comments are ignored.

```c
@f add(int a,b) int = a+b
@f clamp(int x,lo,hi) int
  if x<lo
    lo
  elif x>hi
    hi
  else
    x
@f main int
  total:=0
  for i 0..10
    total+=clamp(i,2,7)
  total!=45
```

- Bare return type (`int`), no arrow. Omitted type = void. Empty `()` optional.
- Inline body: `= expression`. Indented body: final expression returns implicitly;
  a final exhaustive if/elif/else returns each branch's value. No return marker.
- No braces, block colons, condition parentheses, or statement semicolons needed.
  Parentheses/brackets keep multiline expressions together. Optional `;` separates
  same-line expressions. C/C++ initializers and quoted tokens keep native punctuation.
- Locals: `x:=42` infers C scalar literals, C++ uses auto for arbitrary expressions.
  Otherwise spell the C type: `int x=call()`. Group parameters: `int a,b`.
- Ranges: `for i 0..n` (exclusive upper bound, int default), `for i:Type 0..n`.
  Bounds run once in the enclosing scope. `in` and `..<` are accepted too.
  C++: `for x container` binds auto&&. Explicit C loops also work without outer
  parentheses: `for int i=0;i<n;i++`. Use `break` / `continue` normally.
- Conditions: `if`, `elif` / `else if`, `else`, `while`; use C operators.
- Shortcuts: `ret x` (return), `nil` (NULL), `and`/`or`/`not`, `unless c`
  (`if !(c)`), `until c` (`while !(c)`), `loop` (`for (;;)`),
  `@inc stdio, "mine.h", <sys/x.h>` (one `#include` per item; bare names become `<name.h>`).
- Output: `--emit normal` (default, indented readable C) or `--emit mini`
  (comments and layout stripped, smallest valid C for compile speed).
- Existing arrow/brace/indent-colon syntax stays compatible; new code can omit it.
- Assembly: indented `@asm` instructions; `out`/`in`/`clobber`/`labels` sections.
  Optional `volatile`/`inline`/`goto`; [assembly card](assembly.md), `--describe asm`.

## Macros: literal templates or executable programs

```c
@m twice($x)
  (($x)*2)
@m id($x) = x
@m answer = 42
@f result int = @twice(@id(@answer))
```

Captures: `$x` / `$x:tokens`, `$x:ident`, `$x:block`; last `$xs...` is a list.
Templates substitute `$x`, `$($xs),*`, `$fresh(tmp)`, `$$` for a literal `$`.
Template bodies are token text, not evaluator statements. `=` selects a program;
its last expression returns text/tokens/numbers/bools, or it can emit code.
Zero-argument definitions/calls may omit `()`: `@answer`. Other calls use parentheses.
A final `$body:block` argument can be an indented body after the call.

## CT / BT: indented small programs

```c
@ct
  f square(n) = n*n
  for i 1..5
    emit("@f square_"+str(i)+" int = "+str(square(i))+"\n")
```

Values: int64, bool, text, tokens, lists. Bind `x:=expr`; assign `x=expr`;
use `+=`, `++`, C operators, list indexing. Controls use indentation, e.g.
`for i range(n)`, `for i:=0;i<n;i++`, `if cond`, `while cond`.
Program functions use `f name(args) = expr` or an indented final expression.
`quote(C tokens)` interpolates `$name`: text becomes a C string, tokens insert raw.
`ident(text)` constructs names. Load program libraries with `eval(read(path))`.

Direct BT runs first and is removed; its emitted code prefixes input. CT and
macros expand recursively. `source()` reads the current snapshot; `rewrite(text)`
repeats only on changed text; `again()` forces another pass. `get`/`put` retain state.
BT edits apply before expansion; CT/macro edits restart from their edited source.
`rename` edits identifier tokens; `replace` edits raw text. Generated BT runs on use.

All phases may read files/env. Only BT may write/mkdir/remove/run/exec/sh, using
host privileges. `run(argv[,cwd])` returns [status,out,err]; `exec` returns stdout
or fails. `--check` / `--no-effects` reject host mutations and commands.
Defaults: 32 passes, 1M steps, 16 MiB input/output, depth 128 (ceiling 512).
`--max-passes 0 --max-steps 0` removes count limits, not other resource limits.
Fetch builtin signatures with `--describe NAME`. Logs stay out of generated C.
