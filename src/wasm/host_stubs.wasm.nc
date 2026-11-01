// Build-time file and process features are unavailable in the browser: they fail as "no such capability".
#include "nanoc/nanoc.h"
@f nc_meta_files(NcMachine *m, const char *name, NcValues a, int line) NcValue
  (void)m
  (void)name
  (void)a
  nc_fail(0, line, "%s is not available in the browser", name)
  (NcValue){0}
@f nc_host_run(NcMachine *m, NcValues a, int line) NcValue
  (void)m
  (void)a
  nc_fail(0, line, "run is not available in the browser")
  (NcValue){0}
