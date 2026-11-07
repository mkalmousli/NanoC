// Compiler-owned expansion records; offsets and columns count UTF-8 bytes, ranges are half-open.
@lang 1
s NcSpan
  line,column,end_line,end_column: int

s NcTrace
  id,parent,pass: size_t
  source: NcSpan
  start,end: size_t
  rule: const char *
  name: const char *
  input: const char *
  result: const char *
  captures,identifiers: NcStrings
  synthetic: bool

s NcTraces
  v: *NcTrace
  n,cap: size_t
