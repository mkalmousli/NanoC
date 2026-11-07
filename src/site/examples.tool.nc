// Site step 2: compile examples/*.nc, write examples.json and the ex-table block.
compiler:="build/nanoc"
tracked:=split(exec(["git","ls-files","-co","--exclude-standard"]),"\n")
ex:=[]
for f tracked
  if exists(f) && len(f)>9
    if slice(f,0,9)=="examples/"
      if slice(f,len(f)-3,len(f))==".nc"
        ex=push(ex,f)
exRows:=[]
exNames:=[]
exNc:=[]
exC:=[]
maxChars:=1
for f ex
  src:=read(f)
  r:=run([compiler,f,"-o","build/site-ex.c"])
  if r[0]!=0
    fail("Example failed: "+f+"\n"+r[2])
  if r[0]==0
    out:=read("build/site-ex.c")
    nj:=replace(replace(replace(replace(src,"\\","\\\\"),"\"","\\\""),"\t","\\t"),"\n","\\n")
    cj:=replace(replace(replace(replace(out,"\\","\\\\"),"\"","\\\""),"\t","\\t"),"\n","\\n")
    exRows=push(exRows,"{\"name\":\""+f+"\",\"nc\":\""+nj+"\",\"c\":\""+cj+"\"}")
    a:=len(src)
    b:=len(out)
    exNames=push(exNames,slice(f,9,len(f)-3))
    exNc=push(exNc,a)
    exC=push(exC,b)
    if b>maxChars
      maxChars=b
write("_site/examples.json","["+join(exRows,",")+"]\n")
log("examples: "+str(len(exRows)))
bars:="<div class=\"legend\"><span><i style=\"background:var(--lime)\"></i>NanoC characters</span><span><i style=\"background:#3a3c33\"></i>Generated C characters</span></div><div class=\"bars\">"
for i range(len(exNames))
  bars+="<div class=\"bar-row\"><span>"+exNames[i]+"</span><div class=\"tr\"><i style=\"width:"+str(exNc[i]*100/maxChars)+"%\"></i><i class=\"c\" style=\"width:"+str(exC[i]*100/maxChars)+"%\"></i></div><b>"+str(exNc[i])+" vs "+str(exC[i])+"</b></div>"
write("build/blocks/ex-table.html",bars+"</div>")
