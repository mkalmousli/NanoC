// Assemble the GitHub Pages site in _site/: docs, a copy of the tracked sources
// and a file index for the source browser.
// From the repository root, after `cc -std=c11 build.c -o builder && ./builder build`:
//   build/nctool src/site/site.tool.nc
// It then runs examples.nc, wasm.nc and pages.nc (same folder) to finish the job.
exec(["rm","-rf","_site"])
mkdir("_site")
exec(["cp","-r","docs/.","_site/"])
exec(["cp","src/assets/logo.svg","src/assets/favicon.svg","_site/"])
eval(read("src/dsl/gen.tool.nc"))
write("_site/.nojekyll","")
mkdir("_site/source")
tracked:=[]
for f split(exec(["git","ls-files","-co","--exclude-standard"]),"\n")
  if exists(f) && !contains(f,"\n") && !contains(f,"_site/")
    tracked=push(tracked,f)
    exec(["sh","-c","mkdir -p \"$(dirname \"$2\")\"; cp \"$1\" \"$2\"","sh",f,"_site/source/"+f])
exts:=[".nc"]
index:=[]
for f tracked
  for e exts
    if len(f)>len(e)
      if slice(f,len(f)-len(e),len(f))==e
        if !contains(f,"tests/corpus/") && len(split(f,"."))==2
          index=push(index,"\""+f+"\"")
write("_site/files.json","["+join(index,",")+"]\n")
log("files: "+str(len(index)))
exec(["mkdir","-p","build/blocks"])
exec(["build/nctool","src/docs.tool.nc"])
for step ["examples","wasm","pages"]
  exec(["build/nctool","src/site/"+step+".tool.nc"])
