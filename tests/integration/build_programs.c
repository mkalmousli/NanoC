#include "test.h"
static void unlimited_passes(void) {
    char *path = test_path("passes.nc");
    test_write(path, "@ct {n:=get(\"n\",0);put(\"n\",n+1);if(n<64){again();}}\n@f main()->int=>0;\n");
    const char *args[] = {"build/nanoc", path, "--check", "--diagnostics", "json", "--max-passes", "0", "--max-steps", "0", NULL};
    TestResult r = test_command(args);
    CHECK(test_json(r.out) && strstr(r.out, "\"passes\":65"));
    const char *bounded[] = {"build/nanoc", path, "--check", "--max-passes", "2", NULL};
    CHECK(test_run(bounded).status != 0);
}
static void deferred_effects(void) {
    NcContext *c = test_state.mem;
    char *source = test_path("deferred.nc"), *made = test_path("deferred.txt");
    const char *template = "@m later($path){@bt{write($path,\"deferred\");}}\n@f main()->int=>0;\n";
    test_write(source, template);
    const char *check[] = {"build/nanoc", source, "--check", NULL};
    (void)test_command(check);
    CHECK(!test_exists(made));
    test_write(source, nc_format(c, "%s@later(%s)\n", template, nc_quote(c, made)));
    const char *disabled[] = {"build/nanoc", source, "--no-effects", NULL};
    CHECK(test_run(disabled).status != 0 && !test_exists(made));
    const char *run[] = {"build/nanoc", source, NULL};
    (void)test_command(run);
    CHECK(!strcmp(test_read(made), "deferred"));
    test_write(source, "@bt {exec([\"/bin/sh\",\"-c\",\"exit 9\"]);}");
    TestResult r = test_run(run);
    CHECK(r.status != 0 && strstr(r.err, "command exited 9"));
    test_write(source, "@bt {exec([\"printf\",\"%0200d\",\"0\"]);}");
    const char *limited[] = {"build/nanoc", source, "--max-output", "128", NULL};
    r = test_run(limited);
    CHECK(r.status != 0 && strstr(r.err, "output limit"));
}
void test_build_programs(void) {
    NcContext *c = test_state.mem;
    char *source = test_path("bt.nc"), *file = test_path("made.c"), *exe = test_path("made");
    char *library = test_path("library.meta"), *header = test_path("value.h");
    test_write(library, "f triple(x)=>x*3;");
    char *program = nc_format(c, "@bt {write(%s,\"#include <stdio.h>\\nint main(void){puts(\\\"17\\\");return 0;}\\n\");"
        "r:=run([\"cc\",\"-std=c11\",%s,\"-o\",%s]);assert(r[0]==0,r[2]);"
        "text:=exec([%s]);assert(text==\"17\\n\");log(\"built fixture\");"
        "r=sh(\"printf err >&2; exit 7\");assert(r[0]==7 && r[2]==\"err\");"
        "r=run([\"pwd\"],%s);assert(r[1]==%s+\"\\n\");"
        "write(%s,\"#define GENERATED 42\\n\");emit(\"#include \\\"\"+%s+\"\\\"\\n\");}\n"
        "@ct {eval(read(%s));assert(triple(14)==42);assert(contains(file(),\"bt.nc\"));}\n"
        "@f main()->int=>GENERATED!=42;\n",
        nc_quote(c, file), nc_quote(c, file), nc_quote(c, exe), nc_quote(c, exe),
        nc_quote(c, test_state.dir), nc_quote(c, test_state.dir), nc_quote(c, header), nc_quote(c, header), nc_quote(c, library));
    test_write(source, program);
    char *generated = test_path("bt.c");
    const char *check[] = {"build/nanoc", source, "--check", "--diagnostics", "json", NULL};
    TestResult r = test_run(check);
    CHECK(r.status != 0 && test_json(r.err) && strstr(r.err, "host effects disabled"));
    CHECK(!test_exists(file) && !test_exists(header));
    const char *run[] = {"build/nanoc", source, "-o", generated, "--diagnostics", "json", NULL};
    r = test_command(run);
    CHECK(!*r.out && !*r.err);
    const char *cc[] = {"cc", "-std=c11", generated, "-o", test_path("bt-program"), NULL};
    (void)test_command(cc);
    const char *binary[] = {test_path("bt-program"), NULL};
    (void)test_command(binary);
    test_write(source, "@bt {rewrite(replace(source(),\"SENT\"+\"INEL\",\"42\"));}\n@f main()->int=>SENTINEL!=42;\n");
    const char *pure[] = {"build/nanoc", source, "--check", "--diagnostics", "json", NULL};
    r = test_command(pure);
    CHECK(test_json(r.out) && strstr(r.out, "\"passes\":1"));
    unlimited_passes();
    deferred_effects();
    const char *describe[] = {"build/nanoc", "--describe", "replace", NULL};
    r = test_command(describe);
    CHECK(test_json(r.out) && strstr(r.out, "replace(text,from,to)") && strlen(r.out) < 200);
    puts("[OK] BT host commands, generated files, source edits, check isolation and unlimited passes");
}
