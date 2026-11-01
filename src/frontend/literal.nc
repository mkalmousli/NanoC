// String, char and raw literal scanning.
#include "nanoc/nanoc.h"
// Finds where a literal starts.
@f nc_literal_start(
  const char *s, size_t i, bool cpp
) size_t
  if s[i] == '"' || s[i] == '\''
    return 1
  const char *raw[] = {"R\"", "u8R\"", "uR\"", "UR\"",
    "LR\""}
  const char *normal[] = {"u8\"", "u\"", "U\"", "L\"", "u'",
    "U'", "L'"}
  if cpp
    for size_t n = 0; n < 5; ++n
      if !strncmp(s + i, raw[n], strlen(raw[n]))
        return strlen(raw[n])
  for size_t n = 0; n < 7; ++n
    if !strncmp(s + i, normal[n], strlen(normal[n]))
      return strlen(normal[n])
  0
// Finds where a literal ends.
@f nc_literal_end(
  NcContext *c, const char *s, size_t i, int line
) size_t
  size_t quote = i
  while s[quote] && s[quote] != '"' && s[quote] != '\''
    ++quote
  if quote > i && s[quote - 1] == 'R'
    const char *open = strchr(s + quote + 1, '(')
    if !open || open - s - (ptrdiff_t)quote > 17
      nc_fail(c, line, "invalid raw string")
    char *delimiter = nc_string(c, s + quote + 1,
      (size_t)(open - s) - quote - 1)
    char *closing = nc_format(c, ")%s\"", delimiter)
    const char *end = strstr(open + 1, closing)
    if !end
      nc_fail(c, line, "unterminated raw string")
    return (size_t)(end - s) + strlen(closing)
  size_t end = quote + 1
  while s[end]
    char ch = s[end++]
    if ch == '\\' && s[end]
      ++end
    elif ch == s[quote]
      return end
  nc_fail(c, line, "unterminated literal")
  (size_t){0}
// Finds the end of a line.
@f nc_line_end(const char *s, size_t start) size_t
  size_t i = start
  while s[i]
    if s[i++] != '\n'
      continue
    size_t last = i - 1
    if last && s[last - 1] == '\r'
      --last
    if !last || s[last - 1] != '\\'
      return i
  i
