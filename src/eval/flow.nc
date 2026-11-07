// Conditionals and loops in meta code.
@lang 1
+ "nanoc/nanoc.h"

// Skips an if/elif/else chain.
f skip_conditional(NcCursor *c, size_t depth) static void
  nc_depth(c->ctx, depth, nc_line(c), "conditional")
  nc_need(c, "if")
  (void)nc_group(c, "(", ")")
  (void)nc_group(c, "{", "}")
  if nc_eat(c, "else")
    if nc_at(c, "if")
      skip_conditional(c, depth + 1)
    else
      (void)nc_group(c, "{", "}")

// Runs an if/elif/else chain.
f nc_conditional(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth) NcFlow
  NcTokens cond = nc_group(c, "(", ")")
  NcTokens yes = nc_group(c, "{", "}"), no = {0}
  if nc_eat(c, "else")
    if nc_at(c, "if")
      size_t start = c->pos
      skip_conditional(c, depth + 1)
      no = nc_slice(c->ts, start, c->pos)
    else
      no = nc_group(c, "{", "}")
  bool choose = nc_truth(nc_eval(m, cond, env, depth, 1))
  < nc_run(m, choose ? yes : no, nc_env(m->ctx, env), depth + 1)

// Runs a for or while loop.
f nc_loop(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth, const char *name) NcFlow
  NcContext *ctx = m->ctx
  NcFlow out = {0}
  if !strcmp(name, "for") && nc_at(c, "(")
    < nc_c_for(m, c, env, depth)
  if !strcmp(name, "while")
    NcTokens cond = nc_group(c, "(", ")"), body = nc_group(c, "{", "}")
    while nc_truth(nc_eval(m, cond, env, depth, 1))
      nc_depth(ctx, depth, nc_line(c), "translate-time")
      out = nc_run(m, body, nc_env(ctx, env), depth + 1)
      if out.returning
        < out
      if out.breaking
        < (NcFlow){0}
  else
    char *id = nc_name(c)
    nc_need(c, "in")
    NcTokens input = nc_until(c, "{"), body = nc_group(c, "{", "}")
    NcValue values = nc_eval(m, input, env, depth, 1)
    if values.kind != NC_LIST
      nc_fail(ctx, nc_line(c), "for requires a list")
    for size_t i = (0), nanoc_bound_1 = (values.count); i < nanoc_bound_1; ++i
      NcEnv *scope = nc_env(ctx, env)
      nc_bind(ctx, scope, id, values.items[i])
      out = nc_run(m, body, scope, depth + 1)
      if out.returning
        < out
      if out.breaking
        < (NcFlow){0}
  < (NcFlow){0}
