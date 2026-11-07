@lang 1
+ "nanoc/nanoc.h"
// Read-only compile-time host inputs are unavailable in the browser.
#include "nanoc/nanoc.h"
// Implements nc_meta_files for the freestanding browser compiler.
f nc_meta_files(NcMachine *m, const char *name, NcValues a, int line) NcValue
  (void)m
  (void)name
  (void)a
  nc_fail(m->ctx, line, "%s is not available in the browser", name)
  < (NcValue){0}


// Reports that temporary host streams are unavailable in the browser.
f tmpfile() FILE *
  < NULL

// Reports an unavailable host stream position.
f ftell(FILE *stream) long
  (void)stream
  < -1

// Keeps the unsupported host stream interface side-effect free.
f rewind(FILE *stream)
  (void)stream

// Trace-marker scanning is unavailable in the browser, where tracing is disabled.
f sscanf(const char *input, const char *format, ...) int
  (void)input
  (void)format
  < 0
