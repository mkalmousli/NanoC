// Stable JSON expansion maps; offsets refer directly to emitted C bytes.
@lang 1
+ "nanoc/nanoc.h"

// Writes a source range.
f nc_span_json(NcJson *w, NcSpan span) -> void
  jw_open(w, '{')
  jw_ki(w, "line", span.line)
  jw_ki(w, "column", span.column)
  jw_ki(w, "endLine", span.end_line)
  jw_ki(w, "endColumn", span.end_column)
  jw_close(w, '}')

// Writes an ordered list of text values.
f nc_trace_strings(NcJson *w, NcStrings values) -> void
  jw_open(w, '[')
  for (size_t i = 0; i < values.n; ++i)
    jw_str(w, values.v[i])
  jw_close(w, ']')

// Exports operations, source ancestry, passes, captures, and exact final output offsets.
f nc_trace_json(FILE *out, NcContext *c, const char *generated) -> void
  NcJson w
  jw_start(&w, out)
  jw_open(&w, '{')
  jw_ki(&w, "schemaVersion", 1)
  jw_ks(&w, "file", c->file)
  jw_ks(&w, "offsetUnit", "utf8-byte")
  jw_ks(&w, "generated", generated)
  jw_key(&w, "snapshots")
  nc_trace_strings(&w, c->trace_sources)
  jw_key(&w, "events")
  jw_open(&w, '[')
  for (size_t i = 0; i < c->traces.n; ++i)
    NcTrace *e = &c->traces.v[i]
    if (!nc_trace_matches(c, e))
      continue
    jw_open(&w, '{')
    jw_ki(&w, "id", (long)e->id)
    jw_ki(&w, "parent", (long)e->parent)
    jw_ki(&w, "pass", (long)e->pass)
    jw_ks(&w, "rule", e->rule)
    jw_ks(&w, "name", e->name ? e->name : "")
    jw_kb(&w, "synthetic", e->synthetic)
    jw_key(&w, "source")
    nc_span_json(&w, e->source)
    jw_key(&w, "generated")
    if (e->start == SIZE_MAX || e->end == SIZE_MAX)
      jw_raw(&w, "null")
    else
      jw_open(&w, '{')
      jw_ki(&w, "start", (long)e->start)
      jw_ki(&w, "end", (long)e->end)
      jw_close(&w, '}')
    jw_key(&w, "captures")
    nc_trace_strings(&w, e->captures)
    jw_key(&w, "identifiers")
    nc_trace_strings(&w, e->identifiers)
    jw_ks(&w, "result", e->result ? e->result : "")
    jw_close(&w, '}')
  jw_close(&w, ']')
  jw_close(&w, '}')
  fputc('\n', out)
