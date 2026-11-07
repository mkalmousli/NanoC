# Language compatibility fixtures

`programs.tsv` lists 25 executable NanoC programs migrated from the v0.2 Nim
implementation's existing tests. Each row names a `.nc` source and its C/C++
target. The corresponding `.out` file contains expected stdout (often empty).
The C harness compiles every program with both GCC and Clang in strict standard
mode, executes it, and checks both exit status and output.

`invalid.tsv` lists 28 expected-failure inputs. A row contains the source path,
optional depth/step/output limits (zero selects the default), and an `.err` file
beside the source holds the expected diagnostic fragment. The files cover
indentation, shorthand declarations, macros, recursion, execution budgets, and
compile-time integer errors.

During the C rewrite all 25 executable fixtures were also compared with the saved
v0.2 compiler and produced byte-identical generated C/C++. No reference compiler
or Nim dependency is retained or needed by the test suite.
