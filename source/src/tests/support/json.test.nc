@lang 1
+ "test.h"

f whitespace(const char * *s) static void
  while isspace((unsigned char)**s)
    ++*s

f string(const char * *s) static bool
  if *(*s)++ != '"'
    <  0
  while **s && **s != '"'
    if (unsigned char)**s < 32
      <  0
    if *(*s)++ != '\\'
      ^
    if **s == 'u'
      ++*s
      for int i = 0; i < 4; ++i
        if !isxdigit((unsigned char)**s)
          <  0
        ++*s
    else
      if !**s || !strchr("\"\\/bfnrt", **s)
        <  0
      ++*s
  if **s != '"'
    <  0
  ++*s
  <  1

f value(const char * *s, int depth) static bool
  if depth > 128
    <  0
  whitespace(s)
  if **s == '"'
    <  string(s)
  if **s == '{' || **s == '['
    bool object = **s == '{'
    char close = object ? '}' : ']'
    ++*s
    whitespace(s)
    if **s == close
      ++*s
      <  1
    for ;;
      if object
        whitespace(s)
        if !string(s)
          <  0
        whitespace(s)
        if *(*s)++ != ':'
          <  0
      if !value(s, depth + 1)
        <  0
      whitespace(s)
      if **s == close
        ++*s
        <  1
      if *(*s)++ != ','
        <  0
  const char *words[] = {"true", "false", "null"}
  for size_t i = 0; i < 3; ++i
    if !strncmp(*s, words[i], strlen(words[i]))
      *s += strlen(words[i])
      <  1
  char *end
  (void)strtod(*s, &end)
  if end == *s
    <  0
  *s = end
  <  1

f test_json(const char *source) bool
  if !value(&source, 0)
    <  0
  whitespace(&source)
  <  !*source

