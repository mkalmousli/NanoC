// Web DSLs: eval(read("src/dsl/web.tool.nc")). Indentation replaces braces and semicolons.
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
// Lines of a block with their common indentation removed.
f dedent(ls)
  m:=-1
  for l ls
    if len(trim(l))>0 && (m<0 || indent_of(l)<m)
      m=indent_of(l)
  r:=[]
  for l ls
    if len(trim(l))>0
      r=push(r,slice(l,m,len(l)))
  r
// Lines after index i that belong to it (indented deeper than ind): the end index.
f subtree_end(ls, i, ind)
  k:=i+1
  while k<len(ls) && (len(trim(ls[k]))==0 || indent_of(ls[k])>ind)
    k+=1
  k
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
eval(read("src/dsl/web_html.tool.nc"))
