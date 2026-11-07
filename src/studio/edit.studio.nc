// Keyboard editing uses UTF-8 byte boundaries and shares one undo path for all mutations.
@lang 1
+ "studio.h"
// Replaces the active selection or inserts text at the cursor.
f st_insert(StFile *f,const char *text,size_t n)
  size_t lo=f->buffer.cursor<f->buffer.anchor ? f->buffer.cursor : f->buffer.anchor
  size_t hi=f->buffer.cursor>f->buffer.anchor ? f->buffer.cursor : f->buffer.anchor
  st_edit(&f->buffer,lo,hi-lo,text,n)
// Opens an in-window text prompt; no shell or project command is evaluated.
f st_prompt(StApp *a,int kind,const char *initial)
  free(a->prompt_value)
  a->prompt_value=st_copy(initial,strlen(initial))
  a->prompt=kind
// Searches forward from the current selection and wraps to the beginning.
f st_find(StApp *a)
  StFile *f=&a->files[a->active]
  st_cache(f)
  if !a->search || !*a->search
    <
  const char *p=strstr(f->text+f->buffer.cursor,a->search)
  if !p
    p=strstr(f->text,a->search)
  if p
    f->buffer.anchor=(size_t)(p-f->text)
    f->buffer.cursor=f->buffer.anchor+strlen(a->search)
    f->scroll=(int)st_line(f,f->buffer.anchor)
  else
    a->message="Search text not found"
// Accepts file, search, replacement or save-as input.
f st_accept(StApp *a)
  StFile *f=&a->files[a->active]
  if a->prompt==1
    st_open(a,a->prompt_value)
  elif a->prompt==2
    free(a->search)
    a->search=st_copy(a->prompt_value,strlen(a->prompt_value))
    st_find(a)
  elif a->prompt==3
    st_insert(f,a->prompt_value,strlen(a->prompt_value))
    st_find(a)
  elif a->prompt==4
    free(f->path)
    f->path=st_copy(a->prompt_value,strlen(a->prompt_value))
    st_save(a)
  a->prompt=0
// Handles prompt entry separately from source editing.
f st_prompt_keys(StApp *a)
  int code=GetCharPressed()
  while code
    int bytes=0
    const char *encoded=CodepointToUTF8(code,&bytes)
    size_t n=strlen(a->prompt_value)
    a->prompt_value=realloc(a->prompt_value,n+(size_t)bytes+1)
    memcpy(a->prompt_value+n,encoded,(size_t)bytes)
    a->prompt_value[n+(size_t)bytes]=0
    code=GetCharPressed()
  if IsKeyPressed(KEY_BACKSPACE)
    a->prompt_value[st_prev(a->prompt_value,strlen(a->prompt_value))]=0
  if IsKeyPressed(KEY_ENTER)
    st_accept(a)
  if IsKeyPressed(KEY_ESCAPE)
    a->prompt=0
// Completes the current identifier against earlier identifiers in the file.
f st_complete(StApp *a)
  StFile *f=&a->files[a->active]
  st_cache(f)
  size_t end=f->buffer.cursor,start=end
  while start && (isalnum((unsigned char)f->text[start-1]) || f->text[start-1]=='_')
    --start
  if start==end
    <
  for size_t i=0; i<start; ++i
    if i && (isalnum((unsigned char)f->text[i-1]) || f->text[i-1]=='_')
      ^
    size_t n=0
    while isalnum((unsigned char)f->text[i+n]) || f->text[i+n]=='_'
      ++n
    if n>end-start && !strncmp(f->text+i,f->text+start,end-start)
      st_edit(&f->buffer,start,end-start,f->text+i,n)
      <
// Handles navigation, selections, clipboard, auto-indentation and history.
f st_edit_keys(StApp *a)
  StFile *f=&a->files[a->active]
  st_cache(f)
  StBuffer *b=&f->buffer
  bool ctrl=IsKeyDown(KEY_LEFT_CONTROL)||IsKeyDown(KEY_RIGHT_CONTROL)||IsKeyDown(KEY_LEFT_SUPER)
  bool shift=IsKeyDown(KEY_LEFT_SHIFT)||IsKeyDown(KEY_RIGHT_SHIFT)
  if ctrl
    if IsKeyPressed(KEY_A)
      b->anchor=0
      b->cursor=strlen(f->text)
    if IsKeyPressed(KEY_Z)
      st_history(b,shift)
    if IsKeyPressed(KEY_Y)
      st_history(b,true)
    if IsKeyPressed(KEY_C)||IsKeyPressed(KEY_X)
      size_t lo=b->cursor<b->anchor ? b->cursor : b->anchor
      size_t hi=b->cursor>b->anchor ? b->cursor : b->anchor
      char *selection=st_copy(f->text+lo,hi-lo)
      SetClipboardText(selection)
      free(selection)
      if IsKeyPressed(KEY_X)
        st_insert(f,"",0)
    if IsKeyPressed(KEY_V)
      const char *s=GetClipboardText()
      if s
        st_insert(f,s,strlen(s))
    if IsKeyPressed(KEY_B)
      size_t match=st_bracket(f)
      if match!=SIZE_MAX
        b->cursor=b->anchor=match
        f->scroll=(int)st_line(f,match)
    if IsKeyPressed(KEY_SPACE)
      st_complete(a)
    <
  size_t old=b->cursor,line=st_line(f,b->cursor),column=b->cursor-f->lines[line]
  if IsKeyPressedRepeat(KEY_LEFT)||IsKeyPressed(KEY_LEFT)
    b->cursor=st_prev(f->text,b->cursor)
  if IsKeyPressedRepeat(KEY_RIGHT)||IsKeyPressed(KEY_RIGHT)
    b->cursor=st_next(f->text,b->cursor)
  if IsKeyPressedRepeat(KEY_UP)||IsKeyPressed(KEY_UP)
    if line
      b->cursor=f->lines[line-1]+(column<f->lines[line]-f->lines[line-1]-1 ? column : f->lines[line]-f->lines[line-1]-1)
  if IsKeyPressedRepeat(KEY_DOWN)||IsKeyPressed(KEY_DOWN)
    if line+1<f->line_n
      size_t width=f->lines[line+2]-f->lines[line+1]
      b->cursor=f->lines[line+1]+(column<width ? column : width ? width-1 : 0)
  if IsKeyPressed(KEY_HOME)
    b->cursor=f->lines[line]
  if IsKeyPressed(KEY_END)
    b->cursor=f->lines[line+1]-(f->lines[line+1] && f->text[f->lines[line+1]-1]=='\n' ? 1 : 0)
  while b->cursor && ((unsigned char)f->text[b->cursor]&192)==128
    --b->cursor
  if old!=b->cursor && !shift
    b->anchor=b->cursor
  if IsKeyPressed(KEY_BACKSPACE)||IsKeyPressedRepeat(KEY_BACKSPACE)
    if b->anchor==b->cursor
      b->anchor=st_prev(f->text,b->cursor)
    st_insert(f,"",0)
  elif IsKeyPressed(KEY_DELETE)||IsKeyPressedRepeat(KEY_DELETE)
    if b->anchor==b->cursor
      b->anchor=st_next(f->text,b->cursor)
    st_insert(f,"",0)
  elif IsKeyPressed(KEY_ENTER)
    size_t indent=0,start=f->lines[line]
    while f->text[start+indent]==' '
      ++indent
    char *text=st_alloc(indent+2)
    text[0]='\n'
    memset(text+1,' ',indent)
    st_insert(f,text,indent+1)
    free(text)
  elif IsKeyPressed(KEY_TAB)
    st_insert(f,"  ",2)
  int code=GetCharPressed()
  while code
    int bytes=0
    const char *text=CodepointToUTF8(code,&bytes)
    st_insert(f,text,(size_t)bytes)
    code=GetCharPressed()
