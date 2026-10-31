# Real C regression corpus

These files are **unmodified musl 1.2.5 sources**, retrieved from its tagged
Git mirror. The upstream project is https://musl.libc.org/ and its repository is
https://git.musl-libc.org/cgit/musl/ . The pinned download URLs, SHA-256 checksums,
and historical SHA-1 checks are in `manifest.json`. The C harness verifies
`SHA256SUMS` with the standard `sha256sum` utility.
The upstream MIT license and attribution are retained in `COPYRIGHT`.
Each vendored C source is below the project's 100-line limit.

Files: `bsearch.c`, `memchr.c`, `memcmp.c`, `strlen.c`, and `strspn.c`.
They exercise real pointer arithmetic, callbacks, type casts, alias attributes,
preprocessor conditions, continued macros, and word-at-a-time bit operations.

`./builder test` (a pure C harness) verifies exact source hashes and byte preservation, including
the full scanner path. It also mixes each source with an indentation-based NanoC
function, transpiles it, and compiles renamed functions with GCC and Clang at
`-O0` and `-O2` under AddressSanitizer and UndefinedBehaviorSanitizer.
The differential driver compares 20,000 deterministic inputs per function with
host libc: 100,000 comparisons per configuration, 400,000 with both compilers.
Zero-length inputs, unaligned offsets, high bytes, missing keys, duplicates,
and empty sets are covered. The randomized buffers are initialized and padded
because upstream musl strlen deliberately loads complete machine words past NUL;
using a one-byte empty-string allocation would trip ASan in the original code too.

These tests validate preservation and integration, not exhaustive C standard
conformance. No network is needed to run the test suite. On this Linux test
platform both compilers need their ASan/UBSan runtime packages. Unsupported or
missing sanitizer runtimes produce test failures rather than silently skipping.
LeakSanitizer is disabled for these allocation-free drivers because ptraced
containers cannot run its thread inspection; ASan and UBSan remain enabled.
