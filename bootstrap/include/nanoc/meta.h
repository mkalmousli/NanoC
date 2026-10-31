#ifndef NC_META_H
#define NC_META_H
#include "eval.h"
typedef NcValue (*NcBuiltinFn)(NcMachine *, const char *, NcValues, int);
typedef struct { const char *name, *signature, *phase; NcBuiltinFn function; } NcBuiltinSpec;
extern const NcBuiltinSpec nc_builtin_specs[];
extern const size_t nc_builtin_count;
bool nc_builtin_known(const char *);
NcValue nc_extra_builtin(NcMachine *, const char *, NcValues, int);
const char *nc_meta_text(NcContext *, NcValue, int);
void nc_effect(NcMachine *, int);
NcValue nc_meta_strings(NcMachine *, const char *, NcValues, int);
NcValue nc_meta_lists(NcMachine *, const char *, NcValues, int);
NcValue nc_meta_control(NcMachine *, const char *, NcValues, int);
NcValue nc_meta_files(NcMachine *, const char *, NcValues, int);
NcValue nc_meta_process(NcMachine *, const char *, NcValues, int);
NcValue nc_host_run(NcMachine *, NcValues, int);
char *nc_pipeline(NcContext *, const char *);
char *nc_build_stage(NcContext *, const char *);
#endif
