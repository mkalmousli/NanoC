// Optional Studio model and rendering contracts; never included by the CLI compiler build.
@lang 1
+ <raylib.h>
+ <stdint.h>
+ <math.h>
+ <ctype.h>
+ <stdlib.h>
+ <string.h>
+ "nanoc/nanoc.h"
s StEdit
  at,removed,inserted: size_t
  before,after: char *
s StBuffer
  data: char *
  capacity,gap,end,cursor,anchor,revision: size_t
  undo: *StEdit
  undo_n,undo_cap,undo_at: size_t
s StFile
  path,text,saved: char *
  buffer: StBuffer
  lines: *size_t
  line_n,cached_revision: size_t
  scroll,horizontal: int
  folds: *unsigned char
s StApp
  StFile files[32]
  count,active,selected_event: int
  root,prompt_value,message,search: char *
  prompt,focus,mode: int
  font: Font
  font_size,split: float
  compiler: *NcContext
  generated,previous,reference,build_result: char *
  c_scroll,selected_c_line: int
  explorer: FilePathList
  dark,show_explorer,show_trace: bool
