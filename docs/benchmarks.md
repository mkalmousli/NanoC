# Measurement

`./builder bench` retains CSV and 10,000-function corpora in `build/bench-data`.
Cases: plain C, native syntax, legacy shorthand/indentation, macros. Reports five
warm in-process rounds, CLI elapsed time, peak RSS (GNU time), 20-launch startup.
Plain C is passthrough, not parsing. Process time includes I/O; filesystem caches
are not flushed. C compilation/optimization is excluded. Report CPU, OS, compiler
and flags when comparing; synthetic results are not universal speed claims.
