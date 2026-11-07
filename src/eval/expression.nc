// Expression parsing and evaluation.
@lang 1
+ "nanoc/nanoc.h"

// Parses with operator precedence.
f nc_expression(NcExpr *e, int minimum, bool active) NcValue
  ++e->depth
  NcContext *c = e->m->ctx
  nc_depth(c, e->depth, nc_line(&e->c), "translate-time")
  NcValue out = nc_integer(0)
  if nc_at(&e->c, "!") || nc_at(&e->c, "-") || nc_at(&e->c, "+")
    NcToken op = nc_take(&e->c)
    bool min_literal = nc_is(op, "-") && nc_at(&e->c, "9223372036854775808")
    NcValue a
    if min_literal
      (void)nc_take(&e->c)
      a = nc_integer(INT64_MIN)
    else
      a = nc_expression(e, 7, active)
    if active
      if nc_is(op, "!")
        out = nc_boolean(!nc_truth(a))
      else
        int64_t n = nc_numeric(c, a, nc_line(&e->c))
        if nc_is(op, "-") && !min_literal
          n = nc_arithmetic(c, "-", 0, n, op.line)
        out = nc_integer(n)
  else
    out = nc_primary(e, active)
  while !nc_end(&e->c)
    NcToken op = e->c.ts.v[e->c.pos]
    int precedence = nc_precedence(op)
    if precedence < minimum
      !
    (void)nc_take(&e->c)
    bool execute = (active && !((nc_is(op, "&&") && !nc_truth(out)) || (nc_is(op, "||") && nc_truth(out))))
    NcValue rhs = nc_expression(e, precedence + 1, execute)
    if active
      out = execute ? nc_binary(c, op, out, rhs, op.line) : nc_boolean(nc_is(op, "||"))
  if active && out.kind == NC_LIST
    if out.height > c->max_depth
      nc_fail(c, nc_line(&e->c), "value depth limit exceeded")
    nc_check(c, out.count * 8, nc_line(&e->c))
  --e->depth
  < out

// Evaluates an expression.
f nc_eval(NcMachine *m, NcTokens ts, NcEnv *env, size_t depth, bool active) NcValue
  nc_depth(m->ctx, depth, ts.n ? ts.v[0].line : 1, "translate-time")
  NcExpr e = {{m->ctx, ts, 0}, m, env, depth}
  NcValue out = nc_expression(&e, 0, active)
  if !nc_end(&e.c)
    nc_fail(m->ctx, nc_line(&e.c), "unexpected expression token")
  < out
