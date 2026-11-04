// Language versioning: the "@lang N" declaration and source migration.
typedef char *(*NcStep)(NcContext *, const char *);
// Migration steps: steps[v] rewrites language v source to v+1 (nil means no textual change).
static const NcStep steps[NC_LANG + 1] = {0};
@s NcLang start,end:usize; version:int
// Finds a leading "@lang N" line after blank lines and // comments; version 0 means none.
@f find(NcContext *ctx, cstr s) static NcLang
  NcLang r = {0}
  usize i = 0
  while s[i]
    if isspace((unsigned char)s[i])
      i++
    elif s[i] == '/' && s[i + 1] == '/'
      while s[i] && s[i] != '\n'
        i++
    else
      break
  if strncmp(s + i, "@lang", 5) || (s[i + 5] != ' ' && s[i + 5] != '\t') then return r
  usize j = i + 5
  while s[j] == ' ' || s[j] == '\t'
    j++
  if not isdigit((unsigned char)s[j]) then nc_fail(ctx, 0, "@lang needs a positive integer version")
  long n = 0
  while isdigit((unsigned char)s[j])
    n = n * 10 + (s[j++] - '0')
    if n > 1000000 then nc_fail(ctx, 0, "@lang version is too large")
  while s[j] == ' ' || s[j] == '\t'
    j++
  if s[j] && s[j] != '\n' && s[j] != '\r' && !(s[j] == '/' && s[j + 1] == '/')
    nc_fail(ctx, 0, "@lang takes only a version number")
  if not n then nc_fail(ctx, 0, "@lang needs a positive integer version")
  r.start = i
  r.end = j
  r.version = (int)n
  r
// Rejects source written for a newer language and blanks the declaration (line numbers stay).
@f nc_lang_check(NcContext *ctx, cstr input) char *
  NcLang l = find(ctx, input)
  if not l.version then return (char *)input
  if l.version > NC_LANG
    nc_fail(ctx, 0, "source needs language %d but this nanoc speaks %d; update nanoc", l.version, NC_LANG)
  if l.version < NC_LANG
    nc_fail(ctx, 0, "source is language %d, this nanoc speaks %d; run: nanoc --migrate FILE -o FILE", l.version, NC_LANG)
  nc_format(ctx, "%.*s%s", (int)l.start, input, input + l.end)
// Rewrites source from its declared language (default 1) to the current one and stamps "@lang".
@f nc_migrate(NcContext *ctx, cstr input) char *
  NcLang l = find(ctx, input)
  if l.version > NC_LANG
    nc_fail(ctx, 0, "source needs language %d but this nanoc speaks %d; update nanoc", l.version, NC_LANG)
  char *text = (char *)input
  for int v = l.version ? l.version : 1; v < NC_LANG; ++v
    if steps[v] then text = steps[v](ctx, text)
  l = find(ctx, text)
  if not l.version then return nc_format(ctx, "@lang %d\n%s", NC_LANG, text)
  nc_format(ctx, "%.*s@lang %d%s", (int)l.start, text, NC_LANG, text + l.end)
