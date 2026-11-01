// Macro types.
typedef struct { char *name, *kind; bool variadic; } NcParam;
typedef struct { NcParam *v; size_t n, cap; } NcParams;
typedef struct { NcParams params; NcTokens body; bool program; } NcMacro;
typedef struct { NcMap values, fresh; char *variadic; } NcBindings;
