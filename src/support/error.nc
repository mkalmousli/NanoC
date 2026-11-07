// Errors and execution limits.
@lang 1
+ "nanoc/nanoc.h"

// Reports an error and stops.
f nc_fail(NcContext *c, int line, const char *format, ...) -> _Noreturn void
  va_list args
  va_start(args, format)
  vsnprintf(c->detail, sizeof c->detail, format, args)
  va_end(args)
  c->error_line = line
  c->error_span = (NcSpan){line,0,line,0}
  if line > 0 && c->last_token.line == line
    c->error_span = nc_trace_span((NcTokens){&c->last_token,1,1})
  const char *limit = strstr(c->detail, "limit")
  bool bounded = limit && (limit == c->detail || !isalpha((unsigned char)limit[-1])) && !isalpha((unsigned char)limit[5])
  c->code = c->next_error_code ? c->next_error_code : bounded ? "NC_LIMIT" : line > 0 ? "NC_SYNTAX" : "NC_INPUT"
  c->next_error_code = NULL
  snprintf(c->error, sizeof c->error, "%s:%d: %s", c->file, line, c->detail)
  for (size_t i = c->frame_count; i; --i)
    size_t used = strlen(c->error)
    snprintf(c->error + used, sizeof c->error - used, "\n  %s", c->frames[i - 1])
  longjmp(c->trap, 1)

// Counts a step against the limit.
f nc_step(NcContext *c, int line) -> void
  if (c->max_steps && c->steps == c->max_steps)
    nc_fail(c, line, "compile-time step limit exceeded")
  if (c->steps != SIZE_MAX)
    ++c->steps

// Checks the output size limit.
f nc_check(NcContext *c, size_t bytes, int line) -> void
  if (bytes > c->max_output)
    nc_fail(c, line, "output limit exceeded")

// Checks the nesting limit.
f nc_depth(NcContext *c, size_t depth, int line, const char *kind) -> void
  if (depth > c->max_depth || depth > 512)
    nc_fail(c, line, "%s depth limit exceeded", kind)
  nc_step(c, line)
