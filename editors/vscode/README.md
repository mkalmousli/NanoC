# NanoC for VS Code

Syntax highlighting, snippets and file icons for [NanoC](https://github.com/mkalmousli/NanoC): a compact, self-hosted language that generates plain C11 or C++17.

- Indentation-based blocks, bare return types, `:=` inference
- Macros (`@m`) with `$` captures, compile-time (`@ct`) and build-time (`@bt`) code, inline assembly (`@asm`)
- Embedded C highlighting inside NanoC files
- Snippets for functions, macros, compile-time and build-time blocks

Install NanoC with `git clone https://github.com/mkalmousli/NanoC && cd NanoC && cc -std=c11 -O2 build.c -o builder && ./builder install`, then run `nanoc editor install vscode`.

[Language card](https://github.com/mkalmousli/NanoC/blob/main/docs/language.md) · [Website](https://mkalmousli.github.io/NanoC/) · [Report an issue](https://github.com/mkalmousli/NanoC/issues)
