typedef NcValue (*NcBuiltinFn)(NcMachine *, const char *, NcValues, int);
typedef struct { const char *name, *signature, *phase; NcBuiltinFn function; } NcSpec;
extern const NcSpec nc_specs[];
extern const size_t nc_spec_count;
