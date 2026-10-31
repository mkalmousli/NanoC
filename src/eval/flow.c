#include "nanoc/eval.h"
NcFlow nc_conditional(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth) {
    NcTokens cond = nc_group(c, "(", ")");
    NcTokens yes = nc_group(c, "{", "}"), no = {0};
    if (nc_eat(c, "else")) no = nc_group(c, "{", "}");
    bool choose = nc_truth(nc_eval(m, cond, env, depth, true));
    return nc_run(m, choose ? yes : no, nc_env(m->ctx, env), depth + 1);
}
NcFlow nc_loop(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth, const char *name) {
    NcContext *ctx = m->ctx;
    NcFlow out = {0};
    if (!strcmp(name, "for") && nc_at(c, "(")) return nc_c_for(m, c, env, depth);
    if (!strcmp(name, "while")) {
        NcTokens cond = nc_group(c, "(", ")"), body = nc_group(c, "{", "}");
        while (nc_truth(nc_eval(m, cond, env, depth, true))) {
            nc_depth(ctx, depth, nc_line(c), "compile-time");
            out = nc_run(m, body, nc_env(ctx, env), depth + 1);
            if (out.returning) return out;
            if (out.breaking) return (NcFlow){0};
        }
    } else {
        char *id = nc_name(c);
        nc_need(c, "in");
        NcTokens input = nc_until(c, "{"), body = nc_group(c, "{", "}");
        NcValue values = nc_eval(m, input, env, depth, true);
        if (values.kind != NC_LIST) nc_fail(ctx, nc_line(c), "for requires a list");
        for (size_t i = 0; i < values.count; ++i) {
            NcEnv *scope = nc_env(ctx, env);
            nc_bind(ctx, scope, id, values.items[i]);
            out = nc_run(m, body, scope, depth + 1);
            if (out.returning) return out;
            if (out.breaking) return (NcFlow){0};
        }
    }
    return (NcFlow){0};
}
