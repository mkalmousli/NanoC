#include "nanoc/nanoc.h"
#include "nanoc/nanoc.h"
#include "nanoc/nanoc.h"
@f nc_expand(
  NcContext *ctx, NcTokens ts,
  size_t depth
) char *
  nc_depth(ctx, depth,
    ts.n ? ts.v[0].line : 1,
    "expansion")
  nc_names(ctx, ts)
  NcCursor c = {ctx, ts, 0}
  NcBuffer out = {0}
  while c.pos < ts.n
    NcToken t = ts.v[c.pos++]
    if (t.kind != NC_PUNCT
      || !nc_is(t, "@"))
      nc_addn(ctx, &out, t.s,
        t.n)
    else
      nc_step(ctx, t.line)
      char *name = nc_name(
        &c), *generated = ""
      if (ctx->frame_count
        == 256)
        nc_fail(ctx, t.line,
          "expansion depth "
          "limit exceeded")
      char *frame = nc_format(
        ctx,
        "while expanding "
        "@%s at %s:%d", name,
        ctx->file, t.line)
      size_t at = (
        ctx->frame_count++)
      ctx->frames[at] = frame
      if (!strcmp(name,
          "macro")
        || !strcmp(name, "m"))
        nc_define_macro(ctx,
          &c)
      elif !strcmp(name, "ct")
        generated = (
          nc_compile_time(ctx,
            nc_meta_body(&c,
              nc_header(&c),
              true, false),
            depth + 1))
      elif !strcmp(name, "bt")
        generated = (
          nc_program(ctx,
            nc_meta_body(&c,
              nc_header(&c),
              true, false),
            NULL, NC_BT,
            depth + 1))
      elif !strcmp(name, "f")
        generated = (
          nc_native_function(
            ctx, &c,
            depth + 1))
      elif !strcmp(name,
        "asm")
        generated = (
          nc_assembly(ctx,
            &c))
      elif (!strcmp(name,
          "fn")
        || !strcmp(name,
          "let")
        || !strcmp(name,
          "for"))
        generated = (
          nc_shorthand(ctx,
            &c, name,
            depth + 1))
      else
        generated = (
          nc_invoke_macro(ctx,
            &c, name,
            depth + 1))
      --ctx->frame_count
      nc_marker(ctx, &out,
        t.line)
      nc_add(ctx, &out,
        generated)
      nc_marker(ctx, &out,
        nc_line(&c))
    nc_check(ctx, out.n,
      t.line)
  nc_add(ctx, &out, "")
  out.v
@f nc_transpile(
  NcContext *ctx,
  const char *input
) char *
  nc_check(ctx, strlen(input),
    1)
  if !strchr(input, '@')
    ctx->pass = 1
    ctx->source = input
    return (char *)input
  nc_pipeline(ctx, input)
