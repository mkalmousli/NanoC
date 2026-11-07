// Prints builtin metadata and language cards as JSON for --describe.
@lang 1
+ "nanoc/nanoc.h"

// The static cards are written once, with the JSON DSL, and baked in as C strings at translate time.
@tt
  eval(read("src/dsl/gen.tool.nc"))
  syntax:=o(["version",r("1"),"function","f add(int a,b) int\n  a+b","returns","optional CType after name or parameter list; void by default, int for main; final expression returns","parameters","name: CType or C declarators; bare names share the preceding C type; zero arguments may omit ()","declarations","n := 0; name: CType = expression; C declarations","runtime","if/elif/else; while; for init; condition; step; < value; ! break; ^ continue","preprocessor","+stdio,stdlib or explicit headers; $ define; $- undef; ?+ ifdef; ?- ifndef; ?# if; :# elif; : else; !! error; $! pragma; dedent endif","macro","@m twice($x)\n  (($x)*2)","program","@tt\n  n:=42\n  emit(quote(int answer=$n;))","rawC","@c indented-body, balanced {tokens}, or quoted C source","layout","spaces; indented blocks; no then or block-colon spellings","emit","emit file.nc --to c --map file.map.json","trace","expand file.nc --json; explain file.nc --line N|--symbol NAME|--generated-offset BYTE"])
  limits:=o(["passes",r("32"),"steps",r("1000000"),"zeroMeansUnlimited",a(["passes","steps"]),"depth",r("128"),"depthCap",r("512"),"bytes",r("16777216")])
  emit("static const char SYNTAX[] = "+q(json(syntax))+";\n")
  emit("static const char LIMITS[] = "+q(json(limits))+";\n")
// Writes one builtin.
f spec(NcJson *w, const NcSpec *s) static void
  jw_open(w, '{')
  jw_ks(w, "name", s->name)
  jw_ks(w, "call", s->signature)
  jw_ks(w, "phase", s->phase)
  jw_close(w, '}')

// Prints a topic or builtin card.
f nc_describe(FILE *out, const char *topic) bool
  NcJson w
  jw_start(&w, out)
  if *topic && strcmp(topic, "syntax") && strcmp(topic, "builtins")
    for size_t i = (0), nanoc_bound_1 = (nc_spec_count); i < nanoc_bound_1; ++i
      if !strcmp(topic, nc_specs[i].name)
        spec(&w, &nc_specs[i])
        fputc('\n', out)
        < 1
    < 0
  jw_open(&w, '{')
  jw_ki(&w, "schemaVersion", 1)
  if !strcmp(topic, "builtins")
    jw_key(&w, "builtins")
    jw_open(&w, '[')
    for size_t i = (0), nanoc_bound_2 = (nc_spec_count); i < nanoc_bound_2; ++i
      spec(&w, &nc_specs[i])
    jw_close(&w, ']')
  else
    if !*topic
      jw_ks(&w, "compiler", "nanoc")
      jw_ks(&w, "version", NC_VERSION)
      jw_ki(&w, "lang", NC_LANG)
      jw_ks(&w, "implementation", "NanoC")
      jw_kr(&w, "targets", "[\"c89\",\"c99\",\"c11\",\"c17\",\"c++17\"]")
      jw_ki(&w, "builtinCount", (long)nc_spec_count)
      jw_kr(&w, "commands", "[\"emit\",\"check\",\"build\",\"run\",\"test\",\"convert\",\"expand\",\"explain\",\"inspect\",\"describe\",\"tokens\",\"fmt\",\"doctor\",\"bench\"]")
    jw_kr(&w, "syntax", SYNTAX)
    jw_ks(&w, "phases", "tt/macros during expansion; rewrite/again repeat")
    jw_ks(&w, "checks", "expansion only; no host writes or commands")
    jw_kr(&w, "limits", LIMITS)
  jw_close(&w, '}')
  fputc('\n', out)
  < 1
