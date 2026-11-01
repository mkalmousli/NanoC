// One-line blocks: `if c then ret x` and `else stmt` become a header plus an indented body.
// Tells if a word starts a block that may take an inline body.
@f inline_head(NcToken t) bool
  cstr k[] = {"if", "elif", "else", "while", "for", "unless", "until"}
  for i:usize in 0..7
    if nc_is(t, k[i]) then return true
  false
// Finds the index of the first significant token in a line.
@f inline_first(NcTokens ts) usize
  usize i = 0
  while i < ts.n and ts.v[i].kind == NC_SPACE
    ++i
  i
// Finds the `then` token at bracket depth zero, or the end of `else`; -1 for no inline body.
@f inline_split(NcTokens ts) int
  usize f = inline_first(ts)
  if f == ts.n or not inline_head(ts.v[f]) then return -1
  int depth = 0
  for i:usize in f..ts.n
    NcToken t = ts.v[i]
    if nc_is(t, "(") or nc_is(t, "[") or nc_is(t, "{")
      ++depth
    elif nc_is(t, ")") or nc_is(t, "]") or nc_is(t, "}") then --depth
    elif not depth and nc_is(t, "then") and i > f
      return i
  if nc_is(ts.v[f], "else") and f + 1 < ts.n
    usize s = f + 1
    while s < ts.n and ts.v[s].kind == NC_SPACE
      ++s
    if s < ts.n and not nc_is(ts.v[s], "if") then return f
  -1
// Finds a depth-zero `else` word inside an inline body, or -1 for none.
@f inline_else(NcTokens ts) int
  int depth = 0
  for i:usize in 0..ts.n
    NcToken t = ts.v[i]
    if nc_is(t, "(") or nc_is(t, "[") or nc_is(t, "{") then ++depth
    elif nc_is(t, ")") or nc_is(t, "]") or nc_is(t, "}") then --depth
    elif not depth and i > 0 and nc_is(t, "else") then return i
  -1
// Splits lines such as `if a then b` into `if a` and an indented `b`.
@f nc_split_inline(NcContext *ctx, NcLines input) NcLines
  NcLines out = {0}
  for i:usize in 0..input.n
    NcLayoutLine line = input.v[i]
    bool block = i + 1 < input.n and input.v[i + 1].indent > line.indent
    int at = block ? -1 : inline_split(line.ts)
    if at < 0 then NC_PUSH(ctx, out, line); continue
    NcLayoutLine head = line, body = line
    usize first = inline_first(line.ts)
    usize cut = (usize)at + 1
    head.ts = nc_slice(line.ts, 0, at == (int)first ? cut : (usize)at)
    while cut < line.ts.n and line.ts.v[cut].kind == NC_SPACE
      ++cut
    body.ts = nc_slice(line.ts, cut, line.ts.n)
    body.indent += 2
    NC_PUSH(ctx, out, head)
    int e = inline_else(body.ts)
    if e < 0 then NC_PUSH(ctx, out, body); continue
    NcLayoutLine alt = line, rest = body
    rest.ts = nc_slice(body.ts, e + 1, body.ts.n)
    body.ts = nc_slice(body.ts, 0, e)
    alt.ts = nc_slice(line.ts, 0, 0)
    NC_PUSH(ctx, alt.ts, nc_token("else", line.line, NC_WORD))
    NC_PUSH(ctx, out, body)
    NC_PUSH(ctx, out, alt)
    NC_PUSH(ctx, out, rest)
  out
