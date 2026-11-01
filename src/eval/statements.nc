// Statement execution for CT/BT code.
@use "nanoc/nanoc"
// Runs a statement sequence.
@f nc_run(NcMachine *m, NcTokens ts, NcEnv *env, usize depth) NcFlow
  NcContext *ctx = m->ctx
  nc_depth(ctx, depth, ts.n ? ts.v[0].line : 1, "compile-time")
  NcCursor c = {ctx, ts, 0}
  NcFlow out = {0}
  while !nc_end(&c)
    NcToken t = nc_take(&c)
    nc_step(ctx, t.line)
    usize next = c.pos
    while next < ts.n and ts.v[next].kind == NC_SPACE
      ++next
    bool define_f = nc_is(t, "f") && next < ts.n && ts.v[next].kind == NC_WORD
    if nc_is(t, ";")
      continue
    if nc_is(t, "fn") || define_f
      nc_ct_define(m, &c, env)
    elif nc_is(t, "if")
      out = nc_conditional(m, &c, env, depth)
      if out.returning or out.breaking or out.continuing
        return out
    elif nc_is(t, "for") || nc_is(t, "while")
      out = nc_loop(m, &c, env, depth, nc_text(ctx, t))
      if out.returning or out.breaking or out.continuing
        return out
    elif nc_is(t, "break") || nc_is(t, "continue")
      nc_need(&c, ";")
      return (NcFlow){.breaking = nc_is(t, "break"), .continuing = nc_is(t, "continue")}
    elif nc_is(t, "return") || nc_is(t, "=>")
      NcValue value = nc_eval(m, nc_until(&c, ";"), env, depth, true)
      nc_need(&c, ";")
      return (NcFlow){.returning = true, .value = value}
    elif nc_is(t, "let")
      char *id = nc_name(&c)
      nc_need(&c, "=")
      if nc_get(&env->values, id)
        nc_fail(ctx, t.line, "duplicate compile-time variable: %s", id)
      nc_bind(ctx, env, id, nc_eval(m, nc_until(&c, ";"), env, depth, true))
      nc_need(&c, ";")
    else
      if !nc_assignment(m, &c, env, depth, t)
        --c.pos
        (void)nc_eval(m, nc_until(&c, ";"), env, depth, true)
      nc_need(&c, ";")
  out
// Expands a compile-time block.
@f nc_compile_time(NcContext *ctx, NcTokens ts, usize depth) char *
  nc_expand(ctx, nc_lex(ctx, nc_program(ctx, ts, nil, NC_CT, depth), ts.n ? ts.v[0].line : 1),
    depth)
