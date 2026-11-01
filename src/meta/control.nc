#include "nanoc/nanoc.h"
#include "nanoc/nanoc.h"
@f nc_meta_control(NcMachine *m, const char *name, NcValues a, int line) NcValue
  NcContext *c = m->ctx
  if !strcmp(name, "source") || !strcmp(name, "again") || !strcmp(name, "pass")
    nc_arity(c, a, 0, line)
    if !strcmp(name, "source")
      return nc_value_text(NC_STRING, (char *)(c->source ? c->source : ""))
    if !strcmp(name, "pass")
      return nc_integer((int64_t)c->pass)
    c->again = true
    return nc_integer(0)
  if !strcmp(name, "put") || !strcmp(name, "get")
    nc_arity(c, a, 2, line)
    const char *key = nc_meta_text(c, a.v[0], line)
    NcValue *v = nc_get(&c->state, key)
    if !strcmp(name, "get")
      return v ? *v : a.v[1]
    if !v
      v = nc_alloc(c, sizeof *v)
      nc_put(c, &c->state, key, v)
    *v = a.v[1]
    return a.v[1]
  if !strcmp(name, "assert")
    if a.n != 1 && a.n != 2
      nc_fail(c, line, "assert expects condition[,message]")
    if !nc_truth(a.v[0])
      nc_fail(c, line, "%s", a.n == 2 ? nc_meta_text(c, a.v[1], line) : "compile-time assertion failed")
    return a.v[0]
  nc_arity(c, a, 1, line)
  const char *text = nc_meta_text(c, a.v[0], line)
  if !strcmp(name, "fail")
    nc_fail(c, line, "%s", text)
  if !strcmp(name, "rewrite")
    nc_check(c, strlen(text), line)
    if !c->source || strcmp(text, c->source)
      c->next_source = text
      c->again = true
  else
    if !strcmp(name, "log")
      NC_PUSH(c, c->logs, (char *)text)
    else
      if !strcmp(name, "eval")
        nc_depth(c, m->depth + 1, line, "eval")
        ++m->depth
        NcFlow flow = nc_run(m, nc_program_text(c, text, line), m->root, m->depth)
        --m->depth
        if flow.breaking || flow.continuing
          nc_fail(c, line, "loop control outside eval loop")
        return flow.value
  nc_integer(0)
