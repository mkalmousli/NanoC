// CLI option types.
#define NC_VERSION "0.6.0"
#define NC_LANG 1
@s NcOptions char *input, *output, *action; check,json,prototypes,migrate:bool
@s NcJson out:*FILE; depth:i32; bool more[32]
