// Deterministic optional Studio model tests; no window or display server is required.
@lang 1
+ "studio.h"
// Checks gap-buffer edits against an independent contiguous reference and checks history.
f st_self_test() int
  StBuffer b={0}
  st_init_buffer(&b,"hello")
  char reference[8192]="hello"
  size_t n=5
  uint32_t seed=919031
  for int trial=0; trial<2000; ++trial
    seed=seed*1664525u+1013904223u
    size_t at=seed%(n+1)
    size_t remove=at<n && (seed&1) ? 1 : 0
    char text[2]={(char)('a'+seed%26),0}
    st_edit(&b,at,remove,text,1)
    memmove(reference+at+1,reference+at+remove,n-at-remove+1)
    reference[at]=text[0]
    n+=1-remove
    char *actual=st_text(&b)
    if strcmp(reference,actual)
      free(actual)
      st_free_buffer(&b)
      < 1
    free(actual)
    st_history(&b,false)
    st_history(&b,true)
    actual=st_text(&b)
    if strcmp(reference,actual)
      free(actual)
      st_free_buffer(&b)
      < 2
    free(actual)
  while b.undo_at
    st_history(&b,false)
  char *original=st_text(&b)
  bool okay=!strcmp(original,"hello")
  free(original)
  st_free_buffer(&b)
  const char *unicode="a\303\251\360\237\230\200z"
  okay=okay && st_next(unicode,1)==3 && st_next(unicode,3)==7 && st_prev(unicode,7)==3
  char *large=st_alloc(4*1024*1024+1)
  memset(large,'x',4*1024*1024)
  large[4*1024*1024]=0
  st_init_buffer(&b,large)
  st_edit(&b,2*1024*1024,1,"y",1)
  char *actual=st_text(&b)
  okay=okay && strlen(actual)==4*1024*1024 && actual[2*1024*1024]=='y'
  free(actual)
  free(large)
  st_free_buffer(&b)
  puts(okay ? "Studio: 2000 randomized edits, undo/redo, UTF-8 and 4 MiB buffer passed" : "Studio model tests failed")
  < okay ? 0 : 3
