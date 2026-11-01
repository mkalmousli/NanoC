extern int nc_std;
// Command-line option parsing.
@use "nanoc/nanoc", errno
// Parses a positive count option.
@f positive(NcContext *c, cstr s) static usize
  char *end
  errno = 0
  unsigned i64 n = strtoull(s, &end, 10)
  if !*s || *s == '-' || *end || errno || !n || n > SIZE_MAX
    nc_fail(c, 0, "expected a positive integer: %s", s)
  (usize)n
// Parses the command line.
@f nc_options(NcContext *c, int argc, char **argv) NcOptions
  NcOptions o = {.input = "", .output = "-", .action = ""}
  bool positional = false
  for i in 1..argc
    char *arg = argv[i]
    if !positional && !strcmp(arg, "--")
      positional = true
    elif !positional && !strcmp(arg, "--check")
      o.check = true
      c->effects = false
    elif (!positional
      and (
        !strcmp(arg, "--no-effects") || !strcmp(arg, "--line-directives")
        || !strcmp(arg, "--prototypes")))
      if !strcmp(arg, "--prototypes")
        o.prototypes = true
      elif !strcmp(arg, "--line-directives")
        c->lines = true
      else
        c->effects = false
    elif (!positional
      && (!strcmp(arg, "--help") || !strcmp(arg, "--version") || !strcmp(arg, "--describe")))
      o.action = arg
    elif (!positional
      and (
        !strcmp(arg, "-o") || !strcmp(arg, "--lang") || !strcmp(arg, "--emit")
        || !strcmp(arg, "--diagnostics") || !strcmp(arg, "--std") || !strcmp(arg, "--max-depth")
        || !strcmp(arg, "--max-steps") || !strcmp(arg, "--max-passes")
        || !strcmp(arg, "--max-output")))
      if ++i == argc
        nc_fail(c, 0, "missing value for %s", arg)
      char *value = argv[i]
      if !strcmp(arg, "-o")
        o.output = value
      elif !strcmp(arg, "--emit")
        if strcmp(value, "normal") && strcmp(value, "mini")
          nc_fail(c, 0, "--emit requires normal or mini")
        c->mini = !strcmp(value, "mini")
      elif !strcmp(arg, "--std")
        nc_std = !strcmp(value, "c89") ? 89 : !strcmp(value, "c99") ? 99 : !strcmp(value, "c11") ? 11 : !strcmp(value, "c17") ? 17 : 0
        if not nc_std
          nc_fail(c, 0, "--std requires c89, c99, c11 or c17")
      elif !strcmp(arg, "--lang")
        if strcmp(value, "c") && strcmp(value, "c++")
          nc_fail(c, 0, "--lang requires c or c++")
        c->cpp = !strcmp(value, "c++")
      elif !strcmp(arg, "--diagnostics")
        if strcmp(value, "json")
          nc_fail(c, 0, "--diagnostics requires json")
        o.json = true
      elif !strcmp(arg, "--max-depth")
        c->max_depth = positive(c, value)
      elif !strcmp(arg, "--max-steps")
        c->max_steps = !strcmp(value, "0") ? 0 : positive(c, value)
      elif !strcmp(arg, "--max-passes")
        c->max_passes = !strcmp(value, "0") ? 0 : positive(c, value)
      else
        c->max_output = positive(c, value)
    elif !positional && *arg == '-'
      nc_fail(c, 0, "unknown option: %s", arg)
    elif *o.input
      nc_fail(c, 0, "expected one input file")
    else
      o.input = arg
      c->file = arg
  if !*o.action and !*o.input
    nc_fail(c, 0, "missing input file; use --help")
  o
