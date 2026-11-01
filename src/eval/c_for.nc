#include "nanoc/nanoc.h"
@f statement(NcContext *c, NcTokens ts) static NcTokens
  nc_lex(c, nc_format(c, "%s;", nc_join(c, ts)), ts.n ? ts.v[0].line : 1)
@f nc_c_for(NcMachine *m, NcCursor *c, NcEnv *parent, size_t depth) NcFlow
  NcContext *ctx = m->ctx
  NcGroups parts = nc_split(ctx, nc_group(c, "(", ")"), ";")
  if parts.n != 3
    nc_fail(ctx, nc_line(c), "for expects init; condition; step")
  NcTokens body = nc_group(c, "{", "}")
  NcEnv *env = nc_env(ctx, parent)
  NcFlow init = nc_run(m, statement(ctx, parts.v[0]), env, depth + 1)
  if init.returning || init.breaking || init.continuing
    nc_fail(ctx, nc_line(c), "invalid for initializer")
  for ;;
    NcCursor condition = {ctx, parts.v[1], 0}
    if !nc_end(&condition) && !nc_truth(nc_eval(m, parts.v[1], env, depth + 1, true))
      break
    nc_depth(ctx, depth, nc_line(c), "compile-time")
    NcFlow flow = nc_run(m, body, nc_env(ctx, env), depth + 1)
    if flow.returning
      return flow
    if flow.breaking
      break
    flow = nc_run(m, statement(ctx, parts.v[2]), env, depth + 1)
    if flow.returning || flow.breaking || flow.continuing
      nc_fail(ctx, nc_line(c), "invalid for step")
  (NcFlow){0}
