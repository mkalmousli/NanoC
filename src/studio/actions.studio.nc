// Explicit development actions and lexical navigation; no untrusted project task configuration.
@lang 1
+ "studio.h"
// Compiles the saved active file through the CLI; captures real compiler output for review.
f st_build(StApp *a,bool run) -> void
  st_save(a)
  StFile *f=&a->files[a->active]
  if strcmp(f->text,f->saved)
    return
  NcContext *c=calloc(1,sizeof *c)
  if !c
    exit(1)
  nc_init(c,f->path)
  const char *compiler=getenv("NANOC_STUDIO_COMPILER")
  if !compiler
    compiler="build/nanoc"
  if !setjmp(c->trap)
    const char *args[]={compiler,run ? "run" : "build",f->path,"--json",NULL}
    NcProcess result=nc_process(c,args)
    free(a->build_result)
    a->build_result=st_copy(*result.err ? result.err : result.out,strlen(*result.err ? result.err : result.out))
    a->message=result.status ? "Build/run failed; diagnostics below" : "Build/run completed; output below"
    a->mode=3
  else
    a->message="Unable to invoke CLI compiler; configure NANOC_STUDIO_COMPILER"
  nc_dispose(c)
  free(c)
// Converts the selected C buffer conservatively into a separate unsaved NanoC tab.
f st_convert(StApp *a) -> void
  StFile *f=&a->files[a->active]
  st_cache(f)
  NcContext *c=calloc(1,sizeof *c)
  if !c
    exit(1)
  nc_init(c,f->path)
  char *source=NULL
  if !setjmp(c->trap)
    char *quoted=nc_format(c,"@c %s\n",nc_quote(c,f->text))
    source=st_copy(quoted,strlen(quoted))
  nc_dispose(c)
  free(c)
  if !source
    a->message="Conversion failed; C buffer retained"
    return
  st_open(a,"converted.nc")
  StFile *target=&a->files[a->active]
  st_edit(&target->buffer,0,st_size(&target->buffer),source,strlen(source))
  free(source)
  st_expand(a)
// Navigates exact identifier matches in open tabs, with function-definition lookup on F12.
f st_navigate(StApp *a,bool definition) -> void
  StFile *f=&a->files[a->active]
  st_cache(f)
  size_t at=f->buffer.cursor,start=at,end=at
  while start && (isalnum((unsigned char)f->text[start-1]) || f->text[start-1]=='_')
    --start
  while isalnum((unsigned char)f->text[end]) || f->text[end]=='_'
    ++end
  if start==end
    return
  char *name=st_copy(f->text+start,end-start)
  for int file=0; file<a->count; ++file
    StFile *target=&a->files[file]
    st_cache(target)
    const char *p=target->text
    if !definition && file==a->active
      p+=end
    while (p=strstr(p,name))!=NULL
      bool left=p==target->text || !(isalnum((unsigned char)p[-1]) || p[-1]=='_')
      char after=p[strlen(name)]
      bool right=!(isalnum((unsigned char)after) || after=='_')
      size_t offset=(size_t)(p-target->text),line=st_line(target,offset)
      const char *head=target->text+target->lines[line]
      while *head==' '
        ++head
      bool def=head[0]=='f' && head[1]==' ' && p==head+2
      if left && right && (!definition || def)
        a->active=file
        target->buffer.anchor=offset
        target->buffer.cursor=offset+strlen(name)
        target->scroll=(int)line
        free(name)
        a->message=definition ? "Function definition in open tabs" : "Next lexical reference in open tabs"
        return
      ++p
  free(name)
  a->message="No matching definition/reference in open tabs"
// Loads real benchmark JSON without inventing missing observations.
f st_dashboard(StApp *a) -> void
  const char *path=getenv("NANOC_STUDIO_RESULTS")
  if !path
    path="research/results/final-v1.json"
  char *text=LoadFileText(path)
  free(a->benchmark)
  a->benchmark=text ? st_copy(text,strlen(text)) : st_copy("No benchmark data collected at the configured path.",51)
  if text
    UnloadFileText(text)
  a->mode=2
  a->message="Actual benchmark artifact. Agent/human outcomes are uncollected unless supplied by real trials."
// Matches parentheses, brackets or braces while skipping lexer-recognized comments and strings.
f st_bracket(StFile *f) -> size_t
  NcContext *c=calloc(1,sizeof *c)
  if !c
    return SIZE_MAX
  nc_init(c,f->path)
  size_t found=SIZE_MAX
  if !setjmp(c->trap)
    NcTokens ts=nc_lex(c,f->text,1)
    size_t at=f->buffer.cursor
    for size_t i=0; i<ts.n; ++i
      NcToken t=ts.v[i]
      if t.kind!=NC_PUNCT || t.n!=1 || (size_t)(t.s-f->text)!=at
        continue
      const char *opens="([{",*closes=")]}",*pos=strchr(opens,*t.s)
      if !pos
        break
      char close=closes[pos-opens]
      size_t depth=1
      for size_t j=i+1; j<ts.n; ++j
        NcToken next=ts.v[j]
        if next.kind!=NC_PUNCT || next.n!=1
          continue
        if *next.s==*t.s
          ++depth
        elif *next.s==close && --depth==0
          found=(size_t)(next.s-f->text)
          break
      break
  nc_dispose(c)
  free(c)
  return found
