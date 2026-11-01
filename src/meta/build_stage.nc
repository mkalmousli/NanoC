// Selects the BT build stage.
@s Programs v:*NcTokens; n,cap:usize
// Runs BT code in the build stage.
@f nc_build_stage(NcContext *ctx, cstr source) char *
  if !strstr(source, "bt")
    ctx->source = source
    return (char *)source
  NcTokens ts = nc_lex(ctx, source, 1)
  NcCursor c = {ctx, ts, 0}
  NcBuffer bare = {0}
  Programs programs = {0}
  while c.pos < ts.n
    usize start = c.pos
    NcToken t = ts.v[c.pos++]
    if t.kind == NC_PUNCT && nc_is(t, "@")
      usize next = c.pos
      while next < ts.n and ts.v[next].kind == NC_SPACE
        ++next
      if next < ts.n && nc_is(ts.v[next], "bt")
        c.pos = next + 1
        NC_PUSH(ctx, programs, nc_meta_body(&c, nc_header(&c), true, false))
        for i:usize in start..c.pos
          for usize j = 0; j < ts.v[i].n; ++j then nc_add(ctx, &bare, ts.v[i].s[j] == '\n' ? "\n" : " ")
        continue
      if next < ts.n && (nc_is(ts.v[next], "m") || nc_is(ts.v[next], "macro"))
        c.pos = next + 1
        NcHeader header = nc_header(&c)
        (void)nc_name(&c)
        if nc_header_at(&c, "(", header.line) then (void)nc_group(&c, "(", ")")
        bool program
        (void)nc_macro_body(&c, header, &program)
      elif next < ts.n && nc_is(ts.v[next], "asm")
        c.pos = next + 1
        (void)nc_assembly(ctx, &c)
      elif next < ts.n && nc_is(ts.v[next], "ct")
        c.pos = next + 1
        (void)nc_meta_body(&c, nc_header(&c), true, false)
    for i:usize in start..c.pos then nc_addn(ctx, &bare, ts.v[i].s, ts.v[i].n)
  if not programs.n
    ctx->source = source
    return (char *)source
  nc_add(ctx, &bare, "")
  ctx->source = bare.v
  NcBuffer prelude = {0}
  for i:usize in 0..programs.n
    if ctx->frame_count == 256 then nc_fail(ctx, 1, "build depth limit exceeded")
    char *frame = nc_format(ctx, "while executing @bt at %s:%d", ctx->file,
      programs.v[i].n ? programs.v[i].v[0].line : 1)
    ctx->frames[ctx->frame_count++] = frame
    nc_add(ctx, &prelude, nc_program(ctx, programs.v[i], nil, NC_BT, 1))
    --ctx->frame_count
    if ctx->next_source
      ctx->source = ctx->next_source
      ctx->next_source = nil
      ctx->again = false
  if prelude.n then nc_add(ctx, &prelude, "\n")
  nc_add(ctx, &prelude, ctx->source)
  nc_check(ctx, prelude.n, 1)
  prelude.v
