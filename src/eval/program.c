#include "nanoc/eval.h"
char *nc_program(NcContext *ctx, NcTokens ts, NcEnv *env, NcPhase phase, size_t depth) {
    NcMachine m = {.ctx = ctx, .root = env ? env : nc_env(ctx, NULL), .phase = phase, .depth = depth};
    NcFlow flow = nc_run(&m, ts, m.root, depth);
    int line = ts.n ? ts.v[0].line : 1;
    if (flow.breaking || flow.continuing) nc_fail(ctx, line, "loop control outside a loop");
    if (flow.returning) {
        if (phase == NC_CT) nc_fail(ctx, line, "return outside a compile-time function");
        if (flow.value.kind != NC_STRING && flow.value.kind != NC_CODE)
            nc_fail(ctx, line, "program result must be text or tokens");
        nc_add(ctx, &m.output, flow.value.text);
    }
    nc_add(ctx, &m.output, "");
    nc_check(ctx, m.output.n, line);
    return m.output.v;
}
