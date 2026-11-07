// Expansion events are created by parser and evaluator operations, never inferred from string diffs.
@lang 1
+ "nanoc/nanoc.h"

// Opens a compiler operation and records its source provenance before generation.
f nc_trace_begin(NcContext *c, NcToken t, const char *rule, const char *name) -> size_t
  if (!c->tracing)
    return 0
  NcTrace event = {.id = c->traces.n + 1, .parent = c->trace_parent, .pass = c->pass,
          .source = {t.line,t.column,t.line,t.column + (int)t.n}, .start = SIZE_MAX, .end = SIZE_MAX,
          .rule = rule, .name = name, .input = c->source ? c->source : ""}
  uintptr_t p = (uintptr_t)t.s, base = (uintptr_t)c->source
  event.synthetic = !c->source || p < base || p - base > strlen(c->source)
  NC_PUSH(c, c->traces, event)
  c->trace_parent = event.id
  return event.id

// Extends an operation's source span to the final consumed token.
f nc_trace_end_source(NcContext *c, size_t id, NcToken t) -> void
  if (!id)
    return
  NcSpan *span = &c->traces.v[id - 1].source
  int line = t.line, column = t.column
  for (size_t i = 0; i < t.n; ++i)
    if (t.s[i] == '\n')
      ++line
      column = 1
    else
      ++column
  span->end_line = line
  span->end_column = column

// Writes an internal event boundary that the final emitter consumes without printing.
f nc_trace_mark(NcContext *c, NcBuffer *out, size_t id, bool begin) -> void
  if (id)
    nc_printf(c, out, "/*nc-trace:%c:%zu*/", begin ? 'b' : 'e', id)

// Wraps generated tokens in an operation boundary and restores its expansion parent.
f nc_trace_wrap(NcContext *c, size_t id, const char *text, size_t parent) -> char *
  c->trace_parent = parent
  if (!id)
    return (char *)text
  NcBuffer out = {0}
  nc_trace_mark(c, &out, id, 1)
  nc_add(c, &out, text)
  nc_trace_mark(c, &out, id, 0)
  return out.v

// Captures evaluator output or a substituted argument on the current operation.
f nc_trace_value(NcContext *c, const char *name, const char *text) -> void
  if (!c->tracing || !c->trace_parent)
    return
  NcTrace *event = &c->traces.v[c->trace_parent - 1]
  if (!name)
    event->result = text
  else
    NC_PUSH(c, event->captures, nc_format(c, "%s=%s", name, text))

// Resolves event boundaries at final emission time, using the actual output buffer offset.
f nc_trace_boundary(NcContext *c, NcBuffer *out, NcToken token) -> bool
  if (!c->tracing || token.kind != NC_SPACE || token.n < 16 || strncmp(token.s, "/*nc-trace:", 11))
    return 0
  char phase
  size_t id
  char *text = nc_text(c, token)
  if (sscanf(text, "/*nc-trace:%c:%zu*/", &phase, &id) != 2 || !id || id > c->traces.n)
    return 0
  NcTrace *event = &c->traces.v[id - 1]
  if (phase == 'b')
    event->start = out->n
  elif (phase == 'e')
    event->end = out->n
  else
    return 0
  return 1

// Restores provenance when recursive expansion encounters an already-lowered statement boundary.
f nc_trace_cursor(NcContext *c, NcToken token) -> bool
  if (!c->tracing || token.kind != NC_SPACE || token.n < 16 || strncmp(token.s, "/*nc-trace:", 11))
    return 0
  char phase
  size_t id
  if (sscanf(nc_text(c, token), "/*nc-trace:%c:%zu*/", &phase, &id) != 2 || !id || id > c->traces.n)
    return 0
  if (phase != 'b' && phase != 'e')
    return 0
  c->trace_parent = phase == 'b' ? id : c->traces.v[id - 1].parent
  return 1

// Starts one parsed layout node using its original indentation coordinates.
f nc_trace_line(NcContext *c, NcBuffer *out, NcLayoutLine line) -> size_t
  NcToken token = line.ts.v[0]
  token.line = line.line
  token.column = line.indent + 1
  size_t id = nc_trace_begin(c, token, line.raw ? "raw-c" : "statement", "")
  if (id)
    c->traces.v[id - 1].synthetic = c->trace_virtual != 0
    c->traces.v[id - 1].source = line.span.line ? line.span : nc_trace_span(line.ts)
    c->traces.v[id - 1].source.column = line.indent + 1
  nc_trace_mark(c, out, id, 1)
  return id

// Closes one parsed layout node and restores the enclosing transformation.
f nc_trace_finish(NcContext *c, NcBuffer *out, size_t id, size_t parent) -> void
  nc_trace_mark(c, out, id, 0)
  c->trace_parent = parent
