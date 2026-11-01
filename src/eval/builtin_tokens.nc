// Builtins that work on token lists.
#include "nanoc/nanoc.h"
// Runs token-list builtins.
@f nc_builtin_tokens(NcMachine *m, const char *name, NcValue v, int line) NcValue
  NcContext *c = m->ctx
  if v.kind != NC_STRING
    nc_fail(c, line, "%s requires a string", name)
  if strcmp(name, "tokens") && !nc_identifier(v.text)
    nc_fail(c, line, "invalid identifier: %s", v.text)
  if !strcmp(name, "tokens")
    (void)nc_lex(c, v.text, line)
  nc_value_text(NC_CODE, !strcmp(name, "fresh") ? nc_fresh(c, v.text) : v.text)
// Runs the range builtin.
@f nc_builtin_range(NcMachine *m, NcValues args, int line) NcValue
  NcContext *c = m->ctx
  if args.n != 1 && args.n != 2
    nc_fail(c, line, "range expects one or two integers")
  int64_t start = args.n == 2 ? nc_numeric(c, args.v[0], line) : 0
  int64_t end = nc_numeric(c, args.v[args.n - 1], line)
  NcValues list = {0}
  for int64_t i = start; i < end; ++i
    nc_step(c, line)
    nc_check(c, (list.n + 1) * 8, line)
    NC_PUSH(c, list, nc_integer(i))
  nc_list(list)
