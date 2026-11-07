// Studio chrome, commands, tabs, project browser and expansion inspection.
@lang 1
+ "studio.h"
// Invokes only explicit editor actions; keyboard shortcuts mirror toolbar labels.
f st_shortcuts(StApp *a) -> void
  bool ctrl=IsKeyDown(KEY_LEFT_CONTROL)||IsKeyDown(KEY_RIGHT_CONTROL)||IsKeyDown(KEY_LEFT_SUPER)
  bool shift=IsKeyDown(KEY_LEFT_SHIFT)||IsKeyDown(KEY_RIGHT_SHIFT)
  if IsKeyPressed(KEY_F5)
    st_build(a,shift)
  if IsKeyPressed(KEY_F12)
    st_navigate(a,!shift)
  if IsKeyPressed(KEY_F6)
    a->dark=!a->dark
  if IsKeyPressed(KEY_F3)
    st_find(a)
  if ctrl
    if IsKeyPressed(KEY_O)
      st_prompt(a,1,"")
    if IsKeyPressed(KEY_S)
      if shift
        st_prompt(a,4,a->files[a->active].path)
      else
        st_save(a)
    if IsKeyPressed(KEY_F)
      st_prompt(a,2,a->search ? a->search : "")
    if IsKeyPressed(KEY_H)
      st_prompt(a,3,"")
    if IsKeyPressed(KEY_ENTER)
      st_expand(a)
    if IsKeyPressed(KEY_E)
      st_export(a)
    if IsKeyPressed(KEY_D)
      a->mode=a->mode==0 ? 1 : a->mode==1 ? 4 : 0
    if IsKeyPressed(KEY_TAB) && a->count
      a->active=(a->active+1)%a->count
      a->selected_event=0
    if IsKeyPressed(KEY_EQUAL)
      a->font_size=fminf(a->font_size+1,32)
    if IsKeyPressed(KEY_MINUS)
      a->font_size=fmaxf(a->font_size-1,12)
    if shift && IsKeyPressed(KEY_F)
      st_format(a)
// Draws a clickable toolbar action using the common font.
f st_button(StApp *a,const char *label,float *x,float y) -> bool
  float width=MeasureTextEx(a->font,label,a->font_size,0).x+20
  Rectangle box={*x,y,width,a->font_size+12}
  bool hover=CheckCollisionPointRec(GetMousePosition(),box)
  DrawRectangleRec(box,hover ? (Color){58,72,87,255} : (Color){36,43,53,255})
  st_label(a,label,*x+10,y+5,RAYWHITE)
  *x+=width+5
  return hover && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)
// Displays captures, evaluated results, generated identifiers and the parent expansion chain.
f st_inspector(StApp *a,Rectangle area) -> void
  DrawRectangleRec(area,(Color){25,31,39,255})
  if a->mode==2 || a->mode==3
    st_report_pane(a,area)
    return
  float y=area.y+6
  BeginScissorMode((int)area.x,(int)area.y,(int)area.width,(int)area.height)
  if a->compiler && a->selected_event
    NcTrace *e=&a->compiler->traces.v[a->selected_event-1]
    st_label(a,TextFormat("#%d %s %s | pass %d | %s:%d:%d%s",(int)e->id,e->rule,e->name,(int)e->pass,a->compiler->file,e->source.line,e->source.column,e->synthetic ? " (generated fragment; follow parent)" : ""),area.x+10,y,SKYBLUE)
    y+=a->font_size+6
    float x=area.x+10
    if st_button(a,"Parent expansion",&x,y)
      st_parent(a)
    y+=a->font_size+18
    for size_t i=0; i<e->captures.n && y<area.y+area.height; ++i
      st_label(a,e->captures.v[i],area.x+10,y,(Color){221,192,134,255})
      y+=a->font_size+4
    if e->result && *e->result
      st_label(a,e->result,area.x+10,y,GRAY)
  else
    st_label(a,"Click a source line or C line to inspect the expansion chain. Ctrl+E exports review artifacts.",area.x+10,y,GRAY)
  EndScissorMode()
// Draws file tabs, retaining unsaved text and making dirty state visible.
f st_tabs(StApp *a,float left,float y) -> void
  float x=left
  for int i=0; i<a->count && x<(float)GetScreenWidth()-80; ++i
    StFile *f=&a->files[i]
    st_cache(f)
    const char *name=GetFileName(f->path)
    const char *label=TextFormat("%s%s",strcmp(f->text,f->saved) ? "*" : "",name)
    if i==a->active
      DrawRectangle((int)x,(int)y,150,(int)a->font_size+12,(Color){68,79,96,255})
    if st_button(a,label,&x,y)
      a->active=i
      a->selected_event=0
// Draws a scrollable project tree; clicking a file opens a new tab.
f st_explorer(StApp *a,Rectangle area) -> void
  static int scroll=0
  if CheckCollisionPointRec(GetMousePosition(),area)
    scroll-=(int)(GetMouseWheelMove()*3)
  if scroll<0
    scroll=0
  BeginScissorMode((int)area.x,(int)area.y,(int)area.width,(int)area.height)
  float y=area.y+8
  st_label(a,"PROJECT",area.x+10,y,SKYBLUE)
  y+=a->font_size+10
  float x=area.x+10
  if st_button(a,"..",&x,y)
    st_project(a,GetPrevDirectoryPath(a->root))
  y+=a->font_size+15
  for unsigned int i=(unsigned int)scroll; i<a->explorer.count && y<area.y+area.height; ++i
    const char *name=a->explorer.paths[i]
    size_t root=strlen(a->root)
    if !strncmp(name,a->root,root) && strlen(name)>root+1
      name+=root+1
    Rectangle row={area.x,y,area.width,a->font_size+5}
    if CheckCollisionPointRec(GetMousePosition(),row) && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)
      if DirectoryExists(a->explorer.paths[i])
        st_project(a,a->explorer.paths[i])
        break
      else
        st_open(a,a->explorer.paths[i])
    st_label(a,name,area.x+10,y,GRAY)
    y+=a->font_size+5
  EndScissorMode()
