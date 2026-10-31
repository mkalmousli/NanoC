# Agent card

Fetch only what you need:

```sh
nanoc --describe syntax              # small syntax/phase card
nanoc --describe replace             # one builtin, usually <200 bytes
nanoc --describe builtins            # complete signatures + phase availability
nanoc unit.nc --check --diagnostics json
nanoc unit.nc -o unit.c --diagnostics json
cc -std=c11 -Wall -Wextra -Werror -pedantic-errors unit.c -o unit
```

- Checks validate expansion, not C/C++ types/linking/runtime. Then compile and test.
- `--check` never writes generated code and rejects BT host effects. Reads remain.
- Normal builds execute BT effects. `--no-effects` disables them explicitly.
- Success check JSON: schemaVersion, ok, file, validation, language, generatedBytes,
  symbols, passes, logs, diagnostics. Symbols cover generated `@f`/legacy `@fn`.
- Errors: one JSON object on stderr, nonzero exit; compiler output stays intact.
  Prior BT effects are not rolled back.
  Diagnostics contain code, file, line, message, trace; logs are retained.
- Codes: NC_SYNTAX, NC_LIMIT, NC_INPUT. Line 0 = unavailable. Schema v1 is additive.
- Use `@f add(int a,b) int = a+b` or an indented final expression.
  No arrows/braces/block colons/semicolons; `@f main int` omits empty `()`.
- CT/macros generate/edit code; BT adds host files/commands. Functions, loops,
  reusable `eval(read(path))` libraries, persistent state and passes compose.
- `rewrite` converges on unchanged text. `again` forces a pass. For long transforms,
  explicitly raise budgets; 0 removes pass/step counts, other limits remain.
- Preserve raw C/C++ for unsupported declarators; don't invent inference in C.
