// Token and cursor types.
@lang 1
e NcKind  NC_SPACE, NC_WORD, NC_NUMBER, NC_LITERAL, NC_PUNCT, NC_DIRECTIVE

s NcToken
  s:const char *
  n:size_t
  line,column:int
  kind:NcKind

s NcTokens
  v:*NcToken
  n,cap:size_t

s NcGroups
  v:*NcTokens
  n,cap:size_t

s NcCursor
  ctx:*NcContext
  ts:NcTokens
  pos:size_t
