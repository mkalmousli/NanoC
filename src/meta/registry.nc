// Builtin catalog and metadata.
#include "nanoc/nanoc.h"
const NcSpec nc_specs[] = {
  {"emit", "emit(text|tokens)", "all", NULL},
  {"str", "str(value)", "all", NULL},
  {"tokens", "tokens(text)", "all", NULL},
  {"ident", "ident(text)", "all", NULL},
  {"fresh", "fresh(hint)", "all", NULL},
  {"len", "len(value)", "all", NULL},
  {"range", "range([start,]end)", "all", NULL},
  {"replace", "replace(text,from,to)", "all",
    nc_meta_strings},
  {"rename", "rename(text,oldIdentifier,newIdentifier)",
    "all", nc_meta_strings},
  {"find", "find(text,needle)", "all", nc_meta_strings},
  {"contains", "contains(text,needle)", "all",
    nc_meta_strings},
  {"split", "split(text,separator)", "all",
    nc_meta_strings},
  {"join", "join(list,separator)", "all", nc_meta_lists},
  {"slice", "slice(value,start[,end])", "all",
    nc_meta_lists},
  {"push", "push(list,value)", "all", nc_meta_lists},
  {"lex", "lex(text)", "all", nc_meta_lists},
  {"source", "source()", "all", nc_meta_control},
  {"rewrite", "rewrite(text)", "all", nc_meta_control},
  {"again", "again()", "all", nc_meta_control},
  {"pass", "pass()", "all", nc_meta_control},
  {"get", "get(key,default)", "all", nc_meta_control},
  {"put", "put(key,value)", "all", nc_meta_control},
  {"eval", "eval(program)", "all", nc_meta_control},
  {"fail", "fail(message)", "all", nc_meta_control},
  {"assert", "assert(condition[,message])", "all",
    nc_meta_control},
  {"log", "log(message)", "all", nc_meta_control},
  {"read", "read(path)", "all", nc_meta_files},
  {"exists", "exists(path)", "all", nc_meta_files},
  {"env", "env(name)", "all", nc_meta_files},
  {"file", "file()", "all", nc_meta_files},
  {"write", "write(path,text)", "bt", nc_meta_files},
  {"mkdir", "mkdir(path)", "bt", nc_meta_files},
  {"remove", "remove(path)", "bt", nc_meta_files},
  {"run", "run(argv[,cwd]) -> [status,out,err]", "bt",
    nc_meta_process},
  {"exec", "exec(argv[,cwd]) -> stdout; fails on nonzero",
    "bt", nc_meta_process},
  {"sh", "sh(command) -> [status,out,err]", "bt",
    nc_meta_process} };
const size_t nc_spec_count = (
  sizeof nc_specs / sizeof *nc_specs);
// Tells if a builtin exists.
@f nc_builtin_known(const char *name) bool
  for size_t i = 0; i < nc_spec_count; ++i
    if !strcmp(name, nc_specs[i].name)
      return true
  false
// Calls a registered builtin.
@f nc_extra_builtin(
  NcMachine *m, const char *name, NcValues args, int line
) NcValue
  for size_t i = 0; i < nc_spec_count; ++i
    const NcSpec *s = &nc_specs[i]
    if !strcmp(name, s->name) && s->function
      return s->function(m, name, args, line)
  nc_fail(m->ctx, line, "unknown compile-time function: %s",
    name)
  (NcValue){0}
// Gets a value as text.
@f nc_meta_text(
  NcContext *c, NcValue v, int line
) const char *
  if v.kind != NC_STRING && v.kind != NC_CODE
    nc_fail(c, line, "expected text or tokens")
  v.text
// Fails unless host effects are on.
@f nc_effect(NcMachine *m, int line) void
  if m->phase != NC_BT
    nc_fail(m->ctx, line, "host effects require @bt")
  if !m->ctx->effects
    nc_fail(m->ctx, line,
      "host effects disabled by --check or --no-effects")
