#ifndef NC_EVAL_H
#define NC_EVAL_H
#include "core.h"
typedef enum { NC_INT, NC_BOOL, NC_STRING, NC_CODE, NC_LIST } NcValueKind;
typedef struct NcValue NcValue;
struct NcValue { NcValueKind kind; int64_t n; char *text; NcValue *items; size_t count, height; };
typedef struct { NcValue *v; size_t n, cap; } NcValues;
typedef struct NcEnv { struct NcEnv *parent; NcMap values; } NcEnv;
typedef struct { NcStrings params; NcTokens body; NcEnv *closure; } NcCtFunction;
typedef enum { NC_CT, NC_BT, NC_MACRO } NcPhase;
typedef struct { NcContext *ctx; NcMap functions; NcBuffer output; NcEnv *root; NcPhase phase; size_t depth; } NcMachine;
typedef struct { bool returning; NcValue value; bool breaking, continuing; } NcFlow;
typedef struct { NcCursor c; NcMachine *m; NcEnv *env; size_t depth; } NcExpr;
NcValue nc_integer(int64_t);
NcValue nc_boolean(bool);
NcValue nc_value_text(NcValueKind, char *);
NcValue nc_list(NcValues);
bool nc_truth(NcValue);
int64_t nc_numeric(NcContext *, NcValue, int);
NcEnv *nc_env(NcContext *, NcEnv *);
NcValue nc_lookup(NcContext *, NcEnv *, const char *, int);
void nc_assign(NcContext *, NcEnv *, const char *, NcValue, int);
void nc_bind(NcContext *, NcEnv *, const char *, NcValue);
char *nc_display(NcContext *, NcValue, size_t, int);
char *nc_value_code(NcContext *, NcValue, int);
bool nc_equal(NcContext *, NcValue, NcValue, size_t, int);
int nc_precedence(NcToken);
NcValue nc_binary(NcContext *, NcToken, NcValue, NcValue, int);
int64_t nc_arithmetic(NcContext *, const char *, int64_t, int64_t, int);
NcValue nc_eval(NcMachine *, NcTokens, NcEnv *, size_t, bool);
NcValue nc_expression(NcExpr *, int, bool);
NcValue nc_primary(NcExpr *, bool);
NcValue nc_quotation(NcExpr *, NcTokens, bool);
NcValue nc_call(NcMachine *, const char *, NcValues, size_t, int);
NcValue nc_builtin(NcMachine *, const char *, NcValues, int);
NcValue nc_builtin_tokens(NcMachine *, const char *, NcValue, int);
NcValue nc_builtin_range(NcMachine *, NcValues, int);
void nc_arity(NcContext *, NcValues, size_t, int);
NcFlow nc_run(NcMachine *, NcTokens, NcEnv *, size_t);
NcFlow nc_conditional(NcMachine *, NcCursor *, NcEnv *, size_t);
NcFlow nc_loop(NcMachine *, NcCursor *, NcEnv *, size_t, const char *);
void nc_ct_define(NcMachine *, NcCursor *, NcEnv *);
char *nc_program(NcContext *, NcTokens, NcEnv *, NcPhase, size_t);
bool nc_assignment(NcMachine *, NcCursor *, NcEnv *, size_t, NcToken);
NcFlow nc_c_for(NcMachine *, NcCursor *, NcEnv *, size_t);
#endif
