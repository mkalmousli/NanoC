#ifndef NC_NANOC_H
#define NC_NANOC_H
// Base types and limits.

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <limits.h>
#include <ctype.h>

typedef struct NcContext NcContext;
typedef struct NcAllocation NcAllocation;

typedef struct NcEntry NcEntry;
struct NcEntry {
    const char * key;
    void *value;
};

typedef struct NcMap NcMap;
struct NcMap {
    NcEntry *v;
    size_t n,cap;
};

typedef struct NcBuffer NcBuffer;
struct NcBuffer {
    char *v;
    size_t n,cap;
};

typedef struct NcStrings NcStrings;
struct NcStrings {
    char * *v;
    size_t n,cap;
};

#define NC_PUSH(c, a, x) do { \
    if ((a).n == (a).cap) (a).v = nc_grow(c, (a).v, (a).n, &(a).cap, sizeof *(a).v); \
    (a).v[(a).n++] = (x); \
} while (0)
// Token and cursor types.
typedef enum {
    NC_SPACE,
    NC_WORD,
    NC_NUMBER,
    NC_LITERAL,
    NC_PUNCT,
    NC_DIRECTIVE
} NcKind;

typedef struct NcToken NcToken;
struct NcToken {
    const char * s;
    size_t n;
    int line,column;
    NcKind kind;
};

typedef struct NcTokens NcTokens;
struct NcTokens {
    NcToken *v;
    size_t n,cap;
};

typedef struct NcGroups NcGroups;
struct NcGroups {
    NcTokens *v;
    size_t n,cap;
};

typedef struct NcCursor NcCursor;
struct NcCursor {
    NcContext *ctx;
    NcTokens ts;
    size_t pos;
};
// The compile context.
typedef struct NcSymbol NcSymbol;
struct NcSymbol {
    char *name, *params, *returns, *intent;
    int line;
};

typedef struct NcSymbols NcSymbols;
struct NcSymbols {
    NcSymbol *v;
    size_t n,cap;
};

struct NcContext {
    const char *file;
    bool cpp;
    size_t max_depth, max_steps, max_output, steps, serial, allocated;
    size_t max_passes, pass;
    bool effects, again, lines, mini;
    const char *source, *next_source;
    NcMap state;
    NcStrings logs;
    NcAllocation *allocations;
    NcMap names, macros;
    NcSymbols symbols;
    jmp_buf trap;
    char error[16384], detail[2048];
    const char *code;
    int error_line;
    char *frames[256];
    char *ret_type, *defers;
    bool need_stdio;
    size_t frame_count;
};
// Macro types.
typedef struct NcParam NcParam;
struct NcParam {
    char *name, *kind;
    bool variadic;
};

typedef struct NcParams NcParams;
struct NcParams {
    NcParam *v;
    size_t n,cap;
};

typedef struct NcMacro NcMacro;
struct NcMacro {
    NcParams params;
    NcTokens body;
    bool program;
};

typedef struct NcBindings NcBindings;
struct NcBindings {
    NcMap values,fresh;
    char *variadic;
};
// Layout tree types.
typedef struct NcLayoutLine NcLayoutLine;
struct NcLayoutLine {
    NcTokens ts;
    int indent,line;
    bool raw;
};

typedef struct NcLines NcLines;
struct NcLines {
    NcLayoutLine *v;
    size_t n,cap;
};

typedef struct NcNode NcNode;

typedef struct NcNodes NcNodes;
struct NcNodes {
    NcNode *v;
    size_t n,cap;
};

struct NcNode {
    NcLayoutLine head;
    NcNodes children;
};

typedef struct NcHeader NcHeader;
struct NcHeader {
    int line,indent;
};
// State of the pretty C printer.

typedef struct {
    NcContext *c;
    NcBuffer out;
    NcToken prev;
    int ind, top, paren, after, ternary;
    size_t col;
    bool bol, space, cont, stmt, kw_type, kw_enum, in_case, gap, comment, last_dir, has_prev;
    char kind[256];
    bool cases[256], dos[256], ctl[256];
} NcPretty;
// Evaluator types.
typedef enum {
    NC_INT,
    NC_BOOL,
    NC_STRING,
    NC_CODE,
    NC_LIST
} NcValueKind;

typedef struct NcValue NcValue;
struct NcValue {
    NcValueKind kind;
    int64_t n;
    char *text;
    NcValue *items;
    size_t count, height;
};

typedef struct NcValues NcValues;
struct NcValues {
    NcValue *v;
    size_t n,cap;
};

typedef struct NcEnv {
    struct NcEnv *parent;
    NcMap values;
} NcEnv;

typedef struct NcCtFunction NcCtFunction;
struct NcCtFunction {
    NcStrings params;
    NcTokens body;
    NcEnv *closure;
};

typedef enum {
    NC_CT,
    NC_BT,
    NC_MACRO
} NcPhase;

typedef struct NcMachine NcMachine;
struct NcMachine {
    NcContext *ctx;
    NcMap functions;
    NcBuffer output;
    NcEnv *root;
    NcPhase phase;
    size_t depth;
};

typedef struct NcFlow NcFlow;
struct NcFlow {
    bool returning;
    NcValue value;
    bool breaking,continuing;
};

typedef struct NcExpr NcExpr;
struct NcExpr {
    NcCursor c;
    NcMachine *m;
    NcEnv *env;
    size_t depth;
};
// Builtin catalog types.
typedef NcValue (*NcBuiltinFn)(NcMachine *, const char *, NcValues, int);

typedef struct NcSpec NcSpec;
struct NcSpec {
    const char *name, *signature, *phase;
    NcBuiltinFn function;
};

extern const NcSpec nc_specs[];
extern const size_t nc_spec_count;
// CLI option types.

#define NC_VERSION "0.6.0"

typedef struct NcOptions NcOptions;
struct NcOptions {
    char *input, *output, *action;
    bool check,json,prototypes;
};

typedef struct NcJson NcJson;
struct NcJson {
    FILE *out;
    int depth;
    bool more[32];
};
char *nc_read(NcContext *c, const char *path);
void nc_write(NcContext *c, const char *path, const char *contents);
void nc_init(NcContext *c, const char *file);
void *nc_alloc(NcContext *c, size_t size);
void nc_dispose(NcContext *c);
void *nc_grow(NcContext *c, const void *old, size_t n, size_t *cap, size_t width);
_Noreturn void nc_fail(NcContext *c, int line, const char *format, ...);
void nc_step(NcContext *c, int line);
void nc_check(NcContext *c, size_t bytes, int line);
void nc_depth(NcContext *c, size_t depth, int line, const char *kind);
void *nc_get(const NcMap *m, const char *key);
bool nc_has_token(const NcMap *m, NcToken t);
void nc_put(NcContext *c, NcMap *m, const char *key, void *value);
char *nc_fresh(NcContext *c, const char *hint);
void nc_addn(NcContext *c, NcBuffer *b, const char *s, size_t n);
void nc_add(NcContext *c, NcBuffer *b, const char *s);
void nc_printf(NcContext *c, NcBuffer *b, const char *format, ...);
char *nc_string(NcContext *c, const char *s, size_t n);
char *nc_format(NcContext *c, const char *format, ...);
char *nc_trim(NcContext *c, const char *s);
bool nc_identifier(const char *s);
char *nc_quote(NcContext *c, const char *s);
char *nc_unquote(NcContext *c, const char *s, int line);
NcLayoutLine nc_logical_line(NcCursor *c);
NcLines nc_body_lines(NcCursor *c, int header_line, int indent);
char *nc_match(NcContext *c, NcNode node, size_t depth);
NcHeader nc_header(const NcCursor *c);
bool nc_same_line(const NcCursor *c, int line);
bool nc_header_at(const NcCursor *c, const char *s, int line);
bool nc_header_eat(NcCursor *c, const char *s, int line);
NcTokens nc_line_expression(NcCursor *c);
NcNodes nc_indented_nodes(NcCursor *c, NcHeader header, bool program);
char *nc_defer_return(NcContext *c, char *s);
void nc_emit_defer(NcContext *c, NcBuffer *out, NcNodes nodes, size_t at, bool tail, size_t depth);
char *nc_say(NcContext *c, const char *args, int line);
NcTokens nc_meta_body(NcCursor *c, NcHeader header, bool program, bool tail);
NcTokens nc_macro_body(NcCursor *c, NcHeader header, bool *program);
bool nc_is_ret(NcContext *c, NcTokens items);
char *nc_statement(NcContext *c, NcLayoutLine line, bool tail);
void nc_marker(NcContext *c, NcBuffer *b, int line);
char *nc_emit_block(NcContext *c, NcNodes nodes, bool tail, size_t depth);
char *nc_infer(NcContext *c, NcTokens ts, int line);
NcTokens nc_declaration(NcContext *ctx, NcTokens ts, int line);
char *nc_program_control(NcContext *ctx, NcTokens ts, int line);
NcTokens nc_program_text(NcContext *ctx, const char *text, int line);
char *nc_emit_program(NcContext *ctx, NcNodes nodes, bool tail, size_t depth);
char *nc_control(NcContext *ctx, NcTokens ts, int line);
bool inline_head(NcToken t);
size_t inline_first(NcTokens ts);
int inline_split(NcTokens ts);
int inline_else(NcTokens ts);
NcLines nc_split_inline(NcContext *ctx, NcLines input);
bool nc_extension_line(NcLayoutLine line);
bool nc_meta_line(NcLayoutLine line);
NcLines nc_prepare_lines(NcContext *ctx, NcLines input, bool program);
NcNodes nc_tree(NcContext *c, NcLines lines, size_t *i, int indent, size_t depth);
NcValue nc_expression(NcExpr *e, int minimum, bool active);
NcValue nc_eval(NcMachine *m, NcTokens ts, NcEnv *env, size_t depth, bool active);
int64_t nc_arithmetic(NcContext *c, const char *op, int64_t x, int64_t y, int line);
NcValue nc_builtin_tokens(NcMachine *m, const char *name, NcValue v, int line);
NcValue nc_builtin_range(NcMachine *m, NcValues args, int line);
NcEnv *nc_env(NcContext *c, NcEnv *parent);
void nc_bind(NcContext *c, NcEnv *e, const char *name, NcValue value);
NcValue nc_lookup(NcContext *c, NcEnv *e, const char *name, int line);
void nc_assign(NcContext *c, NcEnv *e, const char *name, NcValue value, int line);
char *nc_program(NcContext *ctx, NcTokens ts, NcEnv *env, NcPhase phase, size_t depth);
NcValue nc_quotation(NcExpr *e, NcTokens ts, bool active);
NcValue nc_integer(int64_t n);
NcValue nc_boolean(bool n);
NcValue nc_value_text(NcValueKind kind, char *s);
NcValue nc_list(NcValues items);
bool nc_truth(NcValue v);
int64_t nc_numeric(NcContext *c, NcValue v, int line);
char *nc_display(NcContext *c, NcValue v, size_t depth, int line);
char *nc_value_code(NcContext *c, NcValue v, int line);
bool nc_equal(NcContext *c, NcValue a, NcValue b, size_t depth, int line);
NcFlow nc_conditional(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth);
NcFlow nc_loop(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth, const char *name);
bool nc_assignment(NcMachine *m, NcCursor *c, NcEnv *env, size_t depth, NcToken name);
NcFlow nc_run(NcMachine *m, NcTokens ts, NcEnv *env, size_t depth);
char *nc_compile_time(NcContext *ctx, NcTokens ts, size_t depth);
void nc_arity(NcContext *c, NcValues args, size_t n, int line);
NcValue nc_builtin(NcMachine *m, const char *name, NcValues args, int line);
NcFlow nc_c_for(NcMachine *m, NcCursor *c, NcEnv *parent, size_t depth);
int nc_precedence(NcToken t);
NcValue nc_binary(NcContext *c, NcToken op, NcValue a, NcValue b, int line);
NcValue nc_primary(NcExpr *e, bool active);
void nc_ct_define(NcMachine *m, NcCursor *c, NcEnv *env);
NcValue nc_call(NcMachine *m, const char *name, NcValues args, size_t depth, int line);
char *nc_mini(NcContext *c, const char *text);
char *nc_style(NcContext *c, const char *text);
void nc_pp_put(NcPretty *p, const char *s, size_t n);
void nc_pp_nl(NcPretty *p);
void nc_pp_end(NcPretty *p);
void nc_pp_blank(NcPretty *p);
void nc_pp_directive(NcPretty *p, NcToken t);
char *nc_pretty(NcContext *c, const char *text);
bool nc_pp_prev_is(NcPretty *p, const char *s);
bool nc_pp_prev_punct(NcPretty *p, const char *s);
void nc_pp_open(NcPretty *p, NcToken t);
void nc_pp_close(NcPretty *p);
void nc_pp_resolve(NcPretty *p, NcToken t);
char *nc_macro_program(NcContext *ctx, NcMacro *macro, NcBindings *b, size_t depth);
void nc_define_macro(NcContext *ctx, NcCursor *c);
char *nc_invoke_macro(NcContext *ctx, NcCursor *c, const char *name, size_t depth);
char *nc_substitute(NcContext *ctx, NcTokens ts, NcBindings *b, size_t depth, size_t index);
void nc_block_argument(NcContext *ctx, NcCursor *c, NcMacro *m, NcGroups *args, int line, int indent);
void jw_start(NcJson *w, FILE *out);
void jw_text(NcJson *w, const char *s);
void jw_open(NcJson *w, char open);
void jw_close(NcJson *w, char close);
void jw_key(NcJson *w, const char *key);
void jw_str(NcJson *w, const char *s);
void jw_int(NcJson *w, long n);
void jw_bool(NcJson *w, bool b);
void jw_raw(NcJson *w, const char *json);
void jw_ks(NcJson *w, const char *k, const char *s);
void jw_ki(NcJson *w, const char *k, long n);
void jw_kb(NcJson *w, const char *k, bool b);
void jw_kr(NcJson *w, const char *k, const char *json);
void nc_help(FILE *out);
NcOptions nc_options(NcContext *c, int argc, char **argv);
void nc_prototypes(NcContext *c, FILE *out);
void nc_report(FILE *out, NcContext *c, size_t bytes);
void nc_diagnostic(FILE *out, NcContext *c);
bool nc_describe(FILE *out, const char *topic);
NcValue nc_meta_lists(NcMachine *m, const char *name, NcValues a, int line);
char *nc_pipeline(NcContext *ctx, const char *input);
NcValue nc_host_run(NcMachine *m, NcValues a, int line);
NcValue nc_meta_process(NcMachine *m, const char *name, NcValues a, int line);
char *nc_build_stage(NcContext *ctx, const char *source);
NcValue nc_meta_strings(NcMachine *m, const char *name, NcValues a, int line);
bool nc_builtin_known(const char *name);
NcValue nc_extra_builtin(NcMachine *m, const char *name, NcValues args, int line);
const char *nc_meta_text(NcContext *c, NcValue v, int line);
void nc_effect(NcMachine *m, int line);
NcValue nc_meta_control(NcMachine *m, const char *name, NcValues a, int line);
NcValue nc_meta_files(NcMachine *m, const char *name, NcValues a, int line);
char *nc_include(NcContext *ctx, NcCursor *c);
char *nc_expand(NcContext *ctx, NcTokens ts, size_t depth);
char *nc_transpile(NcContext *ctx, const char *input);
void nc_alias(NcToken *t);
char *nc_alias_name(NcContext *c, const char *name);
NcTokens nc_aliased(NcContext *c, NcTokens ts);
char *nc_function(NcContext *ctx, NcCursor *c, size_t depth);
char *nc_raw(NcContext *ctx, NcCursor *c);
char *nc_native_function(NcContext *ctx, NcCursor *c, size_t depth);
NcTokens nc_group(NcCursor *c, const char *open, const char *close);
NcTokens nc_until(NcCursor *c, const char *delimiter);
NcGroups nc_split(NcContext *ctx, NcTokens ts, const char *delimiter);
bool nc_is(NcToken t, const char *s);
char *nc_text(NcContext *c, NcToken t);
NcToken nc_token(const char *s, int line, NcKind kind);
NcTokens nc_slice(NcTokens ts, size_t a, size_t b);
char *nc_join(NcContext *c, NcTokens ts);
NcTokens nc_significant(NcContext *c, NcTokens ts);
char *nc_words(NcContext *c, NcTokens ts);
void nc_names(NcContext *c, NcTokens ts);
NcTokens nc_lex(NcContext *c, const char *s, int line);
char *nc_native_parameters(NcContext *ctx, NcTokens ts);
char *nc_shorthand(NcContext *ctx, NcCursor *c, const char *name, size_t depth);
const char *nc_sep(const char *type);
char *nc_typed(NcContext *ctx, NcTokens input, bool initialized);
char *nc_parameters(NcContext *ctx, NcTokens ts);
void nc_skip(NcCursor *c);
bool nc_end(NcCursor *c);
bool nc_at(NcCursor *c, const char *s);
int nc_line(const NcCursor *c);
NcToken nc_take(NcCursor *c);
bool nc_eat(NcCursor *c, const char *s);
void nc_need(NcCursor *c, const char *s);
char *nc_name(NcCursor *c);
char *nc_record(NcContext *ctx, NcCursor *c, char kind);
char *nc_assembly(NcContext *ctx, NcCursor *c);
size_t nc_literal_start(const char *s, size_t i, bool cpp);
size_t nc_literal_end(NcContext *c, const char *s, size_t i, int line);
size_t nc_line_end(const char *s, size_t start);
#endif
