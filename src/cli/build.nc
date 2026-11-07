// Explicit multi-file build and run workflows; no project command hooks or shell interpolation.
@lang 1
+ "nanoc/nanoc.h"
+ "nanoc/manage.h"
+ <errno.h>
extern int nc_std;
// Emits one input using an independent context and propagates its precise NanoC diagnostics.
f build_unit(NcContext *c,const char *input,const char *file,bool lines) -> void
  NcContext *unit=calloc(1,sizeof *unit)
  if !unit
    nc_fail(c,0,"cannot allocate compilation context")
  nc_init(unit,input)
  unit->lines=lines
  if setjmp(unit->trap)
    char *error=nc_format(c,"%s",unit->error)
    c->file=input
    c->error_span=unit->error_span
    nc_dispose(unit)
    free(unit)
    nc_fail(c,c->error_span.line,"%s",error)
  char *generated=nc_transpile(unit,nc_read(unit,input))
  nc_write(c,file,generated)
  nc_dispose(unit)
  free(unit)
// Builds C and NanoC translation units with caller-selected linking flags, then optionally executes.
f nc_build_command(NcContext *c,int argc,const char **argv) -> int
  const char *output="build/program", *compiler=getenv("CC"), *standard="c11"
  bool run=!strcmp(argv[1],"run"),json=false,lines=true,emit_only=false
  NcStrings flags={0},arguments={0},inputs={0},sources={0}
  if !compiler || !*compiler
    compiler="cc"
  for int i=2; i<argc; ++i
    const char *arg=argv[i]
    if !strcmp(arg,"--json")
      json=true
    elif !strcmp(arg,"--emit-c")
      emit_only=true
    elif !strcmp(arg,"--line-directives")
      lines=true
    elif !strcmp(arg,"-o") || !strcmp(arg,"--cc") || !strcmp(arg,"--std") || !strcmp(arg,"--cflag")
      if ++i==argc
        nc_fail(c,0,"missing value for %s",arg)
      if !strcmp(arg,"-o")
        output=argv[i]
      elif !strcmp(arg,"--cc")
        compiler=argv[i]
      elif !strcmp(arg,"--std")
        standard=argv[i]
      else
        NC_PUSH(c,flags,(char *)argv[i])
    elif !strcmp(arg,"--")
      while ++i<argc
        NC_PUSH(c,arguments,(char *)argv[i])
    elif *arg=='-'
      NC_PUSH(c,flags,(char *)arg)
    else
      NC_PUSH(c,inputs,(char *)arg)
  nc_std=!strcmp(standard,"c89") ? 89 : !strcmp(standard,"c99") ? 99 : !strcmp(standard,"c11") ? 11 : !strcmp(standard,"c17") ? 17 : 0
  if !nc_std
    nc_fail(c,0,"--std requires c89, c99, c11 or c17")
  if !inputs.n
    NC_PUSH(c,inputs,"main.nc")
  if NC_MKDIR("build") && errno!=EEXIST
    nc_fail(c,0,"cannot create build directory")
  for size_t i=0; i<inputs.n; ++i
    const char *input=inputs.v[i]
    size_t n=strlen(input)
    if n>3 && !strcmp(input+n-3,".nc")
      char *file=inputs.n==1 ? nc_format(c,"%s.c",output) : nc_format(c,"%s.%zu.c",output,i)
      build_unit(c,input,file,lines)
      NC_PUSH(c,sources,file)
      const char *slash=nc_last_separator((char *)input)
      if slash
        NC_PUSH(c,flags,nc_format(c,"-I%.*s",(int)(slash-input),input))
    else
      NC_PUSH(c,sources,(char *)input)
  if emit_only
    if json
      NcJson w
      jw_start(&w,stdout)
      jw_open(&w,'{')
      jw_ki(&w,"schemaVersion",1)
      jw_key(&w,"sources")
      nc_trace_strings(&w,sources)
      jw_close(&w,'}')
      fputc('\n',stdout)
    return 0
  NcStrings args={0}
  NC_PUSH(c,args,(char *)compiler)
  NC_PUSH(c,args,nc_format(c,"-std=%s",standard))
  NC_PUSH(c,args,"-Wall")
  NC_PUSH(c,args,"-Wextra")
  for size_t i=0; i<sources.n; ++i
    NC_PUSH(c,args,sources.v[i])
  for size_t i=0; i<flags.n; ++i
    NC_PUSH(c,args,flags.v[i])
  NC_PUSH(c,args,"-o")
  NC_PUSH(c,args,(char *)output)
  NC_PUSH(c,args,NULL)
  NcProcess result=nc_process(c,(const char **)args.v)
  const char *stage="c-compile"
  if !result.status && run
    NcStrings exec={0}
    NC_PUSH(c,exec,strchr(output,'/') || strchr(output,'\\') ? (char *)output : nc_format(c,"./%s",output))
    for size_t i=0; i<arguments.n; ++i
      NC_PUSH(c,exec,arguments.v[i])
    NC_PUSH(c,exec,NULL)
    result=nc_process(c,(const char **)exec.v)
    stage="run"
  if json
    nc_process_json(stdout,stage,result)
  else
    fputs(result.out,stdout)
    fputs(result.err,stderr)
  return result.status
