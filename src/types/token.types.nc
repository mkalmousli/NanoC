// Token and cursor types.
@e NcKind NC_SPACE, NC_WORD, NC_NUMBER, NC_LITERAL, NC_PUNCT, NC_DIRECTIVE
@s NcToken s:cstr; n:usize; line,column:i32; kind:NcKind
@s NcTokens v:*NcToken; n,cap:usize
@s NcGroups v:*NcTokens; n,cap:usize
@s NcCursor ctx:*NcContext; ts:NcTokens; pos:usize
