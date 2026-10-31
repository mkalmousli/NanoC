# NanoC 0.5

Compact C/C++ source + programmable macros, CT and BT. Pure C11 implementation.
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

```sh
cc -std=c11 -O2 build.c -o builder
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
| Performance | `./builder bench`; [measurement notes](docs/benchmarks.md) |

Build/test/bench/clean/install/uninstall are C tools; `CC` selects an executable.
Host: POSIX. Targets: C11 / `--lang c++` for C++17. Test prerequisites: GCC/Clang,
C++ frontends, ASan/UBSan runtimes, `sha256sum`. Bench additionally uses GNU time.
Every source file <=100 lines. Tests are offline; [musl provenance](tests/corpus/README.md).
