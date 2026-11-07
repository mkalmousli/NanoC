// NanoC v1 typed functions; the C compiler validates all C types and declarators.
@lang 1
+ "nanoc/nanoc.h"

// Reads a C return type up to an expression body, prototype delimiter, or newline.
f return_type(NcCursor *c, int line) static NcTokens
  size_t start = c->pos
  while nc_same_line(c, line) && !nc_header_at(c, "=", line) && !nc_header_at(c, ";", line) && !nc_header_at(c, "{", line)
    (void)nc_take(c)
  < nc_slice(c->ts, start, c->pos)

// Expands a v1 function with an optional C return type and an indented body.
f nc_native_function(NcContext *ctx, NcCursor *c, size_t depth) char *
  NcHeader header = nc_header(c)
  int definition_line = header.line
  char *name = nc_name(c)
  if ctx->tracing && ctx->trace_parent
    ctx->traces.v[ctx->trace_parent - 1].name = name
    ctx->traces.v[ctx->trace_parent - 1].rule = "function"
  if !nc_header_at(c, "(", header.line)
    nc_fail(ctx, header.line, "function signatures require parentheses")
  char *params = nc_native_parameters(ctx, nc_group(c, "(", ")"))
  header.line = c->ts.v[c->pos - 1].line
  if nc_header_at(c, "->", header.line)
    nc_fail(ctx, header.line, "write the return type directly after the parameter list; omit ->")
  char *type = nc_trim(ctx, nc_join(ctx, return_type(c, header.line)))
  while *type == '*'
    type = nc_format(ctx, "%s *", nc_trim(ctx, type + 1))
  if !*type
    type = !strcmp(name, "main") ? "int" : "void"
  NC_PUSH(ctx, ctx->symbols, ((NcSymbol){name, params, type, "", definition_line}))
  if nc_header_eat(c, ";", header.line)
    < nc_format(ctx, "%s%s%s(%s);", type, nc_sep(type), name, params)
  if nc_header_at(c, "=", header.line)
    nc_fail(ctx, header.line, "function bodies use indentation and < for returns")
  if nc_header_at(c, "{", header.line)
    nc_fail(ctx, header.line, "function bodies use indentation; C blocks use @c")
  char *body = nc_emit_block(ctx, nc_indented_nodes(c, header, 0), 0)
  char *expanded = nc_expand(ctx, nc_lex(ctx, body, header.line), depth)
  < nc_format(ctx, "%s%s%s(%s) {%s}", type, nc_sep(type), name, params, expanded)
