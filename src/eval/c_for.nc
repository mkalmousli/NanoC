// C-style for loops in meta code.
// Runs one for-loop clause.
@f statement(NcContext *c, NcTokens ts) static NcTokens = nc_lex(c, nc_format(c, "%s;", nc_join(c, ts)), ts.n ? ts.v[0].line : 1)
// Runs a C-style for loop.
@f nc_c_for(NcMachine *m, NcCursor *c, NcEnv *parent, usize depth) NcFlow
  NcContext *ctx = m->ctx
  NcGroups parts = nc_split(ctx, nc_group(c, "(", ")"), ";")
  if parts.n != 3 then nc_fail(ctx, nc_line(c), "for expects init; condition; step")
  NcTokens body = nc_group(c, "{", "}")
  NcEnv *env = nc_env(ctx, parent)
  NcFlow init = nc_run(m, statement(ctx, parts.v[0]), env, depth + 1)
  if init.returning or init.breaking or init.continuing then nc_fail(ctx, nc_line(c), "invalid for initializer")
  for ;;
    NcCursor condition = {ctx, parts.v[1], 0}
    if !nc_end(&condition) and !nc_truth(nc_eval(m, parts.v[1], env, depth + 1, true)) then break
    nc_depth(ctx, depth, nc_line(c), "compile-time")
    NcFlow flow = nc_run(m, body, nc_env(ctx, env), depth + 1)
    if flow.returning then return flow
    if flow.breaking then break
    flow = nc_run(m, statement(ctx, parts.v[2]), env, depth + 1)
    if flow.returning or flow.breaking or flow.continuing then nc_fail(ctx, nc_line(c), "invalid for step")
  (NcFlow){0}
