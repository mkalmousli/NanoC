// Builtin catalog types.
@lang 1
typedef NcValue (*NcBuiltinFn)(NcMachine *, const char *, NcValues, int);
s NcSpec
  const char *name, *signature, *phase
  function:NcBuiltinFn

extern const NcSpec nc_specs[];
extern const size_t nc_spec_count;
