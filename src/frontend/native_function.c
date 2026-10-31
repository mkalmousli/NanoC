#include "nanoc/core.h"
char *nc_native_parameters(NcContext *, NcTokens);
static NcTokens return_type(NcCursor *c) {
    size_t start = c->pos;
    while (!nc_end(c) && !nc_at(c, "=>") && !nc_at(c, "{")) (void)nc_take(c);
    return nc_slice(c->ts, start, c->pos);
}
char *nc_native_function(NcContext *ctx, NcCursor *c, size_t depth) {
    int line = nc_line(c);
    char *name = nc_name(c);
    char *params = nc_native_parameters(ctx, nc_group(c, "(", ")"));
    char *type = "void";
    if (nc_eat(c, "->")) type = nc_trim(ctx, nc_join(ctx, return_type(c)));
    if (!*type) nc_fail(ctx, line, "missing return type");
    NC_PUSH(ctx, ctx->symbols, ((NcSymbol){name, params, type, "", line}));
    char *body;
    if (nc_eat(c, "=>")) {
        char *expr = nc_join(ctx, nc_until(c, ";"));
        nc_need(c, ";");
        body = nc_format(ctx, "%s%s;", strcmp(type, "void") ? "return " : "", expr);
    } else {
        NcTokens ts = nc_group(c, "{", "}");
        body = nc_join(ctx, ts);
    }
    char *expanded = nc_expand(ctx, nc_lex(ctx, body, line), depth);
    if (strstr(expanded, "=>")) {
        NcTokens ts = nc_lex(ctx, expanded, line);
        NcBuffer b = {0};
        for (size_t i = 0; i < ts.n; ++i) {
            NcToken t = ts.v[i];
            if (t.kind == NC_PUNCT && nc_is(t, "=>")) nc_add(ctx, &b, "return ");
            else nc_addn(ctx, &b, t.s, t.n);
        }
        nc_add(ctx, &b, "");
        expanded = b.v;
    }
    return nc_format(ctx, "%s %s(%s) {%s}", type, name, params, expanded);
}
