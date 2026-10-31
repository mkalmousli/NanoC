# NanoC 0.6

Compact C/C++ source + programmable macros, CT, BT and assembly. Self-hosted in NanoC.
Ordinary C/C++ passes through; generated programs have no NanoC runtime.

```c
@m twice($x)
  (($x)*2)
@f add(int a,b) int = a+b
@f main int
  @twice(add(2,3))!=10
```

Bare types, spaces and indentation replace arrows, braces, colons, semicolons,
and final return markers. Empty parameter lists can be omitted on definitions.

Assembly uses indentation too (x86 example):

```c
@f main int
  n:=7
  @asm
    addl $5,%0
    out "+r"(n)
    clobber "cc"
  n!=12
```

Direct instructions, registers, memory operands and jump labels; GCC/Clang backend.
Fetch `nanoc --describe asm` or the [assembly card](docs/assembly.md).

```sh
cc -std=c11 -O2 build.c -o builder
./builder bootstrap                  # C seed -> NanoC -> NanoC; compare output
./builder test                       # GCC + Clang, real C, sanitizers
./build/nanoc examples/hello.nc -o build/hello.c
cc -std=c11 -O2 build/hello.c -o build/hello
./builder install --prefix "$HOME/.local"
./builder uninstall --prefix "$HOME/.local"
```

| Need | Read/fetch |
|---|---|
| Syntax + phases | [Language card](docs/language.md) or `nanoc --describe syntax` |
| One builtin | `nanoc --describe replace` (substitute its name) |
| Full builtin catalog | `nanoc --describe builtins` |
| Agent repair protocol | [Agent card](docs/agents.md) |
| Source layout | [Architecture](docs/architecture.md) |
| Bootstrap / refresh C seed | [Bootstrap card](docs/bootstrap.md); `./builder snapshot` |
| Performance | `./builder bench`; [measurement notes](docs/benchmarks.md) |

Build/test/bench/clean/install/uninstall are C tools; `CC` selects an executable.
All compiler implementation lives in `src/**/*.nc`. `bootstrap/` keeps a generated
C seed, including `main`, so a C compiler alone can build the self-hosted compiler.
Host: POSIX. Targets: C11 / `--lang c++` for C++17. Test prerequisites: GCC/Clang,
C++ frontends, ASan/UBSan runtimes, `sha256sum`. Bench additionally uses GNU time.
Every source file <=100 lines. Tests are offline; [musl provenance](tests/corpus/README.md).

Syntax highlighting: open `.nc` files in VS Code with `editors/vscode`, or source
`editors/vim/nanoc.vim` in Vim. The TextMate grammar includes C and NanoC syntax.
