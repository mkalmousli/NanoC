#include "nanoc/layout.h"
char *nc_control(NcContext *ctx, NcTokens ts, int line) {
    char *source = nc_trim(ctx, nc_words(ctx, ts));
    size_t len = strlen(source);
    if (!len) nc_fail(ctx, line, "empty control header");
    char *header = nc_trim(ctx, nc_string(ctx, source, len - 1));
    NcCursor c = {ctx, nc_lex(ctx, header, line), 0};
    char *name = nc_name(&c);
    char *rest = nc_trim(ctx, nc_join(ctx, nc_slice(c.ts, c.pos, c.ts.n)));
    if (!strcmp(name, "if") || !strcmp(name, "while") || !strcmp(name, "elif")) {
        if (!*rest) nc_fail(ctx, line, "missing condition");
        return nc_format(ctx, "%s (%s)", !strcmp(name, "elif") ? "else if" : name, rest);
    }
    if (!strcmp(name, "else")) {
        if (*rest) nc_fail(ctx, line, "else takes no condition");
        return "else";
    }
    if (!strcmp(name, "for")) {
        char *id = nc_name(&c), *type = "int";
        if (nc_eat(&c, ":")) type = nc_name(&c);
        nc_need(&c, "in");
        char *bounds = nc_join(ctx, nc_slice(c.ts, c.pos, c.ts.n));
        NcBuffer out = {0};
        for (size_t i = 0; bounds[i]; ++i) {
            if (!strncmp(bounds + i, "..<", 3)) { nc_add(ctx, &out, ".."); i += 2; }
            else nc_addn(ctx, &out, bounds + i, 1);
        }
        nc_add(ctx, &out, "");
        return nc_format(ctx, "@for (%s %s in %s)", type, id, out.v);
    }
    nc_fail(ctx, line, "unsupported block header: %s", name);
}
