// Diagnostic reports built with the JSON writer.
@lang 1
+ "nanoc/nanoc.h"

extern int nc_std;
// Writes the compiler logs as an array under "logs".
f logs(NcJson *w, NcContext *c) -> static void
  jw_key(w, "logs")
  jw_open(w, '[')
  for (size_t i = (0), nanoc_bound_1 = (c->logs.n); i < nanoc_bound_1; ++i)
    jw_str(w, c->logs.v[i])
  jw_close(w, ']')

// Prints a diagnostic report.
f nc_report(FILE *out, NcContext *c, size_t bytes) -> void
  NcJson w
  jw_start(&w, out)
  jw_open(&w, '{')
  jw_ki(&w, "schemaVersion", 1)
  jw_kb(&w, "ok", 1)
  jw_ks(&w, "file", c->file)
  jw_ks(&w, "validation", "expansion-only")
  jw_ks(&w, "language", c->cpp ? "c++17" : nc_standard_name())
  jw_ki(&w, "generatedBytes", (long)bytes)
  jw_key(&w, "symbols")
  jw_open(&w, '[')
  for (size_t i = (0), nanoc_bound_2 = (c->symbols.n); i < nanoc_bound_2; ++i)
    NcSymbol s = c->symbols.v[i]
    jw_open(&w, '{')
    jw_ks(&w, "name", s.name)
    jw_ki(&w, "line", s.line)
    jw_ks(&w, "parameters", s.params)
    jw_ks(&w, "returnType", s.returns)
    jw_ks(&w, "intent", s.intent)
    jw_close(&w, '}')
  jw_close(&w, ']')
  jw_ki(&w, "passes", (long)c->pass)
  logs(&w, c)
  jw_kr(&w, "diagnostics", "[]")
  jw_close(&w, '}')
  fputc('\n', out)

// Writes one JSON diagnostic.
f nc_diagnostic(FILE *out, NcContext *c) -> void
  NcJson w
  jw_start(&w, out)
  jw_open(&w, '{')
  jw_ki(&w, "schemaVersion", 1)
  jw_kb(&w, "ok", 0)
  jw_key(&w, "diagnostics")
  jw_open(&w, '[')
  jw_open(&w, '{')
  jw_ks(&w, "code", c->code ? c->code : "NC_INPUT")
  jw_ks(&w, "severity", "error")
  jw_ks(&w, "file", c->file)
  jw_ki(&w, "line", c->error_line)
  jw_key(&w, "range")
  nc_span_json(&w, c->error_span)
  jw_ks(&w, "rangePrecision", c->error_span.column ? "token" : "line")
  jw_ks(&w, "sourceKind", c->trace_virtual ? "generated" : "input")
  jw_ks(&w, "message", c->detail)
  jw_key(&w, "trace")
  jw_open(&w, '[')
  for (size_t i = c->frame_count; i; --i)
    jw_str(&w, c->frames[i - 1])
  jw_close(&w, ']')
  jw_close(&w, '}')
  jw_close(&w, ']')
  logs(&w, c)
  jw_close(&w, '}')
  fputc('\n', out)
