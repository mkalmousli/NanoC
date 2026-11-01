typedef NcValue (*NcBuiltinFn)(NcMachine *, const char *, NcValues, int);
typedef struct { const char *name, *signature, *phase; NcBuiltinFn function; } NcBuiltinSpec;
extern const NcBuiltinSpec nc_builtin_specs[];
extern const size_t nc_builtin_count;
