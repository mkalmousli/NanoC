// Variable scopes of the evaluator.
// Creates a child scope.
@f nc_env(NcContext *c, NcEnv *parent) NcEnv *
  NcEnv *e = nc_alloc(c, sizeof *e)
  e->parent = parent
  e
// Defines a variable in a scope.
@f nc_bind(NcContext *c, NcEnv *e, cstr name, NcValue value) void
  NcValue *p = nc_alloc(c, sizeof *p)
  *p = value
  nc_put(c, &e->values, name, p)
// Finds a variable in the scopes.
@f nc_lookup(NcContext *c, NcEnv *e, cstr name, int line) NcValue
  for ; e; e = e->parent
    NcValue *p = nc_get(&e->values, name)
    if p then return *p
  nc_fail(c, line, "unknown compile-time variable: %s", name)
  (NcValue){0}
// Updates an existing variable.
@f nc_assign(NcContext *c, NcEnv *e, cstr name, NcValue value, int line) void
  for ; e; e = e->parent
    NcValue *p = nc_get(&e->values, name)
    if p
      *p = value
      return
  nc_fail(c, line, "unknown compile-time variable: %s", name)
