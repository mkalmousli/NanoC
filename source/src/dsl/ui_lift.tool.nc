// Element behavior extraction and page composition for ui.tool.nc.
// Moves every element's `css`, `js` and `on` children out of the tree: the element gets a generated class
// and/or data-j attribute, the code goes to ui:css and ui:js (identical blocks are shared).
f tree_end(ic, i)
  k:=i+1
  while k<len(ic) && (ic[k]<0 || ic[k]>ic[i])
    k+=1
  k
f lift(text)
  ls:=split(text,"\n")
  tr:=[]
  ic:=[]
  for l ls
    t:=trim(l)
    tr=push(tr,t)
    if len(t)==0
      ic=push(ic,-1)
    else
      ic=push(ic,indent_of(l))
    put("sk:"+str(len(tr)-1),false)
  out:=[]
  for i range(len(ls))
    t:=tr[i]
    if !get("sk:"+str(i),false) && len(t)>0 && !starts(t,"|") && !starts(t,"//")
      end:=tree_end(ic,i)
      css:=[]
      code:=[]
      k:=i+1
      base:=-1
      while k<end
        t2:=tr[k]
        if len(t2)>0 && base<0
          base=ic[k]
        if len(t2)>0 && ic[k]==base && (t2=="css" || starts(t2,"css |") || t2=="js" || starts(t2,"on "))
          m:=tree_end(ic,k)
          body:=dedent(slice(ls,k+1,m))
          if starts(t2,"css |")
            css=push(css,trim(slice(t2,5,len(t2))))
          elif t2=="css"
            for b body
              css=push(css,b)
          elif t2=="js"
            for b body
              code=push(code,b)
          else
            code=push(code,"el.addEventListener('"+slice(t2,3,len(t2))+"', e =>")
            for b body
              code=push(code,"  "+b)
            code=push(code,")")
          for q range(m-k)
            put("sk:"+str(k+q),true)
          k=m
        else
          k+=1
      e:=head_end(t)
      h:=slice(t,0,e)
      r:=trim(slice(t,e,len(t)))
      if len(css)>0
        h+=".c"+gen("css",css)
      if len(code)>0
        d:="data-j="+gen("js",code)
        if starts(r,"[")
          r="[ "+d+" "+slice(r,1,len(r))
        else
          r="["+d+"] "+r
      r=replace(replace(r,"[as=","[data-a="),"[ as=","[ data-a=")
      out=push(out,sp(ic[i])+h+" "+r)
    elif !get("sk:"+str(i),false)
      out=push(out,ls[i])
  join(out,"\n")
// Renders one page file into html; its css and js are left in ui:css and ui:js.
f render(name)
  put("ui:css","")
  put("ui:js","")
  put("g:#css",0)
  put("g:#js",0)
  put("var:bundle",name)
  t:=lift(expand(read("src/web/pages/"+name+".html.nc")))
  for v ["built","wasmsize","bundle"]
    t=replace(t,"$"+v,get("var:"+v,""))
  html(t)
