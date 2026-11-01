// Test-case DSL: eval(read("src/dsl/cases.bt.nc")), then cases("test_name", "file.cases").
//   suite TEXT              printed when the group passes
//   case NAME               compile `nanoc`, run it, compare with `prints`
//   reject FRAGMENT         compilation must fail with FRAGMENT in the message
//   (blocks)  nanoc / prints  indented lines;  flag  cpp;  limits DEPTH STEPS OUTPUT
f ind_of(l)
  n:=0
  while n<len(l) && slice(l,n,n+1)==" "
    n+=1
  n
f cstarts(s, p)
  if len(s)<len(p)
    false
  else
    slice(s,0,len(p))==p
f cq(s) = "\""+replace(replace(replace(s,"\\","\\\\"),"\"","\\\""),"\n","\\n")+"\""
f block_text(ls)
  join(ls,"\n")+"\n"
// Emits one test call from the collected parts of a case.
f one(kind, name, nc, pr, cpp, lim)
  if kind=="case"
    want:=""
    if len(pr)>0
      want=block_text(pr)
    flag:="false"
    if cpp
      flag="true"
    "  test_program("+cq(block_text(nc))+", "+cq(want)+", "+flag+")\n"
  else
    "  test_reject("+cq(block_text(nc))+", "+cq(name)+", "+join(lim,", ")+")\n"
f cases(fn, path)
  ls:=split(read(path),"\n")
  body:=""
  title:=fn
  kind:=""
  name:=""
  nc:=[]
  pr:=[]
  cpp:=false
  lim:=["0","0","0"]
  block:=""
  for l ls
    t:=slice(l,ind_of(l),len(l))
    d:=ind_of(l)
    if len(t)==0
      d=-1
    if d==0
      if kind!=""
        body+=one(kind,name,nc,pr,cpp,lim)
      kind=""
      nc=[]
      pr=[]
      cpp=false
      lim=["0","0","0"]
      if cstarts(t,"suite ")
        title=slice(t,6,len(t))
      elif cstarts(t,"case ")
        kind="case"
        name=slice(t,5,len(t))
      elif cstarts(t,"reject ")
        kind="reject"
        name=slice(t,7,len(t))
    elif d==2
      block=t
      if t=="cpp"
        cpp=true
      elif cstarts(t,"limits ")
        lim=split(slice(t,7,len(t))," ")
    elif d<0
      d=d
    elif block=="nanoc"
      nc=push(nc,slice(l,4,len(l)))
    elif block=="prints"
      pr=push(pr,slice(l,4,len(l)))
  if kind!=""
    body+=one(kind,name,nc,pr,cpp,lim)
  "@f "+fn+" void\n"+body+"  puts("+cq("[OK] "+title)+")\n"
