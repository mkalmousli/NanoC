#include "nanoc/nanoc.h"
@f nc_lex(NcContext *c, const char *s, int line) NcTokens
  NcTokens out = {0}
  size_t i = 0
  int column = 1
  bool bol = true
  while s[i]
    size_t start = i
    NcToken t = {s + i, 0, line, column, NC_PUNCT}
    unsigned char ch = (unsigned char)s[i]
    if isspace(ch)
      t.kind = NC_SPACE
      while s[i] && isspace((unsigned char)s[i])
        ++i
    else
      if !strncmp(s + i, "//", 2)
        t.kind = NC_SPACE
        i = nc_line_end(s, i)
      else
        if !strncmp(s + i, "/*", 2)
          t.kind = NC_SPACE
          const char *end = strstr(s + i + 2, "*/")
          if !end
            nc_fail(c, line, "unterminated comment")
          i = (size_t)(end - s) + 2
        else
          if ch == '#' && bol
            t.kind = NC_DIRECTIVE
            i = nc_line_end(s, i)
          else
            if nc_literal_start(s, i, c->cpp)
              t.kind = NC_LITERAL
              i = nc_literal_end(c, s, i, line)
            else
              if isalpha(ch) || ch == '_' || ch >= 128
                t.kind = NC_WORD
                while 1
                  ++i
                  if !(isalnum((unsigned char)s[i]) || s[i] == '_' || (unsigned char)s[i] >= 128)
                    break
              else
                if isdigit(ch) || (ch == '.' && isdigit((unsigned char)s[i + 1]))
                  t.kind = NC_NUMBER
                  ++i
                  while s[i]
                    if isalnum((unsigned char)s[i]) || s[i] == '_' || (s[i] == '.' && strncmp(s + i, "..", 2))
                      ++i
                    else
                      if (s[i] == '+' || s[i] == '-') && strchr("eEpP", s[i - 1])
                        ++i
                      else
                        break
                else
                  const char *ops[] = {"...", "..", "->", "==", "!=", "<=", ">=", "&&", "||", "=>", ":=", "++", "--", "+=", "-=", "*=", "/=", "%="}
                  ++i
                  for size_t n = 0; n < sizeof ops / sizeof *ops; ++n
                    if !strncmp(s + start, ops[n], strlen(ops[n]))
                      i = start + strlen(ops[n])
                      break
    t.n = i - start
    bool newline = false
    for size_t n = start; n < i; ++n
      if s[n] == '\n'
        ++line
        column = 1
        newline = true
      else
        ++column
    if t.kind == NC_SPACE
      if newline
        bol = true
    else
      bol = t.kind == NC_DIRECTIVE && s[i - 1] == '\n'
    NC_PUSH(c, out, t)
  out
