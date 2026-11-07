@lang 1
+ "test.h"

f whitespace(const char * *s) -> static void
  while (isspace((unsigned char)**s))
    ++*s

f string(const char * *s) -> static bool
  if (*(*s)++ != '"')
    return  0
  while (**s && **s != '"')
    if ((unsigned char)**s < 32)
      return  0
    if (*(*s)++ != '\\')
      continue
    if (**s == 'u')
      ++*s
      for (int i = 0; i < 4; ++i)
        if (!isxdigit((unsigned char)**s))
          return  0
        ++*s
    else
      if (!**s || !strchr("\"\\/bfnrt", **s))
        return  0
      ++*s
  if (**s != '"')
    return  0
  ++*s
  return  1

f value(const char * *s, int depth) -> static bool
  if (depth > 128)
    return  0
  whitespace(s)
  if (**s == '"')
    return  string(s)
  if (**s == '{' || **s == '[')
    bool object = **s == '{'
    char close = object ? '}' : ']'
    ++*s
    whitespace(s)
    if (**s == close)
      ++*s
      return  1
    for (;;)
      if (object)
        whitespace(s)
        if (!string(s))
          return  0
        whitespace(s)
        if (*(*s)++ != ':')
          return  0
      if (!value(s, depth + 1))
        return  0
      whitespace(s)
      if (**s == close)
        ++*s
        return  1
      if (*(*s)++ != ',')
        return  0
  const char *words[] = {"true", "false", "null"}
  for (size_t i = 0; i < 3; ++i)
    if (!strncmp(*s, words[i], strlen(words[i])))
      *s += strlen(words[i])
      return  1
  char *end
  (void)strtod(*s, &end)
  if (end == *s)
    return  0
  *s = end
  return  1

f test_json(const char *source) -> bool
  if (!value(&source, 0))
    return  0
  whitespace(&source)
  return  !*source

