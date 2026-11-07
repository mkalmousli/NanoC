// CLI option types.
@lang 1
#define NC_VERSION "0.6.0"
#define NC_LANG 1
s NcOptions
  char *input, *output, *action, *command, *map
  check,json,prototypes,trace:bool

s NcJson
  out:*FILE
  depth:int
  bool more[32]
