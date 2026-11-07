// Evaluator types.
@lang 1
e NcValueKind  NC_INT, NC_BOOL, NC_STRING, NC_CODE, NC_LIST

typedef struct NcValue NcValue;
struct NcValue { NcValueKind kind; int64_t n; char *text; NcValue *items; size_t count, height; };
s NcValues
  v:*NcValue
  n,cap:size_t

typedef struct NcEnv { struct NcEnv *parent; NcMap values; } NcEnv;
s NcTtFunction
  params:NcStrings
  body:NcTokens
  closure:*NcEnv

e NcPhase  NC_TT, NC_MACRO

s NcMachine
  ctx:*NcContext
  functions:NcMap
  output:NcBuffer
  root:*NcEnv
  phase:NcPhase
  depth:size_t

s NcFlow
  returning:bool
  value:NcValue
  breaking,continuing:bool

s NcExpr
  c:NcCursor
  m:*NcMachine
  env:*NcEnv
  depth:size_t
