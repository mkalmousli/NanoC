// Source and translation-cycle information available to translation-time programs.
@lang 1
+ "nanoc/nanoc.h"

// Returns the active source location, surrounding function, cycle or output language.
f nc_meta_context(NcMachine *m, const char *name, NcValues args, int at) NcValue
  NcContext *c = m->ctx
  nc_arity(c, args, 0, at)
  if !strcmp(name, "line")
    < nc_integer(at)
  if !strcmp(name, "cycle")
    < nc_integer((int64_t)c->pass)
  if !strcmp(name, "name")
    < nc_value_text(NC_STRING, (char *)(c->function_name ? c->function_name : ""))
  if !strcmp(name, "target")
    < nc_value_text(NC_STRING, c->cpp ? "c++17" : (char *)nc_standard_name())
  if !strcmp(name, "path")
    char resolved[PATH_MAX]
    if NC_REALPATH(c->file, resolved)
      < nc_value_text(NC_STRING, nc_string(c, resolved, strlen(resolved)))
  < nc_value_text(NC_STRING, (char *)c->file)
