#include "nanoc/macro.h"
void nc_define_macro(NcContext *ctx, NcCursor *c) {
    char *name = nc_name(c);
    if (!strcmp(name, "fn") || !strcmp(name, "let") || !strcmp(name, "for") ||
        !strcmp(name, "macro") || !strcmp(name, "ct") || !strcmp(name, "m") ||
        !strcmp(name, "f") || !strcmp(name, "bt")) nc_fail(ctx, nc_line(c), "reserved extension name");
    if (nc_get(&ctx->macros, name)) nc_fail(ctx, nc_line(c), "duplicate macro: %s", name);
    NcMacro *m = nc_alloc(ctx, sizeof *m);
    NcGroups args = nc_split(ctx, nc_group(c, "(", ")"), ",");
    NcMap names = {0};
    for (size_t i = 0; i < args.n; ++i) {
        NcCursor a = {ctx, args.v[i], 0};
        nc_need(&a, "$");
        NcParam p = {.name = nc_name(&a)};
        p.kind = nc_eat(&a, ":") ? nc_name(&a) : "tokens";
        p.variadic = nc_eat(&a, "...");
        if (!nc_end(&a) || (strcmp(p.kind, "tokens") && strcmp(p.kind, "ident") && strcmp(p.kind, "block")))
            nc_fail(ctx, nc_line(&a), "expected ident, tokens, or block parameter");
        if (nc_get(&names, p.name) || !strcmp(p.name, "fresh"))
            nc_fail(ctx, nc_line(&a), "duplicate or reserved parameter");
        nc_put(ctx, &names, p.name, (void *)1);
        if (m->params.n && m->params.v[m->params.n - 1].variadic)
            nc_fail(ctx, nc_line(&a), "variadic parameter must be last");
        NC_PUSH(ctx, m->params, p);
    }
    m->program = nc_eat(c, "=>");
    if (m->program && !nc_at(c, "{")) {
        int line = nc_line(c);
        char *expr = nc_join(ctx, nc_until(c, ";"));
        nc_need(c, ";");
        m->body = nc_lex(ctx, nc_format(ctx, "return %s;", expr), line);
    } else m->body = nc_group(c, "{", "}");
    nc_put(ctx, &ctx->macros, name, m);
}
