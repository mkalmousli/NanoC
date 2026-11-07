// Expansion driver: templates and compile-time source transformations.
@lang 1
+ "nanoc/nanoc.h"

// Expands tokens until stable.
f nc_expand(NcContext *ctx, NcTokens ts, size_t depth) char *
  nc_depth(ctx, depth, ts.n ? ts.v[0].line : 1, "expansion")
  nc_names(ctx, ts)
  NcCursor c = {ctx, ts, 0}
  NcBuffer out = {0}
  while c.pos < ts.n
    NcToken t = ts.v[c.pos++]
    if nc_trace_cursor(ctx, t)
      nc_addn(ctx, &out, t.s, t.n)
      ^
    if nc_compact_decl(ts, c.pos - 1)
      size_t parent = ctx->trace_parent
      size_t event = nc_trace_begin(ctx, t, "declaration", nc_text(ctx, t))
      char *generated = nc_is(t, "f") ? nc_native_function(ctx, &c, depth + 1) : nc_record(ctx, &c, t.s[0])
      nc_marker(ctx, &out, t.line)
      if c.pos
        nc_trace_end_source(ctx, event, ts.v[c.pos - 1])
      nc_add(ctx, &out, nc_trace_wrap(ctx, event, generated, parent))
      nc_marker(ctx, &out, nc_line(&c))
    elif t.kind == NC_PUNCT && nc_is(t, "@")
      nc_step(ctx, t.line)
      char *name = nc_name(&c), *generated = ""
      size_t parent = ctx->trace_parent
      size_t event = nc_trace_begin(ctx, t, "expansion", name)
      if ctx->frame_count == 256
        nc_fail(ctx, t.line, "expansion depth limit exceeded")
      char *frame = nc_format(ctx, "while expanding @%s at %s:%d", name, ctx->file, t.line)
      size_t at = ctx->frame_count++
      ctx->frames[at] = frame
      if !strcmp(name, "m")
        nc_define_macro(ctx, &c)
      elif !strcmp(name, "ct")
        generated = nc_compile_time(ctx, nc_meta_body(&c, nc_header(&c), 1, 0), depth + 1)
      elif !strcmp(name, "bt")
        nc_fail(ctx, t.line, "@bt was removed; use an external build tool")
      elif !strcmp(name, "asm")
        nc_fail(ctx, t.line, "NanoC asm was removed; use @c for compiler-specific C")
      elif !strcmp(name, "c")
        generated = nc_raw(ctx, &c)
      else
        generated = nc_invoke_macro(ctx, &c, name, depth + 1)
      --ctx->frame_count
      nc_marker(ctx, &out, t.line)
      if c.pos
        nc_trace_end_source(ctx, event, ts.v[c.pos - 1])
      nc_add(ctx, &out, nc_trace_wrap(ctx, event, generated, parent))
      nc_marker(ctx, &out, nc_line(&c))
    elif nc_runtime_start(ctx, ts, c.pos - 1)
      --c.pos
      char *fragment = nc_runtime_scope(ctx, &c)
      nc_add(ctx, &out, nc_expand(ctx, nc_lex(ctx, fragment, t.line), depth + 1))
    elif nc_directive_start(ts, c.pos - 1)
      NcCursor peek = c
      --peek.pos
      NcLayoutLine head = nc_logical_line(&peek)
      int pp = nc_pp_kind(nc_significant(ctx, head.ts))
      char *directive = nc_pp_simple(ctx, head.ts, head.line)
      if nc_is(t, "asm")
        nc_fail(ctx, t.line, "NanoC asm was removed; use @c for compiler-specific C")
      if pp >= 1 && pp <= 3
        size_t parent = ctx->trace_parent
        size_t event = nc_trace_begin(ctx, t, "preprocessor", nc_text(ctx, t))
        c = peek
        char *text = nc_pp_scope(ctx, &c, head, depth)
        if c.pos
          nc_trace_end_source(ctx, event, ts.v[c.pos - 1])
        nc_add(ctx, &out, nc_trace_wrap(ctx, event, text, parent))
      elif pp >= 4
        nc_fail(ctx, t.line, "preprocessor branch without matching condition")
      elif directive
        size_t parent = ctx->trace_parent
        size_t event = nc_trace_begin(ctx, t, "preprocessor", nc_text(ctx, t))
        c = peek
        if c.pos
          nc_trace_end_source(ctx, event, ts.v[c.pos - 1])
        nc_add(ctx, &out, nc_trace_wrap(ctx, event, directive, parent))
      else
        nc_addn(ctx, &out, t.s, t.n)
    else
      nc_addn(ctx, &out, t.s, t.n)
    nc_check(ctx, out.n, t.line)
  nc_add(ctx, &out, "")
  < out.v

// Transpiles source text to C.
f nc_transpile(NcContext *ctx, const char *input) char *
  input = nc_lang_check(ctx, input)
  nc_check(ctx, strlen(input), 1)
  if !nc_has_syntax(ctx, input)
    ctx->pass = 1
    ctx->source = input
    NcToken source = {input,strlen(input),1,1,NC_SPACE}
    size_t event = nc_trace_begin(ctx, source, "identity", "")
    nc_trace_end_source(ctx, event, source)
    if event && !ctx->mini
      ctx->traces.v[event - 1].start = 0
      ctx->traces.v[event - 1].end = strlen(input)
    char *text = ctx->mini ? nc_trace_wrap(ctx, event, input, 0) : (char *)input
    < ctx->mini ? nc_mini(ctx, text) : text
  char *output = nc_pipeline(ctx, input)
  char *prelude = nc_prelude(ctx)
  if *prelude && !strstr(output, prelude)
    output = nc_format(ctx, "%s%s", prelude, output)
  < strcmp(output, input) || ctx->mini ? nc_style(ctx, output) : output
