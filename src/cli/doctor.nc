// Machine-readable environment discovery, without executing project-supplied commands.
@lang 1
+ "nanoc/nanoc.h"
+ "nanoc/manage.h"
// Reports actual compiler availability and optional dependency boundaries.
f nc_doctor(NcContext *c,int argc,char **argv) int
  const char *compiler=getenv("CC")
  if !compiler || !*compiler
    compiler="cc"
  for int i=2; i<argc; ++i
    if strcmp(argv[i],"--json")
      nc_fail(c,0,"doctor accepts only --json")
  const char *args[]={compiler,"--version",NULL}
  NcProcess result=nc_process(c,args)
  NcJson w
  jw_start(&w,stdout)
  jw_open(&w,'{')
  jw_ki(&w,"schemaVersion",1)
  jw_ks(&w,"version",NC_VERSION)
  jw_ks(&w,"cCompiler",compiler)
  jw_kb(&w,"cCompilerAvailable",result.status==0)
  jw_ks(&w,"cCompilerVersion",result.out)
  jw_ks(&w,"cCompilerError",result.err)
  jw_kb(&w,"conservativeConversion",true)
  jw_ks(&w,"compactConversion","optional Python 3 and Clang AST")
  jw_ks(&w,"modelTokenCounts","optional tiktoken==0.8.0; NANOC_PYTHON selects interpreter")
  jw_ks(&w,"studio","optional separate raylib executable")
  jw_ks(&w,"validation","expansion check does not validate C semantics")
  jw_close(&w,'}')
  fputc('\n',stdout)
  < result.status ? 1 : 0
// Runs explicit test translation units independently and emits a deterministic JSON summary.
f nc_test_command(NcContext *c,int argc,char **argv) int
  NcStrings files={0}
  for int i=2; i<argc; ++i
    if strcmp(argv[i],"--json")
      NC_PUSH(c,files,argv[i])
  if !files.n
    nc_fail(c,0,"test requires explicit test entry files; each must define main")
  NcJson w
  jw_start(&w,stdout)
  jw_open(&w,'{')
  jw_ki(&w,"schemaVersion",1)
  jw_key(&w,"tests")
  jw_open(&w,'[')
  size_t failed=0
  for size_t i=0; i<files.n; ++i
    const char *args[]={c->executable,"run",files.v[i],"--json","-o",nc_format(c,"build/nanoc-test-%zu",i),NULL}
    NcProcess result=nc_process(c,args)
    failed+=result.status!=0
    jw_open(&w,'{')
    jw_ks(&w,"file",files.v[i])
    jw_ki(&w,"exitCode",result.status)
    jw_ks(&w,"stdout",result.out)
    jw_ks(&w,"stderr",result.err)
    jw_close(&w,'}')
  jw_close(&w,']')
  jw_ki(&w,"passed",(long)(files.n-failed))
  jw_ki(&w,"failed",(long)failed)
  jw_close(&w,'}')
  fputc('\n',stdout)
  < failed ? 1 : 0
