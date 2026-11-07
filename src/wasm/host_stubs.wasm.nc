@lang 1
+ "nanoc/nanoc.h"
// Read-only compile-time host inputs are unavailable in the browser.
#include "nanoc/nanoc.h"
f nc_meta_files(NcMachine *m, const char *name, NcValues a, int line) -> NcValue
  (void)m
  (void)name
  (void)a
  nc_fail(m->ctx, line, "%s is not available in the browser", name)
  return (NcValue){0}

