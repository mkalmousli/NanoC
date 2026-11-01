div.table-wrap
  table.vs
    thead
      tr
        th
        th C
        th Zig
        th Rust
        th Nim
        th.us NanoC
    tbody
      tr
        th Compiles to
        td machine code
        td machine code
        td machine code
        td C, C++ or JS
        td.us plain C11 or C++17
      tr
        th Block syntax
        td braces
        td braces
        td braces
        td indentation
        td.us indentation
      tr
        th Compile-time code
        td preprocessor text
        td <code>comptime</code>
        td <code>macro_rules!</code>, proc macros
        td templates, macros
        td.us macros and <code>@ct</code> programs, rewritten until stable
      tr
        th Build-time code
        td Make, CMake…
        td <code>build.zig</code>
        td <code>build.rs</code>
        td nimscript
        td.us <code>@bt</code> in the same file
      tr
        th Existing C
        td native
        td <code>@cImport</code>
        td FFI / bindgen
        td <code>importc</code>
        td.us unmarked C is kept as-is
      tr
        th Runtime / deps
        td none
        td none
        td std, crates
        td GC or ARC
        td.us none: it is just C
      tr
        th Inspect the output
        td n/a
        td assembly / LLVM IR
        td MIR / assembly
        td generated C
        td.us generated C, with <code>#line</code> back to your source
p.method Qualitative and simplified: each language does much more than this table shows. NanoC's pitch is narrow: keep C's output and ecosystem, lose the ceremony.
