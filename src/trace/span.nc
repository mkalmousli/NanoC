// Source spans are preserved on logical layout lines before syntax lowering.
@lang 1
+ "nanoc/nanoc.h"

// Computes a half-open source span from original lexer coordinates.
f nc_trace_span(NcTokens tokens) NcSpan
  NcSpan span = {0}
  if !tokens.n
    < span
  NcToken first = tokens.v[0], last = tokens.v[tokens.n - 1]
  span.line = first.line
  span.column = first.column
  span.end_line = last.line
  span.end_column = last.column
  for size_t i = 0; i < last.n; ++i
    if last.s[i] == '\n'
      ++span.end_line
      span.end_column = 1
    else
      ++span.end_column
  < span

// Extends a structured operation through the last child or branch.
f nc_trace_extend(NcContext *c, size_t id, NcSpan span)
  if !id || !span.line
    <
  NcSpan *target = &c->traces.v[id - 1].source
  target->end_line = span.end_line
  target->end_column = span.end_column

// Filters a map by original source, declared symbol, or generated C offset.
f nc_trace_matches(NcContext *c, NcTrace *event) bool
  if c->query_line && (event->synthetic || c->query_line < event->source.line || c->query_line > event->source.end_line)
    < 0
  if c->query_symbol && *c->query_symbol && strcmp(c->query_symbol, event->name ? event->name : "")
    bool found = 0
    for size_t i = 0; i < event->identifiers.n; ++i
      if !strcmp(c->query_symbol, event->identifiers.v[i])
        found = 1
    if !found
      < 0
  if c->query_generated && (event->start == SIZE_MAX || c->query_offset < event->start || c->query_offset >= event->end)
    < 0
  < 1

// Serializes a map through a standard C temporary stream before an atomic file write.
f nc_trace_text(NcContext *c, const char *generated) char *
  FILE *file = tmpfile()
  if !file
    nc_fail(c, 0, "cannot create map stream")
  nc_trace_json(file, c, generated)
  long size = ftell(file)
  if size < 0 || (uintmax_t)size > c->max_output
    fclose(file)
    nc_fail(c, 0, "map output limit exceeded")
  rewind(file)
  char *text = nc_alloc(c, (size_t)size + 1)
  bool ok = fread(text, 1, (size_t)size, file) == (size_t)size
  fclose(file)
  if !ok
    nc_fail(c, 0, "cannot read map stream")
  < text
