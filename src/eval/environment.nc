#include "nanoc/eval.h"
@f nc_env(NcContext *c, NcEnv *parent) NcEnv *
  NcEnv *e = nc_alloc(c, sizeof *e)
  e->parent = parent
  e
@f nc_bind(NcContext *c, NcEnv *e, const char *name, NcValue value) void
  NcValue *p = nc_alloc(c, sizeof *p)
  *p = value
  nc_put(c, &e->values, name, p)
@f nc_lookup(NcContext *c, NcEnv *e, const char *name, int line) NcValue
  for ; e; e = e->parent
    NcValue *p = nc_get(&e->values, name)
    if p
      return *p
  nc_fail(c, line, "unknown compile-time variable: %s", name)
  (NcValue){0}
@f nc_assign(NcContext *c, NcEnv *e, const char *name, NcValue value, int line) void
  for ; e; e = e->parent
    NcValue *p = nc_get(&e->values, name)
    if p
      *p = value
      return
  nc_fail(c, line, "unknown compile-time variable: %s", name)
