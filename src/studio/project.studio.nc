// Project state, indexed text snapshots and explicit file/session persistence.
@lang 1
+ "studio.h"
// Refreshes line offsets only after edits, so rendering work depends on visible lines.
f st_cache(StFile *f) -> void
  if f->text && f->cached_revision==f->buffer.revision
    return
  free(f->text)
  f->text=st_text(&f->buffer)
  size_t count=1
  for const char *p=f->text; *p; ++p
    if *p=='\n'
      ++count
  f->lines=realloc(f->lines,(count+1)*sizeof *f->lines)
  f->folds=realloc(f->folds,count+1)
  if !f->lines || !f->folds
    exit(1)
  memset(f->folds,0,count+1)
  f->line_n=1
  f->lines[0]=0
  for size_t i=0; f->text[i]; ++i
    if f->text[i]=='\n'
      f->lines[f->line_n++]=i+1
  f->lines[f->line_n]=strlen(f->text)
  f->cached_revision=f->buffer.revision
// Returns the line containing a byte offset through binary search.
f st_line(StFile *f,size_t at) -> size_t
  size_t lo=0,hi=f->line_n
  while lo+1<hi
    size_t mid=(lo+hi)/2
    if f->lines[mid]<=at
      lo=mid
    else
      hi=mid
  return lo
// Opens an existing text file or an empty untitled buffer, retaining unsaved tabs.
f st_open(StApp *a,const char *path) -> void
  for int i=0; i<a->count; ++i
    if !strcmp(a->files[i].path,path)
      a->active=i
      return
  if a->count==32
    a->message="Tab limit reached (32)"
    return
  char *text=FileExists(path) ? LoadFileText(path) : NULL
  StFile *f=&a->files[a->count]
  memset(f,0,sizeof *f)
  f->path=st_copy(path,strlen(path))
  st_init_buffer(&f->buffer,text ? text : "")
  f->saved=st_copy(text ? text : "",text ? strlen(text) : 0)
  if text
    UnloadFileText(text)
  st_cache(f)
  a->active=a->count++
  a->focus=0
// Saves only on an explicit user action, preserving the buffer when saving fails.
f st_save(StApp *a) -> void
  StFile *f=&a->files[a->active]
  st_cache(f)
  if SaveFileText(f->path,f->text)
    free(f->saved)
    f->saved=st_copy(f->text,strlen(f->text))
    a->message="Saved"
  else
    a->message="Save failed; buffer retained"
// Opens a project directory for the explorer without loading project commands.
f st_project(StApp *a,const char *root) -> void
  char *copy=st_copy(root,strlen(root))
  if a->explorer.paths
    UnloadDirectoryFiles(a->explorer)
  free(a->root)
  a->root=copy
  a->explorer=LoadDirectoryFilesEx(a->root,NULL,false)
// Persists paths and appearance; text is always saved separately and explicitly.
f st_session(StApp *a,bool restore) -> void
  const char *path=".nanoc-studio.session"
  if restore
    char *text=LoadFileText(path)
    if !text
      return
    char *p=strchr(text,'\n')
    if p
      a->dark=text[0]!='0'
      a->font_size=(float)atoi(text+2)
      for char *line=p+1; *line;
        char *end=strchr(line,'\n')
        if !end
          break
        *end=0
        if FileExists(line)
          st_open(a,line)
        line=end+1
    UnloadFileText(text)
  else
    NcBuffer b={0}
    NcContext *c=calloc(1,sizeof *c)
    nc_init(c,path)
    if !setjmp(c->trap)
      nc_printf(c,&b,"%d %d\n",a->dark,(int)a->font_size)
      for int i=0; i<a->count; ++i
        nc_printf(c,&b,"%s\n",a->files[i].path)
      (void)SaveFileText(path,b.v)
    nc_dispose(c)
    free(c)
// Frees all project, compiler and editor resources.
f st_dispose(StApp *a) -> void
  for int i=0; i<a->count; ++i
    StFile *f=&a->files[i]
    st_free_buffer(&f->buffer)
    free(f->path)
    free(f->text)
    free(f->saved)
    free(f->lines)
    free(f->folds)
  if a->compiler
    nc_dispose(a->compiler)
    free(a->compiler)
  if a->explorer.paths
    UnloadDirectoryFiles(a->explorer)
  free(a->root)
  free(a->benchmark)
  free(a->build_result)
  free(a->previous)
  free(a->prompt_value)
  free(a->search)
