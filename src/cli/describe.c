#include "nanoc/cli.h"
#include "nanoc/meta.h"
static void spec(FILE *out, const NcBuiltinSpec *s) {
    fputs("{\"name\":", out);
    nc_json_string(out, s->name);
    fputs(",\"call\":", out);
    nc_json_string(out, s->signature);
    fputs(",\"phase\":", out);
    nc_json_string(out, s->phase);
    fputc('}', out);
}
bool nc_describe(FILE *out, const char *topic) {
    if (*topic && strcmp(topic, "syntax") && strcmp(topic, "builtins")) {
        for (size_t i = 0; i < nc_builtin_count; ++i) if (!strcmp(topic, nc_builtin_specs[i].name)) {
            spec(out, &nc_builtin_specs[i]);
            fputc('\n', out);
            return true;
        }
        return false;
    }
    fputs("{\"schemaVersion\":1", out);
    if (!strcmp(topic, "builtins")) {
        fputs(",\"builtins\":[", out);
        for (size_t i = 0; i < nc_builtin_count; ++i) {
            if (i) fputc(',', out);
            spec(out, &nc_builtin_specs[i]);
        }
        fputs("]}\n", out);
        return true;
    }
    if (!*topic) fprintf(out, ",\"compiler\":\"nanoc\",\"version\":\"%s\",\"implementation\":\"C11\","
        "\"targets\":[\"c11\",\"c++17\"],\"builtinCount\":%zu", NC_VERSION, nc_builtin_count);
    fputs(",\"syntax\":{\"function\":\"@f add(int a,b)->int => a+b;\","
        "\"block\":\"@f main()->int { int x=3; => x-3; }\","
        "\"macro\":\"@m twice($x) { (($x)*2) } @twice(3)\","
        "\"programMacro\":\"@m id($x) => quote { $x };\","
        "\"program\":\"@ct { x:=0; for(i:=0;i<3;i++){x+=i;} emit(quote{enum{n=$x};}); }\","
        "\"implicitReturn\":\"=> expression;\",\"legacySyntax\":true},"
        "\"phases\":\"bt before expansion; ct/macros during expansion; rewrite/again repeat\","
        "\"checks\":\"expansion only; host effects disabled\","
        "\"limits\":{\"passes\":32,\"steps\":1000000,\"zeroMeansUnlimited\":[\"passes\",\"steps\"],"
        "\"depth\":128,\"depthCap\":512,\"bytes\":16777216}}\n", out);
    return true;
}
