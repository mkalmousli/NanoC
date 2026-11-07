// Command-line option parsing.
@lang 1
+ "nanoc/nanoc.h"

extern int nc_std;
+ <errno.h>

// Parses a positive count option.
f positive(NcContext *c, const char *s) -> static size_t
  char *end
  errno = 0
  unsigned long long n = strtoull(s, &end, 10)
  if (!*s || *s == '-' || *end || errno || !n || n > SIZE_MAX)
    nc_fail(c, 0, "expected a positive integer: %s", s)
  return (size_t)n

// Parses the command line.
f nc_options(NcContext *c, int argc, char **argv) -> NcOptions
  NcOptions o = {.input = "", .output = "-", .action = "", .command = "", .map = ""}
  bool positional = 0
  for (int i = (1), nanoc_bound_1 = (argc); i < nanoc_bound_1; ++i)
    char *arg = argv[i]
    if (i == 1 && (!strcmp(arg, "emit") || !strcmp(arg, "check") || !strcmp(arg, "expand") || !strcmp(arg, "explain") || !strcmp(arg, "inspect") || !strcmp(arg, "describe")))
      o.command = arg
      if (!strcmp(arg, "check") || !strcmp(arg, "inspect"))
        o.check = 1
      elif (!strcmp(arg, "expand") || !strcmp(arg, "explain"))
        o.trace = 1; c->tracing = 1
      elif (!strcmp(arg, "describe"))
        o.action = "--describe"
    elif (!positional && !strcmp(arg, "--json"))
      o.json = 1
    elif (!positional && !strcmp(arg, "--trace-json"))
      o.trace = 1; c->tracing = 1
    elif (!positional && !strcmp(arg, "--"))
      positional = 1
    elif (!positional && !strcmp(arg, "--check"))
      o.check = 1
    elif (!positional
                  && (
                    !strcmp(arg, "--line-directives")
                    || !strcmp(arg, "--prototypes")))
      if (!strcmp(arg, "--prototypes"))
        o.prototypes = 1
      else
        c->lines = 1
    elif (!positional
                  && (!strcmp(arg, "--help") || !strcmp(arg, "--version") || !strcmp(arg, "--describe")))
      o.action = arg
    elif (!positional
                  && (
                    !strcmp(arg, "-o") || !strcmp(arg, "--lang") || !strcmp(arg, "--emit")
                    || !strcmp(arg, "--diagnostics") || !strcmp(arg, "--std") || !strcmp(arg, "--max-depth")
                    || !strcmp(arg, "--max-steps") || !strcmp(arg, "--max-passes")
                    || !strcmp(arg, "--max-output") || !strcmp(arg, "--map") || !strcmp(arg, "--to")
                    || !strcmp(arg, "--line") || !strcmp(arg, "--symbol") || !strcmp(arg, "--generated-offset")))
      if (++i == argc)
        nc_fail(c, 0, "missing value for %s", arg)
      char *value = argv[i]
      if (!strcmp(arg, "-o"))
        o.output = value
      elif (!strcmp(arg, "--map"))
        o.map = value; c->tracing = 1
      elif (!strcmp(arg, "--to"))
        if (strcmp(value, "c"))
          nc_fail(c, 0, "emit --to requires c")
      elif (!strcmp(arg, "--line"))
        c->query_line = (int)positive(c, value)
      elif (!strcmp(arg, "--symbol"))
        c->query_symbol = value
      elif (!strcmp(arg, "--generated-offset"))
        c->query_generated = 1; c->query_offset = !strcmp(value, "0") ? 0 : positive(c, value)
      elif (!strcmp(arg, "--emit"))
        if (strcmp(value, "normal") && strcmp(value, "mini"))
          nc_fail(c, 0, "--emit requires normal or mini")
        c->mini = !strcmp(value, "mini")
      elif (!strcmp(arg, "--std"))
        nc_std = !strcmp(value, "c89") ? 89 : !strcmp(value, "c99") ? 99 : !strcmp(value, "c11") ? 11 : !strcmp(value, "c17") ? 17 : 0
        if (! nc_std)
          nc_fail(c, 0, "--std requires c89, c99, c11 or c17")
      elif (!strcmp(arg, "--lang"))
        if (strcmp(value, "c") && strcmp(value, "c++"))
          nc_fail(c, 0, "--lang requires c or c++")
        c->cpp = !strcmp(value, "c++")
      elif (!strcmp(arg, "--diagnostics"))
        if (strcmp(value, "json"))
          nc_fail(c, 0, "--diagnostics requires json")
        o.json = 1
      elif (!strcmp(arg, "--max-depth"))
        c->max_depth = positive(c, value)
      elif (!strcmp(arg, "--max-steps"))
        c->max_steps = !strcmp(value, "0") ? 0 : positive(c, value)
      elif (!strcmp(arg, "--max-passes"))
        c->max_passes = !strcmp(value, "0") ? 0 : positive(c, value)
      else
        c->max_output = positive(c, value)
    elif (!positional && *arg == '-')
      nc_fail(c, 0, "unknown option: %s", arg)
    elif (*o.input)
      nc_fail(c, 0, "expected one input file")
    else
      o.input = arg; c->file = arg
  if (!*o.action && !*o.input)
    nc_fail(c, 0, "missing input file; use --help")
  return o
