// Trim, quote and identifier helpers.
@use "nanoc/nanoc"
// Trims whitespace.
@f nc_trim(NcContext *c, cstr s) char *
  while isspace((u8)*s)
    ++s
  usize n = strlen(s)
  while n and isspace((u8)s[n - 1])
    --n
  nc_string(c, s, n)
// Tells if text is an identifier.
@f nc_identifier(cstr s) bool
  if !isalpha((unsigned char)*s) && *s != '_'
    return false
  for ++s; *s; ++s
    if !isalnum((unsigned char)*s) && *s != '_'
      return false
  true
// Quotes text as a C string.
@f nc_quote(NcContext *c, cstr s) char *
  NcBuffer b = {0}
  nc_add(c, &b, "\"")
  for ; *s; ++s
    u8 ch = (u8)*s
    if ch == '\\' || ch == '"'
      nc_printf(c, &b, "\\%c", ch)
    elif ch == '\n'
      nc_add(c, &b, "\\n")
    elif ch == '\r'
      nc_add(c, &b, "\\r")
    elif ch == '\t'
      nc_add(c, &b, "\\t")
    elif ch < 32 or ch >= 127
      nc_printf(c, &b, "\\%03o", ch)
    else
      nc_addn(c, &b, s, 1)
  nc_add(c, &b, "\"")
  b.v
// Removes quotes from a literal.
@f nc_unquote(NcContext *c, cstr s, int line) char *
  NcBuffer b = {0}
  usize len = strlen(s)
  for usize i = 1; i + 1 < len; ++i
    char ch = s[i]
    if ch == '\\'
      if ++i + 1 >= len
        nc_fail(c, line, "incomplete string escape")
      ch = s[i]
      if ch == 'n'
        ch = '\n'
      elif ch == 'r'
        ch = '\r'
      elif ch == 't'
        ch = '\t'
      elif ch != '\\' && ch != '"'
        nc_fail(c, line, "unsupported compile-time string escape")
    nc_addn(c, &b, &ch, 1)
  nc_add(c, &b, "")
  b.v
