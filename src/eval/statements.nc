// Statement execution for compile-time programs.
@lang 1
+ "nanoc/nanoc.h"

// Runs a statement sequence.
f nc_run(NcMachine *m, NcTokens ts, NcEnv *env, size_t depth) NcFlow
  NcContext *ctx = m->ctx
  nc_depth(ctx, depth, ts.n ? ts.v[0].line : 1, "compile-time")
  NcCursor c = {ctx, ts, 0}
  NcFlow out = {0}
  while !nc_end(&c)
    NcToken t = nc_take(&c)
    nc_step(ctx, t.line)
    size_t next = c.pos
    while next < ts.n && ts.v[next].kind == NC_SPACE
      ++next
    bool define_f = nc_is(t, "f") && next < ts.n && ts.v[next].kind == NC_WORD
    if nc_is(t, ";")
      ^
    if define_f
      nc_ct_define(m, &c, env)
    elif nc_is(t, "if")
      out = nc_conditional(m, &c, env, depth)
      if out.returning || out.breaking || out.continuing
        < out
    elif nc_is(t, "for") || nc_is(t, "while")
      out = nc_loop(m, &c, env, depth, nc_text(ctx, t))
      if out.returning || out.breaking || out.continuing
        < out
    elif nc_is(t, "return") || nc_is(t, "break") || nc_is(t, "continue")
      nc_fail(ctx, t.line, "NanoC v1 uses <, ! and ^ for return, break and continue")
    elif nc_is(t, "!") || nc_is(t, "^")
      nc_need(&c, ";")
      < (NcFlow){.breaking = nc_is(t, "!"), .continuing = nc_is(t, "^")}
    elif nc_is(t, "<")
      NcValue value = nc_eval(m, nc_until(&c, ";"), env, depth, 1)
      nc_need(&c, ";")
      < (NcFlow){.returning = 1, .value = value}
    else
      if !nc_assignment(m, &c, env, depth, t)
        --c.pos
        (void)nc_eval(m, nc_until(&c, ";"), env, depth, 1)
      nc_need(&c, ";")
  < out

// Expands a compile-time block.
f nc_compile_time(NcContext *ctx, NcTokens ts, size_t depth) char *
  char *generated = nc_program(ctx, ts, NULL, NC_CT, depth)
  nc_trace_value(ctx, NULL, generated)
  ++ctx->trace_virtual
  char *expanded = nc_expand(ctx, nc_lex(ctx, generated, ts.n ? ts.v[0].line : 1), depth)
  --ctx->trace_virtual
  < expanded
