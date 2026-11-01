// The @inc shorthand for #include.
#include "nanoc/nanoc.h"
// Turns one @inc item into an #include line.
@f include_line(NcContext *ctx, const char *item) static char *
  size_t n = strlen(item)
  if item[0] == '"' || item[0] == '<'
    return nc_format(ctx, "#include %s\n", item)
  const char *ext = n > 2 && !strcmp(item + n - 2, ".h") ? "" : ".h"
  nc_format(ctx, "#include <%s%s>\n", item, ext)
// Expands "@inc a, b" to one #include per name.
@f nc_include(NcContext *ctx, NcCursor *c) char *
  NcGroups items = nc_split(ctx, nc_line_expression(c), ",")
  NcBuffer out = {0}
  for size_t i = 0; i < items.n; ++i
    char *item = nc_trim(ctx, nc_join(ctx, items.v[i]))
    if !*item
      nc_fail(ctx, nc_line(c), "@inc needs a header name")
    nc_add(ctx, &out, include_line(ctx, item))
  nc_add(ctx, &out, "")
  out.v
