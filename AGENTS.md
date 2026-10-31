# NanoC agent entry

- Pure C11 compiler/tools; POSIX host. Every source file <=100 physical lines.
- Preserve unmarked C/C++. New examples use `@f`, `@m`, C operators/braces, `=>`.
- Bootstrap: `cc -std=c11 -O2 build.c -o builder`; run `./builder test`.
- Sanitizers: `CC=clang ./builder test --sanitize` (includes real musl C corpus).
- Cheapest language lookup: `build/nanoc --describe syntax`.
- Fetch one builtin: `build/nanoc --describe replace`; catalog: `--describe builtins`.
- Repair loop: `nanoc input.nc --check --diagnostics json`, then compile emitted C/C++.
- `--check` validates expansion only and disables BT writes/commands.
- CT/macros transform/generate; BT additionally uses host files/processes.
- `--max-passes 0 --max-steps 0` removes count limits; memory/output/depth still apply.
- Keep builtin metadata in `src/meta/registry.c`; docs are short cards, not tutorials.
- Source layout: `docs/architecture.md`. Keep upstream corpus/license/hash files intact.
