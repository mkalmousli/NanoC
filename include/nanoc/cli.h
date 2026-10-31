#ifndef NC_CLI_H
#define NC_CLI_H
#include "core.h"
#define NC_VERSION "0.6.0"
typedef struct { char *input, *output, *action; bool check, json; } NcOptions;
NcOptions nc_options(NcContext *, int, char **);
void nc_help(FILE *);
void nc_json_string(FILE *, const char *);
void nc_report(FILE *, NcContext *, size_t);
void nc_diagnostic(FILE *, NcContext *);
bool nc_describe(FILE *, const char *);
#endif
