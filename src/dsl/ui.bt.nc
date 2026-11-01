// Widgets (needs web.bt.nc). One file per widget, src/web/ui/Name.ui.nc, with its three parts together:
//   html   pug-like tree; a capitalised tag uses another widget:  Section [id=stats kicker="Measured"]
//   css    the css DSL      js   the js DSL
// `$prop` is filled from the use site's [props]; text after them is $text; `Slot` marks where children go
// (`@head` ... `@body` lines in the children fill `Slot head` and `Slot body`). `Html [src=file]` inlines a file.
// `~name` is a handle: the build invents a short class or id for it, so no names are written by hand.
// Pass one down as a prop (`Copy [id=~copyNc]`) to share an id, or give a literal to pin it.
// Only widgets a page uses are emitted, css and js included.
UI:="src/web/ui/"
f sp(n)
  r:=""
  for k range(n)
    r+=" "
  r
f upper(ch) = len(ch)>0 && find("ABCDEFGHIJKLMNOPQRSTUVWXYZ",ch)>=0
f dequote(v)
  r:=v
  if len(v)>1 && starts(v,"\"")
    r=slice(v,1,len(v)-1)
  r
f note_use(name)
  if !has(split(get("ui:used",""),","),name)
    put("ui:used",get("ui:used","")+","+name)
  if !has(split(get("ui:all",""),","),name)
    put("ui:all",get("ui:all","")+","+name)
f is_name(ch) = len(ch)>0 && find("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_",ch)>=0
f token(name)
  t:=get("h:"+name,"")
  if t==""
    n:=get("h:#",0)
    t="k"+str(n)
    put("h:#",n+1)
    put("h:"+name,t)
    put("h:map",get("h:map","")+t+" "+name+"\n")
  t
// Replaces every `~name` by its generated token.
f hs(text)
  ps:=split(text,"~")
  r:=ps[0]
  for i range(len(ps))
    p:=ps[i]
    n:=0
    while i>0 && n<len(p) && is_name(slice(p,n,n+1))
      n+=1
    if i==0
      r=r
    elif n>0 && find("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",slice(p,0,1))>=0
      r+=token(slice(p,0,n))+slice(p,n,len(p))
    else
      r+="~"+p
  r
// One part (html, css or js) of a widget file, dedented.
f part(name, kind)
  r:=[]
  on:=false
  for l split(read(UI+name+".ui.nc"),"\n")
    if len(l)>0 && slice(l,0,1)!=" "
      on=l==kind
    elif on && len(l)>=2
      r=push(r,slice(l,2,len(l)))
    elif on
      r=push(r,"")
  join(r,"\n")
// Splits `Name [k=v ...] text` into [name, keys, values, text].
f parse_use(t)
  n:=head_end(t)
  name:=slice(t,0,n)
  rest:=trim(slice(t,n,len(t)))
  ks:=[]
  vs:=[]
  if starts(rest,"[")
    z:=find(rest,"]")
    for w words(slice(rest,1,z))
      p:=find(w,"=")
      ks=push(ks,slice(w,0,p))
      vs=push(vs,dequote(slice(w,p+1,len(w))))
    rest=trim(slice(rest,z+1,len(rest)))
  [name,ks,vs,rest]
// Groups children by `@name` lines: returns [names, line-lists]; text before any `@` is "body".
f groups(kids, base)
  gn:=[]
  gl:=[]
  name:="body"
  cur:=[]
  for k kids
    t:=trim(k)
    if len(t)>1 && starts(t,"@") && indent_of(k)==base
      gn=push(gn,name)
      gl=push(gl,cur)
      name=slice(t,1,len(t))
      cur=[]
    elif len(t)>0
      cur=push(cur,k)
  gn=push(gn,name)
  gl=push(gl,cur)
  [gn,gl]
f slot_lines(g, name, base, at)
  r:=[]
  for i range(len(g[0]))
    if g[0][i]==name
      for k g[1][i]
        r=push(r,sp(at+indent_of(k)-base)+trim(k))
  r
f use(t, ind, kids)
  u:=parse_use(t)
  note_use(u[0])
  res:=[]
  if u[0]=="Html"
    for l split(read(u[2][0]),"\n")
      res=push(res,sp(ind)+"| "+l)
  else
    if get("ui:css:"+u[0],"")=="" && get("ui:js:"+u[0],"")==""
      put("ui:css:"+u[0],hs(part(u[0],"css"))+" ")
      put("ui:js:"+u[0],hs(part(u[0],"js"))+" ")
    body:=hs(part(u[0],"html"))
    for k range(len(u[1]))
      body=replace(body,"$"+u[1][k],u[2][k])
    body=replace(body,"$text",u[3])
    base:=0
    for k kids
      if len(trim(k))>0 && base==0
        base=indent_of(k)
    g:=groups(kids,base)
    for l split(body,"\n")
      if len(trim(l))>0
        t2:=trim(l)
        if t2=="Slot" || starts(t2,"Slot ")
          nm:=trim(slice(t2,4,len(t2)))
          if nm==""
            nm="body"
          for s slot_lines(g,nm,base,ind+indent_of(l))
            res=push(res,s)
        else
          res=push(res,sp(ind)+l)
  res
f expand(text)
  ls:=split(text,"\n")
  out:=[]
  again:=false
  i:=0
  while i<len(ls)
    ind:=indent_of(ls[i])
    t:=trim(ls[i])
    if upper(slice(t,0,1))
      kids:=[]
      i+=1
      while i<len(ls) && (len(trim(ls[i]))==0 || indent_of(ls[i])>ind)
        kids=push(kids,ls[i])
        i+=1
      for l use(t,ind,kids)
        out=push(out,l)
      again=true
    else
      out=push(out,ls[i])
      i+=1
  r:=join(out,"\n")
  if again
    r=expand(r)
  r
// Joins the css or js of the named widgets (first-use order).
f bundle(kind, names)
  r:=""
  for n names
    r+=get("ui:"+kind+":"+n,"")+"\n"
  r
// Renders one page file; the widgets it used are left in ui:used.
f render(name)
  put("ui:used","")
  put("var:bundle",name+".js")
  t:=expand(read("src/web/pages/"+name+".html.nc"))
  for v ["built","wasmsize","bundle"]
    t=replace(t,"$"+v,get("var:"+v,""))
  html(t)
