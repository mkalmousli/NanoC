// Source provenance is emitted by compiler operations and resolved by the final emitter.
@lang 1
+ "test.h"
// Verifies mapping ranges, parent chains, captures, unique identifiers and tracing transparency.
f test_trace() -> void
  const char *source = "@m fresh_value($x) { ($x+$fresh(v)) }\n@ct {emit(\"int seed=1;\");}\nf main() -> int\n  n:=1\n  return n\n"
  NcContext *c = calloc(1, sizeof *c)
  CHECK(c != NULL)
  nc_init(c, "trace.nc")
  c->tracing = true
  if setjmp(c->trap)
    fprintf(stderr, "%s\n", c->error)
    CHECK(false)
  char *out = nc_transpile(c, source)
  CHECK(!strcmp(out, test_translate(source, false)))
  CHECK(c->traces.n >= 5)
  CHECK(!strstr(out, "nc-trace"))
  bool statement = false, compile_time = false
  for size_t i=0; i<c->traces.n; ++i
    NcTrace *e = &c->traces.v[i]
    CHECK(e->id == i+1 && e->parent < e->id)
    if e->start != SIZE_MAX
      CHECK(e->end <= strlen(out) && e->start <= e->end)
    if !strcmp(e->rule, "statement") && e->source.line == 5
      statement = true
      CHECK(e->source.column == 3)
      CHECK(strstr(nc_string(c, out+e->start, e->end-e->start), "return n;"))
      c->query_generated = true
      c->query_offset = e->start
      CHECK(nc_trace_matches(c, e))
      c->query_generated = false
    if !strcmp(e->name, "ct")
      compile_time = true
      CHECK(strstr(e->result, "int seed=1;"))
  CHECK(statement && compile_time)
  CHECK(test_json(nc_trace_text(c, out)))
  nc_dispose(c)
  free(c)
  puts("[OK] direct compiler provenance, generated ranges and reverse lookup")
// Checks that canonical formatting is idempotent and leaves raw C source bytes intact.
f test_formatter() -> void
  NcContext *c = test_state.mem
  const char *source = "f main() -> int\n    x := 1\n    if x\n        return 0\n    return 1\n"
  char *formatted = nc_format_source(c, source)
  CHECK(!strcmp(formatted, nc_format_source(c, formatted)))
  CHECK(strstr(formatted, "\n  x := 1\n  if x\n    return 0\n"))
  CHECK(!strcmp(test_translate(source, false), test_translate(formatted, false)))
  const char *island = "@c {\n#define SPLICE a\\\nb\nint value;\n}\n"
  CHECK(!strcmp(nc_format_source(c, island), island))
  puts("[OK] lexical formatter idempotence and opaque C preservation")
