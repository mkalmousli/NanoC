// Macro bodies written as programs.
// Runs a program-style macro.
@f nc_macro_program(NcContext *ctx, NcMacro *macro, NcBindings *b, usize depth) char *
  NcEnv *env = nc_env(ctx, nil)
  for i:usize in 0..macro->params.n
    NcParam p = macro->params.v[i]
    NcGroups *values = nc_get(&b->values, p.name)
    NcValue value
    if p.variadic
      NcValues items = {0}
      for j:usize in 0..values->n then NC_PUSH(ctx, items, nc_value_text(NC_CODE, nc_join(ctx, values->v[j])))
      value = nc_list(items)
    else value = nc_value_text(NC_CODE, nc_join(ctx, values->v[0]))
    nc_bind(ctx, env, p.name, value)
  nc_program(ctx, macro->body, env, NC_MACRO, depth)
