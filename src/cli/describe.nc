// Prints builtin metadata and language cards as JSON for --describe.
// The static cards are written once, with the JSON DSL, and baked in as C strings at compile time.
#include "nanoc/nanoc.h"
@ct
  eval(read("src/dsl/gen.bt.nc"))
  card:=o(["syntax","@asm\n  addl $5,%0\n  out \"+r\"(n)\n  clobber \"cc\"","qualifiers",a(["volatile","inline","goto"]),"sections",a(["out","in","clobber","labels"]),"rules","instructions first; sections optional, ordered, once each; goto needs labels","backend","GNU __asm__; GCC/Clang; target ISA/ABI/constraints; C/C++","templates","raw instructions get newlines; quoted C strings pass through"])
  syntax:=o(["function","@f add(int a,b) int = a+b","block","@f main int\n  n:=0\n  for i 0..3\n    n+=i\n  n!=3","macro","@m twice($x)\n  (($x)*2)","blockArgument","@scope\n  statement","assembly","@asm\n  nop","programMacro","@m id($x) = x","program","@ct\n  n:=42\n  emit(quote(int answer=$n;))","implicitReturn","last expression or final exhaustive if/else","layout","spaces; no braces, colons, semicolons or arrows required","emptyParameters","() optional on zero-argument definitions/macros","shortcuts","@inc stdio, \"x.h\"; ret x; nil; unless c; until c; loop; and/or/not","emit","--emit normal|mini","legacySyntax",r("true")])
  limits:=o(["passes",r("32"),"steps",r("1000000"),"zeroMeansUnlimited",a(["passes","steps"]),"depth",r("128"),"depthCap",r("512"),"bytes",r("16777216")])
  emit("static const char ASM_CARD[] = "+q(json(card))+";\n")
  emit("static const char SYNTAX[] = "+q(json(syntax))+";\n")
  emit("static const char LIMITS[] = "+q(json(limits))+";\n")
// Writes one builtin.
@f spec(NcJson *w, const NcSpec *s) static void
  jw_open(w, '{')
  jw_ks(w, "name", s->name)
  jw_ks(w, "call", s->signature)
  jw_ks(w, "phase", s->phase)
  jw_close(w, '}')
// Prints a topic or builtin card.
@f nc_describe(FILE *out, const char *topic) bool
  NcJson w
  jw_start(&w, out)
  if !strcmp(topic, "asm")
    fprintf(out, "%s\n", ASM_CARD)
    return true
  if *topic && strcmp(topic, "syntax") && strcmp(topic, "builtins")
    for size_t i = 0; i < nc_spec_count; ++i
      if !strcmp(topic, nc_specs[i].name)
        spec(&w, &nc_specs[i])
        fputc('\n', out)
        return true
    return false
  jw_open(&w, '{')
  jw_ki(&w, "schemaVersion", 1)
  if !strcmp(topic, "builtins")
    jw_key(&w, "builtins")
    jw_open(&w, '[')
    for size_t i = 0; i < nc_spec_count; ++i
      spec(&w, &nc_specs[i])
    jw_close(&w, ']')
  else
    if !*topic
      jw_ks(&w, "compiler", "nanoc")
      jw_ks(&w, "version", NC_VERSION)
      jw_ks(&w, "implementation", "NanoC")
      jw_kr(&w, "targets", "[\"c11\",\"c++17\"]")
      jw_ki(&w, "builtinCount", (long)nc_spec_count)
    jw_kr(&w, "syntax", SYNTAX)
    jw_ks(&w, "phases", "bt before expansion; ct/macros during expansion; rewrite/again repeat")
    jw_ks(&w, "checks", "expansion only; host effects disabled")
    jw_kr(&w, "limits", LIMITS)
  jw_close(&w, '}')
  fputc('\n', out)
  true
