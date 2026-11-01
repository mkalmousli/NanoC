// The @use (alias @inc) shorthand for #include.
@use "nanoc/nanoc"
// Bundles that expand to several headers.
@f bundle(cstr item) static cstr 
  const char *names[][2] = {{"std", "stdio,stdlib,string"}, {"libc", "stdio,stdlib,string,stdbool,stdint,stddef,ctype"},
    {"posix", "unistd,fcntl,sys/stat,sys/types"}, {"cxx", "iostream,string,vector,map,algorithm,memory"}}
  for usize i = 0; i < sizeof names / sizeof *names; ++i
    if !strcmp(item, names[i][0])
      return names[i][1]
  nil
// Turns one @use item into an #include line: names get .h in C and none in C++ standard headers.
@f include_line(NcContext *ctx, cstr item) static char *
  usize n = strlen(item)
  if item[0] == '<'
    return nc_format(ctx, "#include %s\n", item)
  if item[0] == '"'
    bool dotted = n > 3 && strchr(item, '.') != nil
    return nc_format(ctx, "#include %.*s%s\"\n", (int)(n - 1), item, dotted ? "" : ".h")
  const char *cxx[] = {"iostream", "string", "vector", "map", "set", "algorithm", "memory", "array", "cstdio", "cstdlib", "cmath",
    "functional", "optional", "utility", "unordered_map", "unordered_set", "sstream", "fstream", "thread", "mutex"}
  for usize i = 0; i < sizeof cxx / sizeof *cxx; ++i
    if ctx->cpp and !strcmp(item, cxx[i])
      return nc_format(ctx, "#include <%s>\n", item)
  const char *ext = n > 2 && !strcmp(item + n - 2, ".h") ? "" : ".h"
  nc_format(ctx, "#include <%s%s>\n", item, ext)
// Expands "@use a, b" to one #include per name; bundles such as std expand to several.
@f nc_include(NcContext *ctx, NcCursor *c) char *
  NcGroups items = nc_split(ctx, nc_line_expression(c), ",")
  NcBuffer out = {0}
  for i:usize in 0..items.n
    char *item = nc_trim(ctx, nc_join(ctx, items.v[i]))
    if !*item
      nc_fail(ctx, nc_line(c), "@use needs a header name")
    cstr many = bundle(item)
    if many
      NcGroups parts = nc_split(ctx, nc_lex(ctx, many, nc_line(c)), ",")
      for k:usize in 0..parts.n
        nc_add(ctx, &out, include_line(ctx, nc_trim(ctx, nc_join(ctx, parts.v[k]))))
    else
      nc_add(ctx, &out, include_line(ctx, item))
  nc_add(ctx, &out, "")
  out.v
