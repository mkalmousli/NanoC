// Runs a whole meta program.
@lang 1
+ "nanoc/nanoc.h"

// Runs a meta program body.
f nc_program(NcContext *ctx, NcTokens ts, NcEnv *env, NcPhase phase, size_t depth) -> char *
  NcMachine m = {.ctx = ctx, .root = env ? env : nc_env(ctx, NULL), .phase = phase, .depth = depth}
  NcFlow flow = nc_run(&m, ts, m.root, depth)
  int line = ts.n ? ts.v[0].line : 1
  if (flow.breaking || flow.continuing)
    nc_fail(ctx, line, "loop control outside a loop")
  if (flow.returning)
    if (phase == NC_CT)
      nc_fail(ctx, line, "return outside a compile-time function")
    if (phase == NC_MACRO && (flow.value.kind == NC_INT || flow.value.kind == NC_BOOL))
      nc_add(ctx, &m.output, nc_value_code(ctx, flow.value, line))
    elif (flow.value.kind != NC_STRING && flow.value.kind != NC_CODE)
      nc_fail(ctx, line, "program result must be text or tokens")
    else
      nc_add(ctx, &m.output, flow.value.text)
  nc_add(ctx, &m.output, "")
  nc_check(ctx, m.output.n, line)
  return m.output.v
