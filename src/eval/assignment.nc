// Assignment statements in the evaluator.
@lang 1
+ "nanoc/nanoc.h"

// Runs name = expr when present.
f nc_assignment(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth, NcToken name) bool
  if name.kind != NC_WORD
    < 0
  size_t saved = c->pos
  if nc_end(c)
    c->pos = saved
    < 0
  NcToken op = c->ts.v[c->pos]
  bool bind = nc_is(op, ":="), assign = nc_is(op, "=")
  bool step = nc_is(op, "++") || nc_is(op, "--")
  bool augment = op.n == 2 && op.s[1] == '=' && strchr("+-*/%", op.s[0])
  if !bind && !assign && !step && !augment
    c->pos = saved
    < 0
  (void)nc_take(c)
  NcContext *ctx = m->ctx
  char *id = nc_text(ctx, name)
  NcValue value = step ? nc_integer(1) : nc_eval(m, nc_until(c, ";"), env, depth, 1)
  if step || augment
    NcToken binary = nc_token(nc_string(ctx, op.s, 1), op.line, NC_PUNCT)
    value = nc_binary(ctx, binary, nc_lookup(ctx, env, id, name.line), value, name.line)
  if bind
    if nc_get(&env->values, id)
      nc_fail(ctx, name.line, "duplicate translate-time variable: %s", id)
    nc_bind(ctx, env, id, value)
  else
    nc_assign(ctx, env, id, value, name.line)
  < 1
