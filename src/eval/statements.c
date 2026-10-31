#include "nanoc/eval.h"
NcFlow nc_run(NcMachine *m, NcTokens ts, NcEnv *env, size_t depth) {
    NcContext *ctx = m->ctx;
    nc_depth(ctx, depth, ts.n ? ts.v[0].line : 1, "compile-time");
    NcCursor c = {ctx, ts, 0};
    NcFlow out = {0};
    while (!nc_end(&c)) {
        NcToken t = nc_take(&c);
        nc_step(ctx, t.line);
        size_t next = c.pos;
        while (next < ts.n && ts.v[next].kind == NC_SPACE) ++next;
        bool define_f = nc_is(t, "f") && next < ts.n && ts.v[next].kind == NC_WORD;
        if (nc_is(t, ";")) continue;
        if (nc_is(t, "fn") || define_f) nc_ct_define(m, &c, env);
        else if (nc_is(t, "if")) {
            out = nc_conditional(m, &c, env, depth);
            if (out.returning || out.breaking || out.continuing) return out;
        } else if (nc_is(t, "for") || nc_is(t, "while")) {
            out = nc_loop(m, &c, env, depth, nc_text(ctx, t));
            if (out.returning || out.breaking || out.continuing) return out;
        } else if (nc_is(t, "break") || nc_is(t, "continue")) {
            nc_need(&c, ";");
            return (NcFlow){.breaking = nc_is(t, "break"), .continuing = nc_is(t, "continue")};
        } else if (nc_is(t, "return") || nc_is(t, "=>")) {
            NcValue value = nc_eval(m, nc_until(&c, ";"), env, depth, true);
            nc_need(&c, ";");
            return (NcFlow){.returning = true, .value = value};
        } else if (nc_is(t, "let")) {
            char *id = nc_name(&c);
            nc_need(&c, "=");
            if (nc_get(&env->values, id)) nc_fail(ctx, t.line, "duplicate compile-time variable: %s", id);
            nc_bind(ctx, env, id, nc_eval(m, nc_until(&c, ";"), env, depth, true));
            nc_need(&c, ";");
        } else {
            if (!nc_assignment(m, &c, env, depth, t)) {
                --c.pos;
                (void)nc_eval(m, nc_until(&c, ";"), env, depth, true);
            }
            nc_need(&c, ";");
        }
    }
    return out;
}
char *nc_compile_time(NcContext *ctx, NcTokens ts, size_t depth) {
    return nc_expand(ctx, nc_lex(ctx, nc_program(ctx, ts, NULL, NC_CT, depth), ts.n ? ts.v[0].line : 1), depth);
}
