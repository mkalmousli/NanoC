// Content DSL: one source for the markdown docs and the website. eval after gen.bt.nc, md.bt.nc, web.bt.nc.
//   h2 / h3 text        headings            p text         paragraph      note text   aside
//   list                items, one per line table A | B     rows below, cells split by ` | `
//   code LANG [c]       verbatim lines below; `c` adds the C that nanoc generates for them, compiled while building
//   lesson id KICKER | Title    a website lesson (a plain heading in markdown); its children are nodes
// Inline: `code` and [text](url) in both targets. Render with render_doc(lines, "md") or render_doc(lines, "ui").
f esc(t) = replace(replace(replace(t,"&","&amp;"),"<","&lt;"),">","&gt;")
f inl_code(t)
  ps:=split(esc(t),"`")
  r:=ps[0]
  for i range(len(ps))
    if i>0 && i%2==1
      r+="<code>"+ps[i]+"</code>"
    elif i>0
      r+=ps[i]
  r
f inl(t)
  rest:=inl_code(t)
  r:=""
  more:=true
  while more
    m:=find(rest,"](")
    z:=m+find(slice(rest,m+2,len(rest)),")")+2
    b:=m-1
    while b>=0 && slice(rest,b,b+1)!="["
      b-=1
    if m<0 || b<0 || z<m+2
      r+=rest
      more=false
    else
      r+=slice(rest,0,b)+"<a href=\""+slice(rest,m+2,z)+"\">"+slice(rest,b+1,m)+"</a>"
      rest=slice(rest,z+1,len(rest))
  r
// The C that nanoc generates for a snippet, as lines.
f cgen(lines)
  write("build/doc-snippet.nc",join(lines,"\n")+"\n")
  r:=run(["build/nanoc","build/doc-snippet.nc","-o","build/doc-snippet.c"])
  if r[0]!=0
    fail("doc snippet does not compile: "+r[2]+join(lines,"\n"))
  out:=split(read("build/doc-snippet.c"),"\n")
  while len(out)>0 && len(trim(out[len(out)-1]))==0
    out=slice(out,0,len(out)-1)
  out
f raw_lines(lines, ind)
  r:=[]
  for l lines
    r=push(r,sp_(ind)+"| "+esc(l))
  r
f sp_(n)
  r:=""
  for k range(n)
    r+=" "
  r
f cells(t) = split(t," | ")
// One node as output lines: markdown blocks, or page-DSL lines (ui) at indent 0.
f node(h, rest, kids, ui)
  r:=[]
  if h=="h2" || h=="h3"
    hd:="## "
    if h=="h3"
      hd="### "
    if ui
      r=[h,"  | "+inl(rest)]
    else
      r=[hd+rest]
  elif h=="p"
    if ui
      r=["p","  | "+inl(rest)]
    else
      r=[rest]
  elif h=="note"
    if ui
      r=["Note","  | "+inl(rest)]
    else
      r=["> "+rest]
  elif h=="list"
    if ui
      r=["ul"]
      for k kids
        r=push(push(r,"  li"),"    | "+inl(k))
    else
      for k kids
        r=push(r,"- "+k)
      r=[join(r,"\n")]
  elif h=="table"
    head:=cells(rest)
    if ui
      r=["Table"]
      r=push(r,"  @head")
      for c head
        r=push(r,"    th "+inl(c))
      r=push(r,"  @body")
      for k kids
        r=push(r,"    tr")
        for c cells(k)
          r=push(r,"      td "+inl(c))
    else
      rows:=[]
      for k kids
        rows=push(rows,cells(k))
      r=[tbl(head,rows)]
  elif h=="code"
    ws:=split(rest," ")
    c:=len(ws)>1
    if ui && c
      r=["Pair","  @nc"]
      for l raw_lines(kids,4)
        r=push(r,l)
      r=push(r,"  @c")
      for l raw_lines(cgen(kids),4)
        r=push(r,l)
    elif ui
      r=["Code [lang="+ws[0]+"]"]
      for l raw_lines(kids,2)
        r=push(r,l)
    else
      r=[code(ws[0],kids)]
      if c
        r=push(r,code("c",cgen(kids)))
  elif h=="lesson"
    n:=get("doc:n",0)+1
    put("doc:n",n)
    w:=split(rest," | ")
    ks:=split(w[0]," ")
    if ui
      pad:=str(n)
      if n<10
        pad="0"+pad
      r=["Lesson [id="+ks[0]+" n=\""+pad+" · "+ks[1]+"\" title=\""+inl(w[1])+"\"]"]
      for l render_doc(kids,true)
        r=push(r,"  "+l)
    else
      r=["## "+w[1]]
      for b render_doc(kids,false)
        r=push(r,b)
      r=[join(r,"\n\n")]
  else
    fail("unknown doc node: "+h)
  r
// All nodes of a document (lines, already split) rendered for markdown (ui=false) or the page DSL (ui=true).
f render_doc(ls, ui)
  out:=[]
  i:=0
  while i<len(ls)
    j:=subtree_end(ls,i,indent_of(ls[i]))
    t:=trim(ls[i])
    sp:=find(t," ")
    h:=t
    rest:=""
    if sp>=0
      h=slice(t,0,sp)
      rest=slice(t,sp+1,len(t))
    for x node(h,rest,dedent(slice(ls,i+1,j)),ui)
      out=push(out,x)
    i=j
  out
// A document file rendered as markdown text.
f doc_md(path)
  put("doc:n",0)
  join(render_doc(meaningful_lines(read(path)),false),"\n\n")
// The same document as page-DSL lines. toc=true gives only its lesson index (for the sticky nav).
f doc_ui(path, toc)
  put("doc:n",0)
  ls:=meaningful_lines(read(path))
  r:=[]
  if toc
    n:=0
    for l ls
      if starts(l,"lesson ")
        n+=1
        w:=split(slice(l,7,len(l))," | ")
        pad:=str(n)
        if n<10
          pad="0"+pad
        r=push(r,"a [href=#"+split(w[0]," ")[0]+"]")
        r=push(push(r,"  span "+pad),"  | "+inl(w[len(w)-1]))
  else
    r=render_doc(ls,true)
  r
f meaningful_lines(text)
  r:=[]
  for l split(text,"\n")
    if len(trim(l))>0 && !starts(l,"//")
      r=push(r,l)
  r
