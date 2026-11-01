// Program entry: parse options, run the pipeline.
@use "nanoc/manage"
// Entry point of the nanoc CLI.
@f main(int argc, char **argv) int
  int managed = nc_manage(argc, argv)
  if managed >= 0 then return managed
  NcContext *c = calloc(1, sizeof *c)
  if not c then fputs("out of memory\n", stderr); return 1
  nc_init(c, "")
  bool json = false
  for int i = 1; i + 1 < argc; ++i
    if !strcmp(argv[i], "--") then break
    if !strcmp(argv[i], "--diagnostics") && !strcmp(argv[i + 1], "json") then json = true
  int code = 0
  if setjmp(c->trap)
    if json then nc_diagnostic(stderr, c) else fprintf(stderr, "%s\n", c->error)
    code = 1
  else
    NcOptions o = nc_options(c, argc, argv)
    if !strcmp(o.action, "--help") then nc_help(stdout)
    elif !strcmp(o.action, "--version") then puts("nanoc " NC_VERSION)
    elif !strcmp(o.action, "--describe")
      if !nc_describe(stdout, o.input) then nc_fail(c, 0, "unknown describe topic: %s", o.input)
    else
      char *generated = nc_transpile(c, nc_read(c, o.input))
      if o.prototypes then nc_prototypes(c, stdout)
      elif o.check
        if o.json then nc_report(stdout, c, strlen(generated))
      elif !strcmp(o.output, "-") then fputs(generated, stdout) else nc_write(c, o.output, generated)
      if not o.json
        for i:usize in 0..c->logs.n then fprintf(stderr, "%s\n", c->logs.v[i])
  if ferror(stdout) then code = 1
  nc_dispose(c)
  free(c)
  code
