// Expansion driver: macros, @ct, @bt.
// Expands tokens until stable.
@f nc_expand(NcContext *ctx, NcTokens ts, usize depth) char *
  nc_depth(ctx, depth, ts.n ? ts.v[0].line : 1, "expansion")
  nc_names(ctx, ts)
  NcCursor c = {ctx, ts, 0}
  NcBuffer out = {0}
  while c.pos < ts.n
    NcToken t = ts.v[c.pos++]
    if t.kind != NC_PUNCT || !nc_is(t, "@") then nc_addn(ctx, &out, t.s, t.n)
    else
      nc_step(ctx, t.line)
      char *name = nc_name(&c), *generated = ""
      if ctx->frame_count == 256 then nc_fail(ctx, t.line, "expansion depth limit exceeded")
      char *frame = nc_format(ctx, "while expanding @%s at %s:%d", name, ctx->file, t.line)
      usize at = ctx->frame_count++
      ctx->frames[at] = frame
      if !strcmp(name, "macro") || !strcmp(name, "m") then nc_define_macro(ctx, &c)
      elif !strcmp(name, "ct") then generated = nc_compile_time(ctx, nc_meta_body(&c, nc_header(&c), true, false), depth + 1)
      elif !strcmp(name, "bt")
        generated = nc_program(ctx, nc_meta_body(&c, nc_header(&c), true, false), nil, NC_BT,
          depth + 1)
      elif !strcmp(name, "f") then generated = nc_native_function(ctx, &c, depth + 1)
      elif (!strcmp(name, "inc") || !strcmp(name, "use")) && !nc_get(&ctx->macros, name) then generated = nc_include(ctx, &c)
      elif strlen(name) == 1 && strchr("seu", name[0]) && !nc_get(&ctx->macros, name) then generated = nc_record(ctx, &c, name[0])
      elif !strcmp(name, "c") then generated = nc_raw(ctx, &c)
      elif !strcmp(name, "asm") then generated = nc_assembly(ctx, &c)
      elif !strcmp(name, "fn") || !strcmp(name, "let") || !strcmp(name, "for")
        generated = nc_shorthand(ctx, &c, name, depth + 1)
      else generated = nc_invoke_macro(ctx, &c, name, depth + 1)
      --ctx->frame_count
      nc_marker(ctx, &out, t.line)
      nc_add(ctx, &out, generated)
      nc_marker(ctx, &out, nc_line(&c))
    nc_check(ctx, out.n, t.line)
  nc_add(ctx, &out, "")
  out.v
// Transpiles source text to C.
@f nc_transpile(NcContext *ctx, cstr input) char *
  nc_check(ctx, strlen(input), 1)
  if !strchr(input, '@') then ctx->pass = 1; ctx->source = input; return ctx->mini ? nc_mini(ctx, input) : (char *)input
  char *output = nc_pipeline(ctx, input)
  char *prelude = nc_prelude(ctx)
  if *prelude and !strstr(output, prelude) then output = nc_format(ctx, "%s%s", prelude, output)
  if ctx->need_stdio && !strstr(output, "<stdio.h>") then output = nc_format(ctx, "#include <stdio.h>\n%s", output)
  strcmp(output, input) or ctx->mini ? nc_style(ctx, output) : output
