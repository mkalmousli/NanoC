// Review output uses actual previous/current compiler snapshots and the language reference.
@lang 1
+ "studio.h"
// Draws a scrollable multiline build output or the compact language reference.
f st_report_pane(StApp *a,Rectangle area)
  static int scroll=0
  const char *text=a->mode==2 ? a->reference : a->build_result
  if !text
    <
  if CheckCollisionPointRec(GetMousePosition(),area)
    scroll-=(int)(GetMouseWheelMove()*3)
  if scroll<0
    scroll=0
  float y=area.y+5,height=a->font_size+5
  int line=0
  BeginScissorMode((int)area.x,(int)area.y,(int)area.width,(int)area.height)
  for const char *p=text; *p && y<area.y+area.height;
    const char *end=strchr(p,'\n')
    if !end
      end=p+strlen(p)
    if line++>=scroll
      char *label=st_copy(p,(size_t)(end-p))
      st_label(a,label,area.x+10,y,GRAY)
      free(label)
      y+=height
    p=*end ? end+1 : end
  EndScissorMode()
// Draws the previous C snapshot, paired with the current C pane in side-by-side review mode.
f st_previous_pane(StApp *a,Rectangle area)
  if !a->previous
    st_label(a,"Expand twice to compare generated C snapshots",area.x+10,area.y+10,GRAY)
    <
  const char *p=a->previous
  int line=0
  float y=area.y+5,height=a->font_size+5
  BeginScissorMode((int)area.x,(int)area.y,(int)area.width,(int)area.height)
  while *p && y<area.y+area.height-height
    const char *end=strchr(p,'\n')
    if !end
      end=p+strlen(p)
    if line>=a->c_scroll
      st_label(a,TextFormat("%5d",line+1),area.x+2,y,GRAY)
      st_code_line(a,p,(size_t)(end-p),area.x+65,y,0,0,0,false)
      y+=height
    p=*end ? end+1 : end
    ++line
  EndScissorMode()
// Reports changed same-numbered lines; this is a positional review aid, not a minimal diff algorithm.
f st_line_changed(StApp *a,const char *text,size_t start,size_t end,size_t line) bool
  if !a->previous
    < false
  const char *p=a->previous
  for size_t i=0; i<line && *p; ++i
    const char *next=strchr(p,'\n')
    p=next ? next+1 : p+strlen(p)
  const char *finish=strchr(p,'\n')
  if !finish
    finish=p+strlen(p)
  < (size_t)(finish-p)!=end-start || strncmp(text+start,p,end-start)!=0
