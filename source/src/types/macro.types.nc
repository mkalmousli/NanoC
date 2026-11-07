// Macro types.
@lang 1
s NcParam
  char *name, *kind
  variadic:bool

s NcParams
  v:*NcParam
  n,cap:size_t

s NcMacro
  params:NcParams
  body:NcTokens
  program:bool

s NcBindings
  values,fresh:NcMap
  variadic:*char
