// Turns source text into tokens.
// Splits text into tokens.
@f nc_lex(NcContext *c, cstr s, int line) NcTokens
  NcTokens out = {0}
  usize i = 0
  int column = 1
  bool bol = true
  while s[i]
    usize start = i
    NcToken t = {s + i, 0, line, column, NC_PUNCT}
    u8 ch = (u8)s[i]
    if isspace(ch)
      t.kind = NC_SPACE
      while s[i] and isspace((u8)s[i])
        ++i
    elif !strncmp(s + i, "//", 2)
      t.kind = NC_SPACE
      i = nc_line_end(s, i)
    elif !strncmp(s + i, "/*", 2)
      t.kind = NC_SPACE
      const char *end = strstr(s + i + 2, "*/")
      if not end then nc_fail(c, line, "unterminated comment")
      i = (usize)(end - s) + 2
    elif ch == '#' && bol then t.kind = NC_DIRECTIVE; i = nc_line_end(s, i)
    elif nc_literal_start(s, i, c->cpp) then t.kind = NC_LITERAL; i = nc_literal_end(c, s, i, line)
    elif isalpha(ch) || ch == '_' || ch >= 128
      t.kind = NC_WORD
      while 1
        ++i
        if !(isalnum((unsigned char)s[i]) || s[i] == '_' || (unsigned char)s[i] >= 128) then break
    elif isdigit(ch) || (ch == '.' && isdigit((unsigned char)s[i + 1]))
      t.kind = NC_NUMBER
      ++i
      while s[i]
        if isalnum((unsigned char)s[i]) || s[i] == '_' || (s[i] == '.' && strncmp(s + i, "..", 2))
          ++i
        elif (s[i] == '+' || s[i] == '-') && strchr("eEpP", s[i - 1])
          ++i
        else break
    else
      const char *ops[] = {"...", "..", "->", "==", "!=", "<=", ">=", "&&", "||", "=>", ":=", "++",
        "--", "+=", "-=", "*=", "/=", "%="}
      ++i
      for size_t n = 0; n < sizeof ops / sizeof *ops; ++n
        if !strncmp(s + start, ops[n], strlen(ops[n])) then i = start + strlen(ops[n]); break
    t.n = i - start
    bool newline = false
    for n:usize in start..i
      if s[n] == '\n' then ++line; column = 1; newline = true
      else
        ++column
    if t.kind == NC_SPACE
      if newline then bol = true
    else bol = t.kind == NC_DIRECTIVE && s[i - 1] == '\n'
    NC_PUSH(c, out, t)
  out
