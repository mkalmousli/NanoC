// README.md content.
SITE:="https://mkalmousli.github.io/NanoC/"
editors:=[["VS Code, VSCodium, Cursor","vscode","extension folder under `~/.vscode`, `~/.vscode-oss`, `~/.cursor`"],
  ["Vim","vim","`~/.vim/syntax`, `~/.vim/ftdetect`"],["Neovim","neovim","`$XDG_CONFIG_HOME/nvim`"],
  ["Emacs","emacs","`~/.emacs.d/lisp` (prints the `require` line)"],["micro","micro","`$XDG_CONFIG_HOME/micro/syntax`"],
  ["GNU nano","nano","`~/.nano/nanoc.nanorc` (prints the `include` line)"],["Sublime Text 4","sublime","`Packages/User`"]]
etab:=[]
for e editors
  etab=push(etab,[e[0],c("nanoc editor install "+e[1]),e[2]])
map:=[["Syntax + phases",link("Language card","docs/language.md")+" or "+c("nanoc --describe syntax")],
  ["One builtin",c("nanoc --describe replace")+" (substitute its name)"],
  ["Full builtin catalog",c("nanoc --describe builtins")],
  ["Agent repair protocol",link("Agent card","docs/agents.md")],["Source layout",link("Architecture","docs/architecture.md")],
  ["Bootstrap / refresh C seed",link("Bootstrap card","docs/bootstrap.md")+"; "+c("./builder snapshot")],
  ["Performance",c("./builder bench")+"; "+link("measurement notes","docs/benchmarks.md")]]
tasks:=[["Install",c(INSTALL)],["Update",c("nanoc update")],["Uninstall",c("nanoc uninstall")+" (asks first; `--yes` skips)"],
  ["Custom location",c("./builder install --prefix DIR")],["Editor syntax",c("nanoc editor install vim")+" (see [Editors](#editors))"]]
page("README.md",[
  "<p align=\"center\"><img src=\"src/assets/logo.svg\" width=\"96\" height=\"96\" alt=\"NanoC logo\"></p>\n\n<h1 align=\"center\">NanoC</h1>\n\n<p align=\"center\"><b>Less syntax, full control.</b> A compact, self-hosted language that generates plain C11 or C++17.<br>Indented blocks, programmable macros, compile-time source transformations, compact C preprocessing.</p>\n\n<p align=\"center\"><a href=\""+SITE+"\">Website</a> · <a href=\"docs/language.md\">Language card</a> · <a href=\"docs/architecture.md\">Architecture</a> · <a href=\"src/editors.tool.nc\">Editors</a></p>",
  h(2,"Quick start"),
  code("sh",[INSTALL]),
  "Needs git and a C11 compiler (`cc`, `gcc` or `clang`). Installs `nanoc` to `~/.local/bin` and sets up the editors it detects. Add `--no-editors` to skip editors, or `--prefix DIR` to change the location.",
  tbl(["Task","Command"],tasks),
  "Installs only the files it created; it refuses to overwrite unrelated files.",
  h(2,"The language"),
  code("c",split(read("examples/hello.nc"),"\n")),
  ul([b("Layout:")+" indentation defines blocks; `f name(args)` with an optional result type (void by default, int for main); explicit `<` returns; `if/elif/else`, `while` and `for` controls.",
    b("Macros:")+" `@m` token templates with `$` captures, repetition and `$fresh(name)`.",
    b("Compile time:")+" `@ct` programs generate code during expansion (`emit`, `quote`, loops).",
    b("Interop:")+" C headers and C++17 APIs work unchanged (`--lang c++`).",
    b("Agent-friendly:")+" `nanoc --describe syntax|builtins`, `nanoc file.nc --check --diagnostics json`."]),
  "Output is ordinary C with no NanoC runtime. `@bt` and NanoC assembly were removed; host commands belong in external build tools and compiler extensions in `@c`. Full reference: "+link("language card","docs/language.md")+" or `nanoc --describe syntax`.",
  h(2,"Runs wherever C runs"),
  ul([b("Host:")+" Linux, macOS, BSD and Windows: the compiler is plain portable C11 (cross-compiled with MinGW in CI); building it from source uses a POSIX shell such as sh, MSYS2 or Git Bash.",
    b("Output:")+" C89/C99/C11/C17 syntax modes, or secondary C++17 with `--lang c++`. User C must satisfy the chosen standard."]),
  h(2,"Editors"),
  "Generated from one token table in [src/editors.tool.nc](src/editors.tool.nc) and installed for detected editors.",
  code("sh",["nanoc editor list","nanoc editor install vim       # or --all, or no args for detected editors","nanoc editor remove vim"]),
  tbl(["Editor","Command","Installs to"],etab),
  h(2,"Repository map"),
  tbl(["Need","Read/fetch"],map),
  h(2,"Build from source"),
  code("sh",["cc -std=c11 -O2 build.c -o builder","./builder bootstrap   # C seed -> NanoC -> NanoC, byte-identical","./builder test        # GCC + Clang, real C, sanitizers","CC=clang ./builder test --sanitize","./builder docs        # regenerate README and docs from src/docs"]),
  h(2,"Project"),
  ul(["Compiler, tools, docs and editors are NanoC under `src/`; compiler modules are at most "+LIMIT+" lines.",
    "`build.c` is the only hand-written C; `bootstrap/` keeps a generated C seed.",
    "Tests are offline. Corpus provenance: [tests/corpus](tests/corpus/README.md)."])])
