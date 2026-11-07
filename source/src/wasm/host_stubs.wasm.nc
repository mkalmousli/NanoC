@lang 1
+ "nanoc/nanoc.h"
// Read-only translate-time host inputs are unavailable in the browser.
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

// Reports the browser's lack of host command execution.
f nc_host_run(NcMachine *m, NcValues args, int at) NcValue
  (void)args
  nc_fail(m->ctx, at, "host commands require the native compiler")
  < (NcValue){0}

// Browser inputs have virtual paths and no host filesystem to resolve them against.
f realpath(const char *input, char *output) char *
  (void)input
  (void)output
  < NULL
