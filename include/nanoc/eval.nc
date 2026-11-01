// Evaluator types.
@e NcValueKind NC_INT, NC_BOOL, NC_STRING, NC_CODE, NC_LIST
typedef struct NcValue NcValue;
struct NcValue { NcValueKind kind; int64_t n; char *text; NcValue *items; size_t count, height; };
@s NcValues v:*NcValue; n,cap:usize
typedef struct NcEnv { struct NcEnv *parent; NcMap values; } NcEnv;
@s NcCtFunction params:NcStrings; body:NcTokens; closure:*NcEnv
@e NcPhase NC_CT, NC_BT, NC_MACRO
@s NcMachine ctx:*NcContext; functions:NcMap; output:NcBuffer; root:*NcEnv; phase:NcPhase; depth:usize
@s NcFlow returning:bool; value:NcValue; breaking,continuing:bool
@s NcExpr c:NcCursor; m:*NcMachine; env:*NcEnv; depth:usize
