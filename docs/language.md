# NanoC language card

Unmarked source is C/C++. New constructs start with `@`; literals/comments and
preprocessor directives are opaque. C preprocessing/type checking happen later.

| Construct | Form |
|---|---|
| Expression function | `@f add(int a,b)->int => a+b;` |
| C body, short return | `@f main()->int { int n=3; => n-3; }` |
| Template macro | `@m twice($x) { (($x)*2) }` then `@twice(3)` |
| Program macro | `@m id($x) => quote { $x };` |
| CT program | `@ct { n:=6*7; emit(quote { enum { answer=$n }; }); }` |
| BT program | `@bt { write("gen.h", "#define ANSWER 42\n"); }` |

`@f` uses C parameter spelling; following bare names share the previous full type.
Omitted return type = void. `=>` in its body means return. Use ordinary C/C++ for
complex declarators/prototypes. Legacy `@fn`, `@macro`, `@let`, `@for`, indentation
syntax and `@name!(...)` remain accepted; new code need not use them.

## Macros

Captures: `$x`/`$x:tokens`, `$x:ident`, `$x:block`; final `$xs...` is variadic.
Template substitution: `$x`, `$($xs),*`, `$(body)*`, `$fresh(tmp)`, `$$` for `$`.
`$fresh` repeats the same name within one invocation; separate calls are distinct.
Program macros bind bare names (`x`, `xs`); captures are token values, variadics
are lists. They may nest loops/functions, emit code, or return text/tokens.

```c
@m constants($xs...) => {
  for(i:=0;i<len(xs);i++) {
    name:=ident("v"+str(i)); value:=xs[i];
    emit(quote { enum { $name=$value }; });
  }
}
@constants(2,3,5)
```

## Programs: same evaluator in CT, BT and program macros

Values: int64, bool, text, tokens, lists. Statements: `x:=expr;`, `x=expr;`,
`x+=expr;`, `x++;`, `if(cond){...} else {...}`, `while(cond){...}`,
`for(i:=0;i<n;i++){...}`, `break;`, `continue;`, `f square(x)=>x*x;`.
Functions also accept `{ ... => value; }`; recursion and lexical variables work.
Operators: C arithmetic/comparison/boolean operators; `+` also joins matching
text/tokens/lists. Lists: `[a,b]`, `xs[i]`. Strings: `\n \r \t \\ \"`.
`quote { C tokens }` interpolates `$name`: text becomes a C string, tokens insert
verbatim, integers/bools become constants. `ident(text)` builds an identifier.
Use `eval(read("library.meta"))` for reusable program libraries in the root scope.

## Stages / source editing

1. Direct BT blocks run first and are removed. Their emitted code prefixes input.
2. Macros and CT run during expansion; generated constructs expand recursively.
3. `rewrite(text)` schedules another pass only when text differs from `source()`;
   `again()` forces another pass. `get(key,default)` / `put(key,value)` retain state.

BT rewrites apply before expansion; CT/macro rewrites restart from edited source.
BT sees source with direct BT blocks blanked. Generated BT executes on expansion.
Build chained edits in a local value, then call rewrite once. Example:
`@ct { rewrite(rename(source(), "old_name", "new_name")); }` converges automatically.
`rename` changes word tokens, preserving literals/comments/directives; `replace`
edits raw text. `lex`, `slice`, `split`, `join`, `push` support custom transforms.

All phases can read text/files/env. **Only BT** can write/mkdir/remove/run/exec/sh;
these use host privileges. `run(argv[,cwd])` returns `[status,stdout,stderr]`;
`exec` returns stdout or fails; `sh` explicitly uses `/bin/sh -c`. Capture is text.
`--check` / `--no-effects` reject host mutations/commands; reads/transforms still run.

Defaults: 32 passes, 1M steps, 16 MiB input/output, depth 128 (hard ceiling 512).
`--max-passes 0 --max-steps 0` removes count limits, not memory/output/depth limits.
Use `--describe NAME` for exact builtin calls. `log` goes to JSON report logs,
or stderr in text mode; it never contaminates generated C.
