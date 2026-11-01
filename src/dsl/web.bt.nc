// Web DSLs: eval(read("src/dsl/web.bt.nc")). Indentation replaces braces and semicolons.
//   css(text)  `sel | a:b;c:d` one-line rule, or a selector line owning indented declarations; `//` lines are comments.
//   js(text)   a line with deeper children opens a block, unless it ends in ( [ { , || an operator
//              (then it is a literal/continuation and a dedented line closes it by hand).
//   html(text) see html() below.
f indent_of(l)
  n:=0
  while n<len(l) && slice(l,n,n+1)==" "
    n+=1
  n
f ends(s, set)
  r:=false
  if len(s)>0
    for ch set
      if slice(s,len(s)-1,len(s))==ch
        r=true
  r
f starts(s, p) = len(s)>=len(p) && slice(s,0,len(p))==p
f meaningful(text)
  ls:=[]
  for l split(text,"\n")
    t:=trim(l)
    if len(t)>0 && !starts(t,"//")
      ls=push(ls,[indent_of(l),t])
  ls
f trim(s)
  a:=0
  z:=len(s)
  while a<z && (slice(s,a,a+1)==" " || slice(s,a,a+1)=="\t")
    a+=1
  while z>a && (slice(s,z-1,z)==" " || slice(s,z-1,z)=="\t" || slice(s,z-1,z)=="\r")
    z-=1
  slice(s,a,z)
f deeper(ls, i) = i+1<len(ls) && ls[i+1][0]>ls[i][0]
f css(text)
  ls:=meaningful(text)
  out:=[]
  st:=[]
  for i range(len(ls))
    while len(st)>0 && st[len(st)-1]>=ls[i][0]
      out=push(out,"}")
      st=slice(st,0,len(st)-1)
    if contains(ls[i][1]," | ")
      out=push(out,replace(ls[i][1]," | ","{")+"}")
    elif deeper(ls,i)
      out=push(out,ls[i][1]+"{")
      st=push(st,ls[i][0])
    else
      out=push(out,ls[i][1]+";")
  for s st
    out=push(out,"}")
  join(out,"\n")+"\n"
f js(text)
  ls:=meaningful(text)
  out:=[]
  ind:=[]
  kind:=[]
  for i range(len(ls))
    t:=ls[i][1]
    while len(ind)>0 && ind[len(ind)-1]>=ls[i][0]
      if kind[len(kind)-1]=="b"
        out=push(out,"}")
      ind=slice(ind,0,len(ind)-1)
      kind=slice(kind,0,len(kind)-1)
    inb:=len(kind)==0 || kind[len(kind)-1]!="d"
    cont:=ends(t,["(","[","{",",","+","&","|","?",":","="])
    nxt:=""
    if i+1<len(ls)
      nxt=ls[i+1][1]
    if deeper(ls,i)
      ind=push(ind,ls[i][0])
      if ends(t,["(","[","{"])
        kind=push(kind,"d")
        out=push(out,t)
      elif cont
        kind=push(kind,"c")
        out=push(out,t)
      else
        kind=push(kind,"b")
        out=push(out,t+" {")
    elif inb && !cont && !ends(t,[";"]) && !starts(nxt,".")
      out=push(out,t+";")
    else
      out=push(out,t)
  for k kind
    if k=="b"
      out=push(out,"}")
  join(out,"\n")+"\n"
// html(text): `tag.class#id [attr=value flag] inline <b>html</b> text`, children indented, `| raw text` lines.
// pre/code/textarea are tight: no whitespace is added inside them.
f words(s)
  ws:=[]
  cur:=""
  q:=false
  for k range(len(s))
    ch:=slice(s,k,k+1)
    if ch=="\""
      q=!q
    if ch==" " && !q
      if len(cur)>0
        ws=push(ws,cur)
      cur=""
    else
      cur+=ch
  if len(cur)>0
    ws=push(ws,cur)
  ws
f attr_text(a)
  r:=""
  for w words(a)
    p:=find(w,"=")
    if p<0
      r+=" "+w
    elif slice(w,p+1,p+2)=="\""
      r+=" "+w
    else
      r+=" "+slice(w,0,p)+"=\""+slice(w,p+1,len(w))+"\""
  r
f head_end(t)
  e:=0
  while e<len(t) && slice(t,e,e+1)!=" " && slice(t,e,e+1)!="["
    e+=1
  e
f has(xs, x)
  r:=false
  for y xs
    if y==x
      r=true
  r
f open_tag(t)
  h:=slice(t,0,head_end(t))
  tag:=""
  cls:=""
  id:=""
  mode:="t"
  cur:=""
  for k range(len(h)+1)
    ch:="."
    if k<len(h)
      ch=slice(h,k,k+1)
    if ch=="." || ch=="#" || k==len(h)
      if mode=="t"
        tag=cur
      elif mode=="."
        cls+=" "+cur
      else
        id=cur
      mode=ch
      cur=""
    else
      cur+=ch
  rest:=trim(slice(t,len(h),len(t)))
  attrs:=""
  if starts(rest,"[")
    z:=find(rest,"]")
    attrs=slice(rest,1,z)
    rest=trim(slice(rest,z+1,len(rest)))
  if len(id)>0
    attrs="id="+id+" "+attrs
  if len(trim(cls))>0
    attrs="class=\""+trim(cls)+"\" "+attrs
  [tag,attr_text(trim(attrs)),rest]
f html(text)
  ls:=[]
  for l split(text,"\n")
    if len(trim(l))>0 && !starts(trim(l),"//")
      ls=push(ls,[indent_of(l),slice(l,indent_of(l),len(l))])
  buf:=""
  st:=[]
  voids:=["meta","link","br","img","input","hr"]
  tights:=["pre","code","textarea","script","style"]
  tight:=0
  for i range(len(ls))
    while len(st)>0 && st[len(st)-1][0]>=ls[i][0]
      top:=st[len(st)-1]
      st=slice(st,0,len(st)-1)
      buf+="</"+top[1]+">"
      tight-=top[2]
      if tight==0
        buf+="\n"
    t:=ls[i][1]
    nxt:=-1
    if i+1<len(ls)
      nxt=ls[i+1][0]
    if starts(t,"|")
      buf+=slice(t,2,len(t))
      if tight>0
        if i+1<len(ls) && starts(ls[i+1][1],"|")
          buf+="\n"
      else
        buf+="\n"
    else
      o:=open_tag(t)
      buf+="<"+o[0]+o[1]+">"
      if has(voids,o[0])
        buf+="\n"
      elif nxt>ls[i][0]
        buf+=o[2]
        tg:=0
        if has(tights,o[0])
          tg=1
        st=push(st,[ls[i][0],o[0],tg])
        tight+=tg
        if tight==0
          buf+="\n"
      else
        buf+=o[2]+"</"+o[0]+">"
        if tight==0
          buf+="\n"
  while len(st)>0
    buf+="</"+st[len(st)-1][1]+">"
    st=slice(st,0,len(st)-1)
  buf
