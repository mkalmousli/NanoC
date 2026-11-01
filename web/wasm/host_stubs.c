/* Build-time file and process features are unavailable in the browser: they fail as "no such capability". */
#include "nanoc/meta.h"
#include "nanoc/core.h"
NcValue nc_meta_files(NcMachine *m, const char *name, NcValues a, int line) {
    (void)m; (void)name; (void)a;
    nc_fail(0, line, "%s is not available in the browser", name);
}
NcValue nc_host_run(NcMachine *m, NcValues a, int line) {
    (void)m; (void)a;
    nc_fail(0, line, "run is not available in the browser");
}
