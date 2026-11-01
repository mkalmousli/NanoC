// Substitutes macro arguments.
@use "nanoc/nanoc"
// Substitutes macro parameters.
@f nc_substitute(NcContext *ctx, NcTokens ts, NcBindings *b, usize depth, usize index) char *
  nc_depth(ctx, depth, 1, "substitution")
  NcCursor c = {ctx, ts, 0}
  NcBuffer out = {0}
  while c.pos < ts.n
    NcToken t = ts.v[c.pos++]
    nc_step(ctx, t.line)
    if t.kind != NC_PUNCT || !nc_is(t, "$") then nc_addn(ctx, &out, t.s, t.n)
    elif nc_eat(&c, "$") then nc_add(ctx, &out, "$")
    elif nc_at(&c, "(")
      NcTokens body = nc_group(&c, "(", ")")
      char *separator = ""
      if !nc_at(&c, "*") then separator = nc_text(ctx, nc_take(&c))
      nc_need(&c, "*")
      if not b->variadic then nc_fail(ctx, t.line, "repetition requires a variadic parameter")
      if index != SIZE_MAX then nc_fail(ctx, t.line, "nested repetitions are not supported")
      NcGroups *values = nc_get(&b->values, b->variadic)
      for i:usize in 0..values->n
        if i then nc_add(ctx, &out, separator)
        nc_add(ctx, &out, nc_substitute(ctx, body, b, depth + 1, i))
        nc_check(ctx, out.n, t.line)
    else
      char *name = nc_name(&c)
      if !strcmp(name, "fresh")
        NcCursor h = {ctx, nc_group(&c, "(", ")"), 0}
        char *id = nc_name(&h)
        if !nc_end(&h) then nc_fail(ctx, t.line, "fresh requires one identifier")
        char *fresh = nc_get(&b->fresh, id)
        if not fresh
          fresh = nc_fresh(ctx, id)
          nc_put(ctx, &b->fresh, id, fresh)
        nc_add(ctx, &out, fresh)
      else
        NcGroups *values = nc_get(&b->values, name)
        if not values then nc_fail(ctx, t.line, "unknown macro capture: $%s", name)
        usize n = b->variadic and !strcmp(name, b->variadic) ? index : 0
        if n == SIZE_MAX then nc_fail(ctx, t.line, "variadic capture requires repetition")
        if n >= values->n then nc_fail(ctx, t.line, "missing macro capture")
        nc_add(ctx, &out, nc_join(ctx, values->v[n]))
    nc_check(ctx, out.n, t.line)
  nc_add(ctx, &out, "")
  out.v
