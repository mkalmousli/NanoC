// Errors and execution limits.
@use "nanoc/nanoc"
// Reports an error and stops.
@f nc_fail(NcContext *c, int line, cstr format, ...) _Noreturn void
  va_list args
  va_start(args, format)
  vsnprintf(c->detail, sizeof c->detail, format, args)
  va_end(args)
  c->error_line = line
  c->code = strstr(c->detail, "limit") ? "NC_LIMIT" : line > 0 ? "NC_SYNTAX" : "NC_INPUT"
  snprintf(c->error, sizeof c->error, "%s:%d: %s", c->file, line, c->detail)
  for usize i = c->frame_count; i; --i
    usize used = strlen(c->error)
    snprintf(c->error + used, sizeof c->error - used, "\n  %s", c->frames[i - 1])
  longjmp(c->trap, 1)
// Counts a step against the limit.
@f nc_step(NcContext *c, int line) void
  if c->max_steps and c->steps == c->max_steps then nc_fail(c, line, "compile-time step limit exceeded")
  if c->steps != SIZE_MAX
    ++c->steps
// Checks the output size limit.
@f nc_check(NcContext *c, usize bytes, int line) void
  if bytes > c->max_output then nc_fail(c, line, "output limit exceeded")
// Checks the nesting limit.
@f nc_depth(NcContext *c, usize depth, int line, cstr kind) void
  if depth > c->max_depth or depth > 512 then nc_fail(c, line, "%s depth limit exceeded", kind)
  nc_step(c, line)
