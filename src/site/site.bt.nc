// Assemble the GitHub Pages site in _site/: docs, a copy of the tracked sources
// (the explorer reads them), a file index and NanoC-vs-C compiler stats.
// From the repository root, after `cc -std=c11 build.c -o builder && ./builder build`:
//   build/nanoc src/site/site.bt.nc -o build/site.c
// It then runs examples.nc, wasm.nc and pages.nc (same folder) to finish the job.
@bt
  exec(["rm","-rf","_site"])
  mkdir("_site")
  exec(["cp","-r","docs/.","_site/"])
  write("_site/.nojekyll","")
  exec(["git","checkout-index","-a","--prefix=_site/source/"])
  tracked:=split(exec(["git","ls-files"]),"\n")
  exts:=[".nc"]
  index:=[]
  for f tracked
    for e exts
      if len(f)>len(e)
        if slice(f,len(f)-len(e),len(f))==e
          if !contains(f,"tests/corpus/")
            index=push(index,"\""+f+"\"")
  write("_site/files.json","["+join(index,",")+"]\n")
  log("files: "+str(len(index)))
  compiler:="build/nanoc"
  today:=slice(exec(["date","-u","+%F"]),0,10)
  areas:=[]
  ncFiles:=[]
  for f tracked
    if len(f)>7
      if slice(f,0,4)=="src/"
        if slice(f,len(f)-3,len(f))==".nc"
          ncFiles=push(ncFiles,f)
  tn:=0
  tb:=0
  tc:=0
  tcb:=0
  for f ncFiles
    src:=read(f)
    out:=""
    if !contains(f,".bt.nc")
      exec([compiler,f,"-o","build/site-stat.c"])
      out=read("build/site-stat.c")
    nl:=0
    for l split(src,"\n")
      if len(l)>0
        nl+=1
    cl:=0
    for l split(out,"\n")
      if len(l)>0
        cl+=1
    rest:=slice(f,4,len(f))
    area:="tools"
    if contains(rest,"/")
      area=slice(rest,0,find(rest,"/"))
    if !contains(join(areas,","),area)
      areas=push(areas,area)
    put("files:"+area,get("files:"+area,0)+1)
    put("nc:"+area,get("nc:"+area,0)+nl)
    put("c:"+area,get("c:"+area,0)+cl)
    tn+=nl
    tb+=len(src)
    tc+=cl
    tcb+=len(out)
  rows:=[]
  for a areas
    rows=push(rows,"{\"name\":\""+a+"\",\"files\":"+str(get("files:"+a,0))+",\"nc\":"+str(get("nc:"+a,0))+",\"c\":"+str(get("c:"+a,0))+"}")
  write("_site/stats.json","{\"generated\":\""+today+"\",\"files\":"+str(len(ncFiles))+",\"nc\":{\"lines\":"+str(tn)+",\"bytes\":"+str(tb)+"},\"c\":{\"lines\":"+str(tc)+",\"bytes\":"+str(tcb)+"},\"areas\":["+join(rows,",")+"]}\n")
  log("stats: "+str(tn)+" nanoc lines, "+str(tc)+" c lines")
  exec(["mkdir","-p","build/blocks"])
  for step ["examples","wasm","pages"]
    exec([compiler,"src/site/"+step+".bt.nc","-o","build/site-"+step+".c"])
