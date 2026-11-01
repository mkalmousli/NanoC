# NanoC agent entry

- Headers: generated from `include/nanoc/*.nc` + `--prototypes` by `tools/headers.nc`.
- Self-hosted compiler in `src/**/*.nc`; C11 bootstrap/tools/tests; POSIX host.
  Every source file <=200 physical lines, doc comment per function. Edit NanoC; never hand-edit generated seed C.
- Preserve unmarked C/C++. New code uses `@f name(args) int`, bare types and
  indentation: no arrows, block colons, braces, semicolons or final return markers.
- Bootstrap: `cc -std=c11 -O2 build.c -o builder`; run `./builder test`.
- `./builder bootstrap` forces three generations and byte-compares emitted C.
  Refresh seed: `./builder snapshot`, then `./builder bootstrap`. See `docs/bootstrap.md`.
- Sanitizers: `CC=clang ./builder test --sanitize` (includes real musl C corpus).
- Cheapest language lookup: `build/nanoc --describe syntax`.
- Fetch one builtin: `build/nanoc --describe replace`; catalog: `--describe builtins`.
- Assembly: `--describe asm`; indented instructions + out/in/clobber/labels sections.
- Repair loop: `nanoc input.nc --check --diagnostics json`, then compile emitted C/C++.
- `--check` validates expansion only and disables BT writes/commands.
- CT/macros transform/generate; BT additionally uses host files/processes.
- `--max-passes 0 --max-steps 0` removes count limits; memory/output/depth still apply.
- Keep builtin metadata in `src/meta/registry.nc`; docs are short cards, not tutorials.
- Source layout: `docs/architecture.md`. Keep upstream corpus/license/hash files intact.
