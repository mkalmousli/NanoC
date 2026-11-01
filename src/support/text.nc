#include "nanoc/nanoc.h"
@f nc_trim(
  NcContext *c, const char *s
) char *
  while isspace(
    (unsigned char)*s)
    ++s
  size_t n = strlen(s)
  while (n
    && isspace(
      (unsigned char)s[
        n - 1]))
    --n
  nc_string(c, s, n)
@f nc_identifier(
  const char *s
) bool
  if (!isalpha(
      (unsigned char)*s)
    && *s != '_')
    return false
  for ++s; *s; ++s
    if (!isalnum(
        (unsigned char)*s)
      && *s != '_')
      return false
  true
@f nc_quote(
  NcContext *c, const char *s
) char *
  NcBuffer b = {0}
  nc_add(c, &b, "\"")
  for ; *s; ++s
    unsigned char ch = ((
        unsigned char)*s)
    if ch == '\\' || ch == '"'
      nc_printf(c, &b, "\\%c",
        ch)
    elif ch == '\n'
      nc_add(c, &b, "\\n")
    elif ch == '\r'
      nc_add(c, &b, "\\r")
    elif ch == '\t'
      nc_add(c, &b, "\\t")
    elif ch < 32 || ch >= 127
      nc_printf(c, &b,
        "\\%03o", ch)
    else
      nc_addn(c, &b, s, 1)
  nc_add(c, &b, "\"")
  b.v
@f nc_unquote(
  NcContext *c, const char *s,
  int line
) char *
  NcBuffer b = {0}
  size_t len = strlen(s)
  for (size_t i = 1;
    i + 1 < len; ++i)
    char ch = s[i]
    if ch == '\\'
      if ++i + 1 >= len
        nc_fail(c, line,
          "incomplete "
          "string escape")
      ch = s[i]
      if ch == 'n'
        ch = '\n'
      elif ch == 'r'
        ch = '\r'
      elif ch == 't'
        ch = '\t'
      elif (ch != '\\'
        && ch != '"')
        nc_fail(c, line,
          "unsupported "
          "compile-time "
          "string escape")
    nc_addn(c, &b, &ch, 1)
  nc_add(c, &b, "")
  b.v
