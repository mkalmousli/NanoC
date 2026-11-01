<p align="center">
  <img src="docs/logo.svg" width="96" height="96" alt="NanoC logo">
</p>

<h1 align="center">NanoC</h1>

<p align="center">
  <b>Less syntax, full control.</b> A compact, self-hosted language that generates plain C11 or C++17.<br>
  Indented blocks, programmable macros, compile-time and build-time code, inline assembly.
</p>

<p align="center">
  <a href="https://mkalmousli.github.io/NanoC/">Website</a> ·
  <a href="docs/language.md">Language card</a> ·
  <a href="docs/architecture.md">Architecture</a> ·
  <a href="editors/">Editors</a>
</p>

---

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/mkalmousli/NanoC/main/install.sh | sh
```

Needs a POSIX shell and a C11 compiler (`cc`, `gcc` or `clang`). Installs `nanoc` to `~/.local/bin` and sets up the editors it detects.

| Task | Command |
|---|---|
| Install | `curl -fsSL https://raw.githubusercontent.com/mkalmousli/NanoC/main/install.sh \| sh` |
| Update | `nanoc update` |
| Uninstall | `nanoc uninstall` (asks first; `--yes` skips) |
| Install from a checkout | `git clone https://github.com/mkalmousli/NanoC && cd NanoC && sh install.sh` |
| Custom location | add `--prefix DIR` to the installer; `--no-editors` skips editor setup |
| Editor syntax | `nanoc editor install vim` (see [Editors](#editors)) |

Installs only the files it created; it refuses to overwrite unrelated files.

## The language

```c
@m twice($x)
  (($x)*2)

@f add(int a,b) int = a+b

@f main int
  @twice(add(2,3))!=10
```

- **Layout:** indentation defines blocks; bare return types; `:=` inference; no braces, colons or semicolons.
- **Macros:** `@m` token templates with `$` captures, repetition and `$fresh(name)`.
- **Compile time:** `@ct` programs generate code during expansion (`emit`, `quote`, loops).
- **Build time:** `@bt` programs read/write files and run host commands. `--check` validates without side effects.
- **Assembly:** indented `@asm` with explicit outputs, inputs, clobbers and jump labels. Instructions are forwarded to your target's assembler.
- **Interop:** C headers and C++17 APIs work unchanged (`--lang c++`).
- **Agent-friendly:** `nanoc --describe syntax|builtins|asm`, `nanoc file.nc --check --diagnostics json`.

Output is ordinary C with no NanoC runtime. Full reference: [language card](docs/language.md) or `nanoc --describe syntax`.

## Runs wherever C runs

- **Host:** Linux, macOS, BSD, WSL, MSYS2 (POSIX shell and a C11 compiler).
- **Output:** portable C11, or C++17 with `--lang c++`; compile it with whatever toolchain targets your machine.
- **Assembly** is the only target-specific part: it is passed to GCC/Clang inline asm for the architecture you build for.

## Editors

Syntax highlighting, installed by default for detected editors. Manage them with the compiler:

```sh
nanoc editor list              # detected and installed editors
nanoc editor install vim       # or: install --all, or no args for detected editors
nanoc editor remove vim        # or: remove --all
```

| Editor | Command | Installs to |
|---|---|---|
| VS Code, VSCodium, Cursor | `nanoc editor install vscode` | extension folder under `~/.vscode`, `~/.vscode-oss`, `~/.cursor` |
| Vim | `nanoc editor install vim` | `~/.vim/syntax`, `~/.vim/ftdetect` |
| Neovim | `nanoc editor install neovim` | `$XDG_CONFIG_HOME/nvim` |
| Emacs | `nanoc editor install emacs` | `~/.emacs.d/lisp` (prints the `require` line) |
| micro | `nanoc editor install micro` | `$XDG_CONFIG_HOME/micro/syntax` |
| GNU nano | `nanoc editor install nano` | `~/.nano/nanoc.nanorc` (prints the `include` line) |
| Sublime Text 4 | `nanoc editor install sublime` | `Packages/User` |

List them with `nanoc editor list`. Helix, Kate and JetBrains are not covered yet.

## Repository map

| Need | Read/fetch |
|---|---|
| Syntax + phases | [Language card](docs/language.md) or `nanoc --describe syntax` |
| One builtin | `nanoc --describe replace` (substitute its name) |
| Full builtin catalog | `nanoc --describe builtins` |
| Assembly | [Assembly card](docs/assembly.md) or `nanoc --describe asm` |
| Agent repair protocol | [Agent card](docs/agents.md) |
| Source layout | [Architecture](docs/architecture.md) |
| Bootstrap / refresh C seed | [Bootstrap card](docs/bootstrap.md); `./builder snapshot` |
| Performance | `./builder bench`; [measurement notes](docs/benchmarks.md) |

## Build from source

```sh
cc -std=c11 -O2 build.c -o builder
./builder bootstrap                  # C seed -> NanoC -> NanoC; outputs must match byte for byte
./builder test                       # GCC + Clang, real C, sanitizers
CC=clang ./builder test --sanitize   # ASan/UBSan, including a real musl C corpus
./build/nanoc examples/hello.nc -o build/hello.c
```

`CC` selects the C compiler. Test prerequisites: GCC or Clang, C++ frontends, ASan/UBSan runtimes, `sha256sum`.

## Project

- All compiler code lives in `src/**/*.nc`; every source file is at most 100 lines.
- `bootstrap/` keeps a generated C seed, so a C compiler alone builds the self-hosted compiler.
- Tests are offline. Corpus provenance: [tests/corpus](tests/corpus/README.md).
- Website: `docs/` (GitHub Pages). Regenerate its file index with `sh tools/site/files.sh`.
