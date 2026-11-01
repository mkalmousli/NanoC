// Prints builtin metadata as JSON for --describe.
#include "nanoc/nanoc.h"
// Writes one builtin as JSON.
@f spec(FILE *out, const NcSpec *s) static void
  fputs("{\"name\":", out)
  nc_json_string(out, s->name)
  fputs(",\"call\":", out)
  nc_json_string(out, s->signature)
  fputs(",\"phase\":", out)
  nc_json_string(out, s->phase)
  fputc('}', out)
// Prints a topic or builtin card.
@f nc_describe(FILE *out, const char *topic) bool
  if !strcmp(topic, "asm")
    fputs(
      "{\"syntax\":\"@asm\\n  addl $5,%0\\n  out \\\"+r\\\"(n)\\n  clobber "
      "\\\"cc\\\"\",\"qualifiers\":[\"volatile\",\"inline\",\"goto\"],\"sections\":[\"out\",\"in\""
      ",\"clobber\",\"labels\"],\"rules\":\"instructions first; sections optional, ordered, once "
      "each; goto needs labels\",\"backend\":\"GNU __asm__; GCC/Clang; target "
      "ISA/ABI/constraints; C/C++\",\"templates\":\"raw instructions get newlines; quoted C "
      "strings pass through\"}\n", out)
    return true
  if *topic && strcmp(topic, "syntax") && strcmp(topic, "builtins")
    for size_t i = 0; i < nc_spec_count; ++i
      if !strcmp(topic, nc_specs[i].name)
        spec(out, &nc_specs[i])
        fputc('\n', out)
        return true
    return false
  fputs("{\"schemaVersion\":1", out)
  if !strcmp(topic, "builtins")
    fputs(",\"builtins\":[", out)
    for size_t i = 0; i < nc_spec_count; ++i
      if i
        fputc(',', out)
      spec(out, &nc_specs[i])
    fputs("]}\n", out)
    return true
  if !*topic
    fprintf(out,
      ",\"compiler\":\"nanoc\",\"version\":\"%s\",\"implementation\":\"NanoC\",\"targets\":[\"c11"
      "\",\"c++17\"],\"builtinCount\":%zu", NC_VERSION, nc_spec_count)
  fputs(
    ",\"syntax\":{\"function\":\"@f add(int a,b) int = a+b\",\"block\":\"@f main int\\n  n:=0\\n  "
    "for i 0..3\\n    n+=i\\n  n!=3\",\"macro\":\"@m twice($x)\\n  "
    "(($x)*2)\",\"blockArgument\":\"@scope\\"
    "n  statement\",\"assembly\":\"@asm\\n  nop\",\"programMacro\":\"@m id($x) = "
    "x\",\"program\":\"@ct\\n  n:=42\\n  emit(quote(int answer=$n;))\",\"implicitReturn\":\"last "
    "expression or final exhaustive if/else\",\"layout\":\"spaces; no braces, colons, semicolons "
    "or arrows required\",\"emptyParameters\":\"() optional on zero-argument "
    "definitions/macros\",\"shortcuts\":\"@inc stdio, \\\"x.h\\\"; ret x; nil; unless c; until c; "
    "loop; and/or/not\",\"emit\":\"--emit normal|mini\",\"legacySyntax\":true},\"phases\":\"bt "
    "before expansion; ct/macros during expansion; rewrite/again repeat\",\"checks\":\"expansion "
    "only; host effects disabled\",\"limits\":{\"passes\":32,\"steps\":1000000,\"zeroMeansUnlimite"
    "d\":[\"passes\",\"steps\"],\"depth\":128,\"depthCap\":512,\"bytes\":16777216}}\n", out)
  true
