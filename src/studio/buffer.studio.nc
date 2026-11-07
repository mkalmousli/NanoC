// UTF-8 byte gap buffer with reversible edit records. Movement uses codepoint boundaries.
@lang 1
+ "studio.h"
// Aborts only on allocation failure; callers never receive a partially resized buffer.
f st_alloc(size_t bytes) void *
  void *p=malloc(bytes ? bytes : 1)
  if !p
    fputs("NanoC Studio: out of memory\n",stderr)
    exit(1)
  < p
// Copies a byte string with a terminating zero.
f st_copy(const char *text, size_t n) char *
  char *p=st_alloc(n+1)
  memcpy(p,text,n)
  p[n]=0
  < p
// Returns logical bytes excluding the gap.
f st_size(StBuffer *b) size_t
  < b->capacity-(b->end-b->gap)
// Moves the gap without changing text or logical cursor positions.
f st_gap(StBuffer *b,size_t at)
  if at<b->gap
    memmove(b->data+b->end-(b->gap-at),b->data+at,b->gap-at)
    b->end-=b->gap-at
  elif at>b->gap
    memmove(b->data+b->gap,b->data+b->end,at-b->gap)
    b->end+=at-b->gap
  b->gap=at
// Materializes a UTF-8 snapshot for save, display caching or compiler input.
f st_text(StBuffer *b) char *
  size_t n=st_size(b)
  char *p=st_alloc(n+1)
  memcpy(p,b->data,b->gap)
  memcpy(p+b->gap,b->data+b->end,b->capacity-b->end)
  p[n]=0
  < p
// Replaces a byte interval, retaining amortized linear insertion around the cursor.
f st_replace(StBuffer *b,size_t at,size_t removed,const char *text,size_t n)
  st_gap(b,at)
  b->end+=removed
  if b->end-b->gap<n
    size_t size=st_size(b), capacity=(size+n)*2+256
    char *data=st_alloc(capacity)
    if b->gap
      memcpy(data,b->data,b->gap)
    size_t tail=b->capacity-b->end
    if tail
      memcpy(data+capacity-tail,b->data+b->end,tail)
    free(b->data)
    b->data=data
    b->capacity=capacity
    b->end=capacity-tail
  memcpy(b->data+b->gap,text,n)
  b->gap+=n
  b->cursor=b->anchor=at+n
  ++b->revision
// Inserts one undoable replacement and invalidates the redo branch.
f st_edit(StBuffer *b,size_t at,size_t removed,const char *text,size_t n)
  char *old=st_text(b)
  for size_t i=b->undo_at; i<b->undo_n; ++i
    free(b->undo[i].before)
    free(b->undo[i].after)
  b->undo_n=b->undo_at
  if b->undo_n==b->undo_cap
    b->undo_cap=b->undo_cap*2+32
    b->undo=realloc(b->undo,b->undo_cap*sizeof *b->undo)
    if !b->undo
      exit(1)
  b->undo[b->undo_n++]=(StEdit){at,removed,n,st_copy(old+at,removed),st_copy(text,n)}
  b->undo_at=b->undo_n
  free(old)
  st_replace(b,at,removed,text,n)
// Replays one recorded edit in either direction without recording a new edit.
f st_history(StBuffer *b,bool redo)
  if redo && b->undo_at<b->undo_n
    StEdit *e=&b->undo[b->undo_at++]
    st_replace(b,e->at,e->removed,e->after,e->inserted)
  elif !redo && b->undo_at
    StEdit *e=&b->undo[--b->undo_at]
    st_replace(b,e->at,e->inserted,e->before,e->removed)
// Creates a fresh editor buffer with insertion reserve.
f st_init_buffer(StBuffer *b,const char *text)
  memset(b,0,sizeof *b)
  st_replace(b,0,0,text,strlen(text))
  b->revision=1
  b->cursor=b->anchor=0
// Releases buffer storage and all history entries.
f st_free_buffer(StBuffer *b)
  for size_t i=0; i<b->undo_n; ++i
    free(b->undo[i].before)
    free(b->undo[i].after)
  free(b->undo)
  free(b->data)
// Finds the previous UTF-8 codepoint boundary.
f st_prev(const char *s,size_t at) size_t
  if at
    --at
  while at && ((unsigned char)s[at]&192)==128
    --at
  < at
// Finds the next UTF-8 codepoint boundary.
f st_next(const char *s,size_t at) size_t
  if s[at]
    ++at
  while s[at] && ((unsigned char)s[at]&192)==128
    ++at
  < at
