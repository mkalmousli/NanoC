// Visible-line rendering, lexical colors and synchronized source/C selection.
@lang 1
+ "studio.h"
// Draws UTF-8 text using the configured font and device-scaled raylib coordinates.
f st_label(StApp *a,const char *text,float x,float y,Color color)
  DrawTextEx(a->font,text,(Vector2){x,y},a->font_size,0,color)
// Chooses colors without changing or interpreting C expressions.
f st_color(const char *s,size_t n,bool comment,bool string) Color
  if comment
    < (Color){120,143,118,255}
  if string
    < (Color){222,192,128,255}
  if n && isdigit((unsigned char)*s)
    < (Color){190,162,225,255}
  const char *words[]={"f","s","u","e","if","elif","else","while","for","return","break","continue","int","char","void","const","struct","typedef",NULL}
  for int i=0; words[i]; ++i
    if strlen(words[i])==n && !strncmp(s,words[i],n)
      < (Color){120,190,224,255}
  if *s=='@' || *s=='$'
    < (Color){221,153,179,255}
  < (Color){218,222,226,255}
// Draws one line, highlighting selected byte intervals and keeping UTF-8 codepoints intact.
f st_code_line(StApp *a,const char *text,size_t n,float x,float y,size_t base,size_t lo,size_t hi,bool highlight)
  bool comment=false,string=false
  char quote=0
  size_t i=0
  float cell=MeasureTextEx(a->font,"M",a->font_size,0).x
  while i<n && text[i]!='\n' && x<(float)GetScreenWidth()
    size_t end=i+1
    if !string && text[i]=='/' && i+1<n && text[i+1]=='/'
      comment=true
    if !comment && (text[i]=='"' || text[i]=='\'') && (!i || text[i-1]!='\\')
      if !string
        quote=text[i]
        string=true
      elif quote==text[i]
        quote=0
    if isalnum((unsigned char)text[i]) || text[i]=='_'
      while end<n && (isalnum((unsigned char)text[end]) || text[end]=='_')
        ++end
    elif ((unsigned char)text[i]&128)!=0
      end=st_next(text,i)
      if end>n
        end=n
    size_t k=i
    Color color=st_color(text+i,end-i,comment,string)
    while k<end
      int bytes=0
      int code=GetCodepointNext(text+k,&bytes)
      if bytes<1
        bytes=1
      if highlight || (base+k>=lo && base+k<hi)
        DrawRectangleRec((Rectangle){x,y,cell,a->font_size+5},(Color){60,77,100,255})
      DrawTextCodepoint(a->font,code,(Vector2){x,y},a->font_size,color)
      x+=cell
      k+=(size_t)bytes
    if string && !quote
      string=false
    i=end
// Renders and operates the original source pane using the cached line index.
f st_source_pane(StApp *a,Rectangle pane)
  StFile *f=&a->files[a->active]
  st_cache(f)
  float height=a->font_size+5,cell=MeasureTextEx(a->font,"M",a->font_size,0).x
  Vector2 mouse=GetMousePosition()
  bool inside=CheckCollisionPointRec(mouse,pane)
  if inside
    f->scroll-=(int)(GetMouseWheelMove()*3)
  if f->scroll<0
    f->scroll=0
  size_t lo=f->buffer.cursor<f->buffer.anchor ? f->buffer.cursor : f->buffer.anchor
  size_t hi=f->buffer.cursor>f->buffer.anchor ? f->buffer.cursor : f->buffer.anchor
  BeginScissorMode((int)pane.x,(int)pane.y,(int)pane.width,(int)pane.height)
  float y=pane.y+5
  size_t line=(size_t)f->scroll
  while line<f->line_n && y<pane.y+pane.height-height
    size_t start=f->lines[line],end=f->lines[line+1]
    st_label(a,TextFormat("%5d",(int)line+1),pane.x+2,y,GRAY)
    bool marked=false
    if a->compiler && a->selected_event
      NcTrace *e=&a->compiler->traces.v[a->selected_event-1]
      marked=!e->synthetic && (int)line+1>=e->source.line && (int)line+1<=e->source.end_line
    st_code_line(a,f->text+start,end-start,pane.x+65-f->horizontal*cell,y,start,lo,hi,marked)
    if inside && IsMouseButtonPressed(MOUSE_BUTTON_LEFT) && mouse.y>=y && mouse.y<y+height
      a->focus=0
      size_t column=(size_t)fmaxf(0,(mouse.x-pane.x-65)/cell)+f->horizontal
      size_t at=start
      while column && at<end && f->text[at]!='\n'
        at=st_next(f->text,at)
        --column
      f->buffer.cursor=f->buffer.anchor=at
      st_select_event(a,at,false)
      if mouse.x<pane.x+60
        f->folds[line]=!f->folds[line]
    if a->focus==0 && f->buffer.cursor>=start && f->buffer.cursor<end && ((int)(GetTime()*2)%2)==0
      size_t points=0
      for size_t k=start; k<f->buffer.cursor; k=st_next(f->text,k)
        ++points
      DrawRectangle((int)(pane.x+65+((float)points-f->horizontal)*cell),(int)y,2,(int)height,SKYBLUE)
    size_t next=line+1
    if f->folds[line] && next<f->line_n
      size_t indent=0
      while f->text[start+indent]==' '
        ++indent
      while next<f->line_n
        size_t child=0,offset=f->lines[next]
        while f->text[offset+child]==' '
          ++child
        if f->text[offset+child]!='\n' && child<=indent
          !
        ++next
    line=next
    y+=height
  EndScissorMode()
// Renders generated C and lets a click reverse-select its provenance operation.
f st_c_pane(StApp *a,Rectangle pane)
  if !a->generated
    st_label(a,"Ctrl+Enter: expand current NanoC buffer",pane.x+12,pane.y+12,GRAY)
    <
  const char *text=a->generated
  size_t start=0,line=0
  float height=a->font_size+5,y=pane.y+5
  Vector2 mouse=GetMousePosition()
  bool inside=CheckCollisionPointRec(mouse,pane)
  if inside
    a->c_scroll-=(int)(GetMouseWheelMove()*3)
  if a->c_scroll<0
    a->c_scroll=0
  BeginScissorMode((int)pane.x,(int)pane.y,(int)pane.width,(int)pane.height)
  while text[start] && y<pane.y+pane.height-height
    size_t end=start
    while text[end] && text[end]!='\n'
      ++end
    if (int)line>=a->c_scroll
      if (a->mode==1 || a->mode==4) && st_line_changed(a,text,start,end,line)
        DrawRectangle((int)pane.x,(int)y,(int)pane.width,(int)height,(Color){38,65,48,255})
      st_label(a,TextFormat("%5d",(int)line+1),pane.x+2,y,GRAY)
      bool marked=false
      if a->selected_event
        NcTrace *e=&a->compiler->traces.v[a->selected_event-1]
        marked=e->start!=SIZE_MAX && start<e->end && end>=e->start
      st_code_line(a,text+start,end-start,pane.x+65,y,start,0,0,marked)
      if inside && IsMouseButtonPressed(MOUSE_BUTTON_LEFT) && mouse.y>=y && mouse.y<y+height
        a->focus=1
        st_select_event(a,start,true)
      y+=height
    start=text[end] ? end+1 : end
    ++line
  EndScissorMode()
