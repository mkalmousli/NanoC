// Page DSL (needs web.tool.nc, doc.tool.nc). One tree per widget, src/web/ui/Name.ui.nc; pages are trees in src/web/pages.
//   tag.class#id [attr=v ...] text      an element; a capitalised tag uses another widget:  Section [id=stats]
//   css  (child of an element)           declarations for that element, `&:hover | ...`, `& h2 | ...`, `@media(..)`;
//                                        other selector lines are global. Identical blocks share one generated class.
//   js   (child of an element)           code run once per element with `el` bound; `on click` + body adds a listener.
//   [as=name]                            elements other code needs: reachable as `A.name` from any js.
// `$prop` is filled from the use site's [props]; text after them is `$text`; `Slot` marks where children go
// (`@head` ... `@body` lines in the children fill `Slot head` and `Slot body`). `Html [src=file]` inlines a file.
// No class or id is ever written by hand: the build invents them and ships only what a page uses.
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
      if p<0
        ks=push(ks,w)
        vs=push(vs,"1")
      else
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
f prop(u, name)
  r:=""
  for k range(len(u[1]))
    if u[1][k]==name
      r=u[2][k]
  r
f use(t, ind, kids)
  u:=parse_use(t)
  res:=[]
  if u[0]=="Html"
    for l split(read(u[2][0]),"\n")
      res=push(res,sp(ind)+"| "+l)
  elif u[0]=="Doc"
    for l doc_ui(prop(u,"src"),has(u[1],"toc"))
      res=push(res,sp(ind)+l)
  else
    body:=read(UI+u[0]+".ui.nc")
    for k range(len(u[1]))
      body=replace(body,"$"+u[1][k],u[2][k])
    body=replace(body,"$text",u[3])
    base:=0
    for k kids
      if len(trim(k))>0 && base==0
        base=indent_of(k)
    own:=[]
    rest:=[]
    k:=0
    while k<len(kids)
      t2:=trim(kids[k])
      m:=subtree_end(kids,k,base)
      if indent_of(kids[k])==base && (t2=="css" || starts(t2,"css |") || t2=="js" || starts(t2,"on "))
        for q range(m-k)
          own=push(own,kids[k+q])
      else
        for q range(m-k)
          rest=push(rest,kids[k+q])
      k=m
    g:=groups(rest,base)
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
    for o own
      res=push(res,sp(indent_of(res[0])+2+indent_of(o)-base)+trim(o))
  res
f expand(text)
  ls:=split(text,"\n")
  out:=[]
  again:=false
  i:=0
  while i<len(ls)
    ind:=indent_of(ls[i])
    t:=trim(ls[i])
    if t=="css" || t=="js" || starts(t,"on ")
      out=push(out,ls[i])
      i+=1
      while i<len(ls) && (len(trim(ls[i]))==0 || indent_of(ls[i])>ind)
        out=push(out,ls[i])
        i+=1
    elif upper(slice(t,0,1))
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
// Rewrites an element's css block into rules for the class `sel` (the css() syntax of web.tool.nc).
f scope(items, sel)
  direct:=[]
  rules:=[]
  i:=0
  while i<len(items)
    l:=items[i]
    j:=subtree_end(items,i,0)
    kids:=dedent(slice(items,i+1,j))
    t:=trim(l)
    if starts(t,"&")
      rules=push(rules,sel+slice(l,1,len(l)))
      for k kids
        rules=push(rules,"  "+k)
    elif starts(t,"@")
      rules=push(rules,l)
      for r scope(kids,sel)
        rules=push(rules,"  "+r)
    elif contains(t," | ") || len(kids)>0
      rules=push(rules,l)
      for k kids
        rules=push(rules,"  "+k)
    else
      direct=push(direct,t)
    i=j
  res:=[]
  if len(direct)>0
    res=push(res,sel+" | "+join(direct,";"))
  for r rules
    res=push(res,r)
  res
// Allocates the next id of a kind (css or js) for this exact text.
f reg(kind, key)
  n:=str(get("g:#"+kind,0))
  put("g:#"+kind,get("g:#"+kind,0)+1)
  put("g:"+get("var:bundle","")+kind+key,n)
  n
// The class or script id for `body`; the first time, `make` text is queued in ui:css / ui:js.
f gen(kind, body)
  key:=join(body,"\n")
  n:=get("g:"+get("var:bundle","")+kind+key,"")
  if n==""
    n=reg(kind,key)
    if kind=="css"
      put("ui:css",get("ui:css","")+css_rules(n,body)+"\n")
    else
      put("ui:js",get("ui:js","")+js_fn(n,body)+"\n")
  n
f css_rules(n, body) = join(scope(body,".c"+n),"\n")
f js_fn(n, body) = "J("+n+", el =>\n  "+join(body,"\n  ")+"\n)"
eval(read("src/dsl/ui_lift.tool.nc"))
