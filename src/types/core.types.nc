// The compile context.
@lang 1
s NcSymbol
  char *name, *params, *returns, *intent
  line:int

s NcSymbols
  v:*NcSymbol
  n,cap:size_t

struct NcContext {
    const char *file, *executable, *next_error_code;
    NcToken last_token;
    NcSpan error_span;
    bool cpp, tracing;
    NcTraces traces;
    size_t trace_parent, trace_virtual;
    NcStrings trace_sources;
    int query_line;
    const char *query_symbol;
    size_t query_offset;
    bool query_generated;
    size_t max_depth, max_steps, max_output, steps, serial, allocated;
    size_t max_passes, pass;
    bool again, lines, mini;
    const char *source, *next_source;
    NcMap state;
    NcStrings logs;
    NcAllocation *allocations;
    NcMap names, macros, raw;
    size_t raw_serial;
    NcSymbols symbols;
    jmp_buf trap;
    char error[16384], detail[2048];
    const char *code;
    int error_line;
    char *frames[256];
    size_t frame_count;
};
