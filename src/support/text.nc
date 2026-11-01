// Trim, quote and identifier helpers.
@use "nanoc/nanoc"
// Trims whitespace.
@f nc_trim(NcContext *c, cstr s) char *
  while isspace((u8)*s)
    ++s
  usize n = strlen(s)
  while n and isspace((u8)s[n - 1]) then --n
  nc_string(c, s, n)
// Tells if text is an identifier.
@f nc_identifier(cstr s) bool
  if !isalpha((unsigned char)*s) && *s != '_' then return false
  for ++s; *s; ++s
    if !isalnum((unsigned char)*s) && *s != '_' then return false
  true
// Quotes text as a C string.
@f nc_quote(NcContext *c, cstr s) char *
  NcBuffer b = {0}
  nc_add(c, &b, "\"")
  for ; *s; ++s
    u8 ch = (u8)*s
    if ch == '\\' || ch == '"' then nc_printf(c, &b, "\\%c", ch)
    elif ch == '\n' then nc_add(c, &b, "\\n")
    elif ch == '\r' then nc_add(c, &b, "\\r")
    elif ch == '\t' then nc_add(c, &b, "\\t")
    elif ch < 32 or ch >= 127 then nc_printf(c, &b, "\\%03o", ch)
    else nc_addn(c, &b, s, 1)
  nc_add(c, &b, "\"")
  b.v
// Removes quotes from a literal.
@f nc_unquote(NcContext *c, cstr s, int line) char *
  NcBuffer b = {0}
  usize len = strlen(s)
  for usize i = 1; i + 1 < len; ++i
    char ch = s[i]
    if ch == '\\'
      if ++i + 1 >= len then nc_fail(c, line, "incomplete string escape")
      ch = s[i]
      if ch == 'n' then ch = '\n'
      elif ch == 'r' then ch = '\r'
      elif ch == 't' then ch = '\t'
      elif ch != '\\' && ch != '"' then nc_fail(c, line, "unsupported compile-time string escape")
    nc_addn(c, &b, &ch, 1)
  nc_add(c, &b, "")
  b.v
