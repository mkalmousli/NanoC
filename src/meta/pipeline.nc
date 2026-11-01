// The full compile pipeline.
// Runs the whole compile pipeline.
@f nc_pipeline(NcContext *ctx, cstr input) char *
  cstr current = input
  for ;;
    if ctx->max_passes and ctx->pass >= ctx->max_passes then nc_fail(ctx, 1, "pass limit exceeded")
    if ctx->pass == SIZE_MAX then nc_fail(ctx, 1, "pass counter limit exceeded")
    ++ctx->pass
    ctx->again = false
    ctx->next_source = nil
    ctx->macros = (NcMap){0}
    ctx->symbols = (NcSymbols){0}
    cstr prepared = nc_build_stage(ctx, current)
    ctx->source = prepared
    char *output = nc_expand(ctx, nc_lex(ctx, prepared, 1), 0)
    if !ctx->again and !ctx->next_source then return output
    current = ctx->next_source ? ctx->next_source : prepared
    nc_check(ctx, strlen(current), 1)
  nil
