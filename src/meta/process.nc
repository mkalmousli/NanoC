// Process builtins: exec, run, sh.
#include "nanoc/nanoc.h"
// Runs process builtins.
@f nc_meta_process(
  NcMachine *m, const char *name, NcValues a, int line
) NcValue
  nc_effect(m, line)
  NcValue result
  if !strcmp(name, "sh")
    nc_arity(m->ctx, a, 1, line)
    NcValues argv = {0}, outer = {0}
    NC_PUSH(m->ctx, argv,
      nc_value_text(NC_STRING, "/bin/sh"))
    NC_PUSH(m->ctx, argv, nc_value_text(NC_STRING, "-c"))
    NC_PUSH(m->ctx, argv,
      nc_value_text(NC_STRING,
        (char *)nc_meta_text(m->ctx, a.v[0], line)))
    NC_PUSH(m->ctx, outer, nc_list(argv))
    result = nc_host_run(m, outer, line)
  else
    result = nc_host_run(m, a, line)
  if !strcmp(name, "exec")
    long long code = (long long) result.items[0].n
    if result.items[0].n
      nc_fail(m->ctx, line, "command exited %lld: %.1000s",
        code, result.items[2].text)
    return result.items[1]
  result
