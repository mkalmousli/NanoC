// HTML emission helpers loaded by web.tool.nc.
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
    elif p+1<len(w) && slice(w,p+1,p+2)=="\""
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
      if len(t)>2
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
