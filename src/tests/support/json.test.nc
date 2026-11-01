@use "test"
@f whitespace(cstr *s) static void
  while isspace((u8)**s)
    ++*s
@f string(cstr *s) static bool
  if *(*s)++ != '"'
    ret false
  while **s && **s != '"'
    if (u8)**s < 32
      ret false
    if *(*s)++ != '\\'
      continue
    if **s == 'u'
      ++*s
      for int i = 0; i < 4; ++i
        if !isxdigit((u8)**s)
          ret false
        ++*s
    else
      if !**s || !strchr("\"\\/bfnrt", **s)
        ret false
      ++*s
  if **s != '"'
    ret false
  ++*s
  ret true
@f value(cstr *s, int depth) static bool
  if depth > 128
    ret false
  whitespace(s)
  if **s == '"'
    ret string(s)
  if **s == '{' || **s == '['
    bool object = **s == '{'
    char close = object ? '}' : ']'
    ++*s
    whitespace(s)
    if **s == close
      ++*s
      ret true
    loop
      if object
        whitespace(s)
        if !string(s)
          ret false
        whitespace(s)
        if *(*s)++ != ':'
          ret false
      if !value(s, depth + 1)
        ret false
      whitespace(s)
      if **s == close
        ++*s
        ret true
      if *(*s)++ != ','
        ret false
  const char *words[] = {"true", "false", "null"}
  for size_t i = 0; i < 3; ++i
    if !strncmp(*s, words[i], strlen(words[i]))
      *s += strlen(words[i])
      ret true
  char *end
  (void)strtod(*s, &end)
  if end == *s
    ret false
  *s = end
  ret true
@f test_json(cstr source) bool
  if !value(&source, 0)
    ret false
  whitespace(&source)
  ret !*source
