// Explicit repository tool interpreter. This executable is never installed as nanoc.
@lang 1
+ "nanoc/nanoc.h"

// Executes a developer script; only this binary links the host command capabilities.
f main(int argc, char **argv) -> int
  if (argc != 2)
    fputs("usage: nctool script.tool.nc\n", stderr); return 1
  NcContext *c = calloc(1, sizeof *c)
  if (!c)
    return 1
  nc_init(c, argv[1])
  c->max_steps = 0
  c->max_passes = 0
  c->max_output = 268435456
  int status = 0
  if (setjmp(c->trap))
    fprintf(stderr, "%s\n", c->error); status = 1
  else
    c->source = nc_read(c, argv[1])
    char *text = nc_program(c, nc_program_text(c, c->source, 1), NULL, NC_CT, 0)
    if (*text)
      fputs(text, stdout)
  for (size_t i = (0), nanoc_bound_1 = (c->logs.n); i < nanoc_bound_1; ++i)
    fprintf(stderr, "%s\n", c->logs.v[i])
  nc_dispose(c)
  free(c)
  return status
