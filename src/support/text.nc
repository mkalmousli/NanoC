// Trim, quote and identifier helpers.
@lang 1
+ "nanoc/nanoc.h"

// Trims whitespace.
f nc_trim(NcContext *c, const char *s) -> char *
  while (isspace((unsigned char)*s))
    ++s
  size_t n = strlen(s)
  while (n && isspace((unsigned char)s[n - 1]))
    --n
  return nc_string(c, s, n)

// Tells if text is an identifier.
f nc_identifier(const char *s) -> bool
  if (!isalpha((unsigned char)*s) && *s != '_')
    return 0
  for (++s; *s; ++s)
    if (!isalnum((unsigned char)*s) && *s != '_')
      return 0
  return 1

// Quotes text as a C string.
f nc_quote(NcContext *c, const char *s) -> char *
  NcBuffer b = {0}
  nc_add(c, &b, "\"")
  for (; *s; ++s)
    unsigned char ch = (unsigned char)*s
    if (ch == '\\' || ch == '"')
      nc_printf(c, &b, "\\%c", ch)
    elif (ch == '\n')
      nc_add(c, &b, "\\n")
    elif (ch == '\r')
      nc_add(c, &b, "\\r")
    elif (ch == '\t')
      nc_add(c, &b, "\\t")
    elif (ch < 32 || ch >= 127)
      nc_printf(c, &b, "\\%03o", ch)
    else
      nc_addn(c, &b, s, 1)
  nc_add(c, &b, "\"")
  return b.v

// Removes quotes from a literal.
f nc_unquote(NcContext *c, const char *s, int line) -> char *
  NcBuffer b = {0}
  size_t len = strlen(s)
  for (size_t i = 1; i + 1 < len; ++i)
    char ch = s[i]
    if (ch == '\\')
      if (++i + 1 >= len)
        nc_fail(c, line, "incomplete string escape")
      ch = s[i]
      if (ch == 'n')
        ch = '\n'
      elif (ch == 'r')
        ch = '\r'
      elif (ch == 't')
        ch = '\t'
      elif (ch >= '0' && ch <= '7')
        int value = ch - '0'
        for (int n = 1; n < 3 && i + 1 < len && s[i + 1] >= '0' && s[i + 1] <= '7'; ++n)
          value = value * 8 + s[++i] - '0'
        ch = (char)value
      elif (ch != '\\' && ch != '"')
        nc_fail(c, line, "unsupported compile-time string escape")
    nc_addn(c, &b, &ch, 1)
  nc_add(c, &b, "")
  return b.v
