# Implementation map

Self-hosted NanoC; C11 bootstrap/tools; POSIX host, libc only. Sources <=100 lines.

| Directory | Owns |
|---|---|
| `include/nanoc` | Internal subsystem contracts (not a stable embedding ABI) |
| `bootstrap` | Generated frozen C seed, including main and its own headers |
| `src/frontend` | Tokens, cursors, declarations, native `@f`, recursive expansion |
| `src/macros` | Templates, captures, program macros |
| `src/eval` | Values, scopes, checked arithmetic, expressions, executable programs |
| `src/meta` | Builtin registry, source passes, text/list edits, BT host operations |
| `src/support` | Aligned arenas, maps, buffers, diagnostics, atomic files |
| `src/cli` | Options, compact catalogs, JSON/text reporting |
| `src/layout` | Indented runtime/meta bodies, short controls, implicit returns |
| `tools/build` | Modules included by standalone `build.c` |
| `tests/unit`, `tests/integration` | Compiler behavior, real C, CLI/ABI/BT/install |
| `tests/fixtures`, `tests/corpus` | Legacy cases and licensed upstream C sources |

Tokens are immutable source slices; lookahead copies indices. A context owns
translation allocations and persistent pass state. Error checkpoints release all
owned memory; arena accounting and budgets bound work. No-`@` input passes through.
BT preparation precedes expansion; rewrite/again iterates without recursive passes.
Output files use same-directory temporary files + rename. Host commands use argv;
only explicit `sh` invokes a shell. Builtin signatures live in `src/meta/registry.nc`.
Compiler modules are `.nc`, with indented functions and controls. C11 emitted by
three generations must match; see [bootstrap card](bootstrap.md).
