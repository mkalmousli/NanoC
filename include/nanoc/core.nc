// The compile context.
@s NcSymbol char *name, *params, *returns, *intent; line:i32
@s NcSymbols v:*NcSymbol; n,cap:usize
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
    size_t frame_count;
};
