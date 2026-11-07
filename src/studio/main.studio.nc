// Optional NanoC Studio entry point. raylib is linked only by the explicit Studio build.
@lang 1
+ "studio.h"
// Runs a resizable editor with synchronized compiler output and persistent sessions.
f main(int argc,char **argv) -> int
  if argc>1 && !strcmp(argv[1],"--self-test")
    return st_self_test()
  bool smoke=argc>1 && !strcmp(argv[1],"--smoke")
  SetConfigFlags(FLAG_WINDOW_RESIZABLE|FLAG_WINDOW_HIGHDPI)
  InitWindow(1440,900,"NanoC Studio — v1")
  SetExitKey(KEY_NULL)
  SetTargetFPS(60)
  StApp app={0}
  app.dark=true
  app.font_size=18
  app.split=0.5f
  app.message="Ctrl+O open | Ctrl+S save | Ctrl+Enter expand | Ctrl+F search | Ctrl+H replace | Ctrl+Space complete"
  const char *font=getenv("NANOC_STUDIO_FONT")
  if !font
    font="/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
  if FileExists(font)
    int count=2048-32
    int *points=st_alloc((size_t)count*sizeof *points)
    for int i=0; i<count; ++i
      points[i]=i+32
    app.font=LoadFontEx(font,32,points,count)
    free(points)
  else
    app.font=GetFontDefault()
  SetTextureFilter(app.font.texture,TEXTURE_FILTER_BILINEAR)
  st_project(&app,".")
  if !smoke
    st_session(&app,true)
  if argc>1 && !smoke
    if DirectoryExists(argv[1])
      st_project(&app,argv[1])
    else
      st_open(&app,argv[1])
  if !app.count
    st_open(&app,smoke ? "examples/compact.nc" : "untitled.nc")
  if smoke
    st_expand(&app)
  int frames=0
  while !WindowShouldClose()
    if IsFileDropped()
      FilePathList files=LoadDroppedFiles()
      for unsigned int i=0; i<files.count; ++i
        if DirectoryExists(files.paths[i])
          st_project(&app,files.paths[i])
        else
          st_open(&app,files.paths[i])
      UnloadDroppedFiles(files)
    if app.prompt
      st_prompt_keys(&app)
    else
      st_shortcuts(&app)
      if app.focus==0 && !app.prompt
        st_edit_keys(&app)
    BeginDrawing()
    ClearBackground(app.dark ? (Color){20,25,32,255} : (Color){55,62,71,255})
    float x=8
    if st_button(&app,"Open",&x,6)
      st_prompt(&app,1,"")
    if st_button(&app,"Save",&x,6)
      st_save(&app)
    if st_button(&app,"Format",&x,6)
      st_format(&app)
    if st_button(&app,"Expand",&x,6)
      st_expand(&app)
    if st_button(&app,"Export review",&x,6)
      st_export(&app)
    if st_button(&app,"Theme (F6)",&x,6)
      app.dark=!app.dark
    if st_button(&app,"C -> NanoC",&x,6)
      st_convert(&app)
    if st_button(&app,"Results",&x,6)
      st_dashboard(&app)
    float top=app.font_size*2+34,left=220
    st_tabs(&app,left,app.font_size+23)
    float width=(float)GetScreenWidth()-left,height=(float)GetScreenHeight()-top-185
    float middle=left+width*app.split
    st_explorer(&app,(Rectangle){0,top,left-5,height})
    if app.mode==1
      st_previous_pane(&app,(Rectangle){left,top,middle-left-3,height})
    else
      st_source_pane(&app,(Rectangle){left,top,middle-left-3,height})
    DrawLine((int)middle,(int)top,(int)middle,(int)(top+height),GRAY)
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) && fabsf(GetMousePosition().x-middle)<7 && GetMousePosition().y>top
      app.split=fmaxf(0.2f,fminf(0.8f,(GetMousePosition().x-left)/width))
    st_c_pane(&app,(Rectangle){middle+3,top,(float)GetScreenWidth()-middle-3,height})
    st_inspector(&app,(Rectangle){left,top+height,width,145})
    st_label(&app,app.message,10,(float)GetScreenHeight()-29,SKYBLUE)
    if app.prompt
      Rectangle box={120,80,(float)GetScreenWidth()-240,90}
      DrawRectangleRec(box,(Color){45,55,70,255})
      const char *titles[]={"","Open path (Enter accepts, Esc cancels)","Search text","Replace selection with","Save as path"}
      st_label(&app,titles[app.prompt],box.x+12,box.y+10,SKYBLUE)
      st_label(&app,app.prompt_value,box.x+12,box.y+45,RAYWHITE)
    EndDrawing()
    if smoke && ++frames==4
      TakeScreenshot("build/studio-smoke.png")
      break
  if !smoke
    st_session(&app,false)
  if app.font.texture.id!=GetFontDefault().texture.id
    UnloadFont(app.font)
  st_dispose(&app)
  CloseWindow()
  return 0
