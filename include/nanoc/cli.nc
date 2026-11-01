// CLI option types.
#define NC_VERSION "0.6.0"
typedef struct { char *input, *output, *action; bool check, json, prototypes; } NcOptions;
typedef struct { FILE *out; int depth; bool more[32]; } NcJson;
