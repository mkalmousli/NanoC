table What | C | Zig | Rust | Nim | NanoC
  Compiles to | machine code | machine code | machine code | C, C++ or JS | plain C11 or C++17
  Block syntax | braces | braces | braces | indentation | indentation
  Translate-time code | preprocessor text | `comptime` | `macro_rules!`, proc macros | templates, macros | macros and `@tt` programs, rewritten until stable
  Build-time code | Make, CMake… | `build.zig` | `build.rs` | nimscript | External build tools
  Existing C | native | `@cImport` | FFI / bindgen | `importc` | unmarked C is kept as-is
  Runtime / deps | none | none | std, crates | GC or ARC | none: it is just C
  Inspect the output | n/a | assembly / LLVM IR | MIR / assembly | generated C | generated C, with `#line` back to your source
p Qualitative and simplified: each language does much more than this table shows. NanoC's pitch is narrow: keep C's output and ecosystem, lose the ceremony.
