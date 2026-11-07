// NanoC v1 indentation headers; source blocks do not use colon or then aliases.
@lang 1
+ "nanoc/nanoc.h"

// Identifies a source transformation or raw C directive at a statement boundary.
f nc_meta_line(NcLayoutLine line) bool
  NcTokens tokens = line.ts
  size_t i = 0
  while i < tokens.n && tokens.v[i].kind == NC_SPACE
    ++i
  if i == tokens.n || !nc_is(tokens.v[i++], "@")
    < 0
  while i < tokens.n && tokens.v[i].kind == NC_SPACE
    ++i
  < i < tokens.n && (nc_is(tokens.v[i], "m") || nc_is(tokens.v[i], "tt") || nc_is(tokens.v[i], "c"))

// Prepares internal tree delimiters while retaining original source spans.
f nc_prepare_lines(NcContext *ctx, NcLines input, bool program) NcLines
  NcLines out = {0}
  for size_t i = 0; i < input.n; ++i
    NcLayoutLine line = input.v[i]
    bool block = i + 1 < input.n && input.v[i + 1].indent > line.indent
    bool extension = 0
    NcTokens significant = nc_significant(ctx, line.ts)
    if significant.n > 1
      extension = block && nc_is(significant.v[0], "@") && significant.v[1].kind == NC_WORD
    if !program && (line.raw || nc_meta_line(line) || extension)
      NcBuffer raw = {0}
      char *text = nc_join(ctx, line.ts)
      nc_printf(ctx, &raw, "%s\n", text)
      int next_line = line.line + 1
      for const char *p = text; *p; ++p
        if *p == '\n'
          ++next_line
      while i + 1 < input.n && input.v[i + 1].indent > line.indent
        NcLayoutLine child = input.v[++i]
        while next_line < child.line
          nc_add(ctx, &raw, "\n")
          ++next_line
        text = nc_join(ctx, child.ts)
        nc_printf(ctx, &raw, "%*s%s\n", child.indent - line.indent, "", text)
        next_line = child.line + 1
        for const char *p = text; *p; ++p
          if *p == '\n'
            ++next_line
      line.ts = nc_lex(ctx, raw.v, line.line)
      line.raw = 1
      NC_PUSH(ctx, out, line)
      ^
    NcTokens ts = nc_significant(ctx, line.ts)
    if !ts.n
      ^
    NcToken first = ts.v[0], last = ts.v[ts.n - 1]
    if !program && nc_is(first, "asm")
      nc_fail(ctx, line.line, "NanoC asm was removed; use @c for compiler-specific C")
    int pp = program ? 0 : nc_pp_kind(ts)
    bool control = nc_is(first, "if") || nc_is(first, "elif") || nc_is(first, "else") || nc_is(first, "while") || nc_is(first, "for")
    if control && ts.n > 1 && nc_is(ts.v[1], "(")
      NcCursor wrapped = {ctx, ts, 1}
      (void)nc_group(&wrapped, "(", ")")
      if nc_end(&wrapped)
        nc_fail(ctx, line.line, "v1 control headers omit outer parentheses")
    bool function = program && nc_is(first, "f") && ts.n > 1 && ts.v[1].kind == NC_WORD
    bool expression = 0
    if function
      for size_t j = 0; j < ts.n; ++j
        if nc_is(ts.v[j], "=")
          expression = 1
    if !program && control && nc_is(last, ":")
      nc_fail(ctx, line.line, "v1 blocks use indentation; omit ':'")
    if pp == 5
      line.ts = nc_lex(ctx, "__nc_pp_else", line.line)
    if (control || pp || (function && !expression)) && (!program || (block || (!nc_is(last, "}") && !nc_is(last, ";"))))
      NcTokens copy = {0}
      for size_t j = 0; j < line.ts.n; ++j
        NC_PUSH(ctx, copy, line.ts.v[j])
      NC_PUSH(ctx, copy, nc_token(":", line.line, NC_PUNCT))
      line.ts = copy
    NC_PUSH(ctx, out, line)
  < out
