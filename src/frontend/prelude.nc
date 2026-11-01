// Project prelude: a `.nanoc` file with `use LIST` lines adds those headers to every module below it.
@use stdio
// Finds the nearest `.nanoc` file at or above the directory of the source file.
@f prelude_file(NcContext *ctx, cstr file) char *
  char *dir = nc_string(ctx, file, strlen(file))
  char *slash = strrchr(dir, '/')
  while slash
    *slash = 0
    char *path = nc_format(ctx, "%s/.nanoc", dir)
    FILE *f = fopen(path, "rb")
    if f then fclose(f); return nc_read(ctx, path)
    slash = strrchr(dir, '/')
  nil
// Returns the include lines the nearest `.nanoc` adds to a module, or an empty string.
@f nc_prelude(NcContext *ctx) char *
  cstr base = ctx->file ? strrchr(ctx->file, '/') : nil
  base = base ? base + 1 : ctx->file
  if not base or strchr(base, '.') != strrchr(base, '.') then return ""
  char *text = prelude_file(ctx, ctx->file)
  NcBuffer out = {0}
  char *rest = text ? text : ""
  while *rest
    char *end = strchr(rest, '\n')
    usize n = end ? (usize)(end - rest) : strlen(rest)
    if n > 4 and !strncmp(rest, "use ", 4)
      NcCursor c = {ctx, nc_lex(ctx, nc_string(ctx, rest + 4, n - 4), 1), 0}
      nc_add(ctx, &out, nc_include(ctx, &c))
    rest += n + (end ? 1 : 0)
  nc_add(ctx, &out, "")
  out.v
