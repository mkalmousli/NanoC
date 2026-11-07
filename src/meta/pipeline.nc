// The full compile pipeline.
@lang 1
+ "nanoc/nanoc.h"

// Runs the whole compile pipeline.
f nc_pipeline(NcContext *ctx, const char *input) char *
  const char * current = input
  for ;;
    if ctx->max_passes && ctx->pass >= ctx->max_passes
      nc_fail(ctx, 1, "pass limit exceeded")
    if ctx->pass == SIZE_MAX
      nc_fail(ctx, 1, "pass counter limit exceeded")
    ++ctx->pass
    ctx->again = 0
    ctx->next_source = NULL
    ctx->macros = (NcMap){0}
    ctx->symbols = (NcSymbols){0}
    const char * prepared = current
    ctx->source = prepared
    if ctx->tracing
      NC_PUSH(ctx, ctx->trace_sources, (char *)prepared)
    char *output = nc_expand(ctx, nc_lex(ctx, prepared, 1), 0)
    if !ctx->again && !ctx->next_source
      < output
    current = ctx->next_source ? ctx->next_source : prepared
    nc_check(ctx, strlen(current), 1)
  < NULL
