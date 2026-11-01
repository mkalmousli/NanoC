// String, char and raw literal scanning.
// Finds where a literal starts.
@f nc_literal_start(cstr s, usize i, bool cpp) usize
  if s[i] == '"' || s[i] == '\'' then return 1
  const char *raw[] = {"R\"", "u8R\"", "uR\"", "UR\"", "LR\""}
  const char *normal[] = {"u8\"", "u\"", "U\"", "L\"", "u'", "U'", "L'"}
  if cpp
    for n:usize in 0..5
      if !strncmp(s + i, raw[n], strlen(raw[n])) then return strlen(raw[n])
  for n:usize in 0..7
    if !strncmp(s + i, normal[n], strlen(normal[n])) then return strlen(normal[n])
  0
// Finds where a literal ends.
@f nc_literal_end(NcContext *c, cstr s, usize i, int line) usize
  usize quote = i
  while s[quote] && s[quote] != '"' && s[quote] != '\''
    ++quote
  if quote > i && s[quote - 1] == 'R'
    const char *open = strchr(s + quote + 1, '(')
    if !open or open - s - (ptrdiff_t)quote > 17 then nc_fail(c, line, "invalid raw string")
    char *delimiter = nc_string(c, s + quote + 1, (usize)(open - s) - quote - 1)
    char *closing = nc_format(c, ")%s\"", delimiter)
    cstr end = strstr(open + 1, closing)
    if not end then nc_fail(c, line, "unterminated raw string")
    return (usize)(end - s) + strlen(closing)
  usize end = quote + 1
  while s[end]
    char ch = s[end++]
    if ch == '\\' && s[end]
      ++end
    elif ch == s[quote] then return end
  nc_fail(c, line, "unterminated literal")
  (usize){0}
// Finds the end of a line.
@f nc_line_end(cstr s, usize start) usize
  usize i = start
  while s[i]
    if s[i++] != '\n' then continue
    usize last = i - 1
    if last && s[last - 1] == '\r' then --last
    if !last || s[last - 1] != '\\' then return i
  i
