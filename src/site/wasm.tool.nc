// Site step 3: build the compiler as WebAssembly (nanoc.wasm) and write the builtins/size blocks.
compiler:="build/nanoc"
names:=split(exec([compiler,"--describe","builtins"]),"{\"name\":\"")
chips:=[]
for i range(1,len(names))
  nm:=slice(names[i],0,find(names[i],"\""))
  chips=push(chips,"<code>"+nm+"</code>")
write("build/blocks/builtins.html",join(chips,""))
write("build/blocks/builtins-count.html",str(len(chips)))
wasm:="none"
lk:=sh("command -v wasm-ld || ls /usr/lib/llvm-*/bin/wasm-ld | tail -1")
if lk[0]==0
  ld:=replace(lk[1],"\n","")
  objs:=[]
  mkdir("build/wasm")
  shimc:=[]
  for f split(exec(["git","ls-files","-co","--exclude-standard","src/wasm"]),"\n")
    if len(f)>8
      if slice(f,len(f)-8,len(f))==".wasm.nc"
        c:="build/wasm/"+replace(slice(f,9,len(f)-8),"/","_")+".c"
        exec(["build/nanoc",f,"-o",c])
        shimc=push(shimc,c)
      elif slice(f,len(f)-5,len(f))==".h.nc"
        h:="build/wasm/include/"+slice(f,17,len(f)-5)+".h"
        exec(["sh","-c","mkdir -p $(dirname "+h+")"])
        exec(["build/nanoc",f,"-o",h])
  srcs:=split(exec(["find","bootstrap/src","-name","*.c"]),"\n")
  for c shimc
    srcs=push(srcs,c)
  ok:=true
  for f srcs
    if len(f)>2
      if slice(f,len(f)-2,len(f))==".c"
        if !contains(f,"cli/") || contains(f,"cli/jw.c") || contains(f,"cli/jw_values.c")
          if !contains(f,"manage_")
            if !contains(f,"host_run")
              if !contains(f,"meta/files.c")
                o:="build/wasm/"+replace(f,"/","_")+".o"
                r:=run(["clang","--target=wasm32","-O2","-ffreestanding","-nostdlib","-Ibuild/wasm/include","-Ibootstrap/include","-c",f,"-o",o])
                if r[0]!=0
                  ok=false
                  log(r[2])
                objs=push(objs,o)
  if ok
    link:=[ld,"--no-entry","--export=nc_web_transpile","--export=nc_web_output","--export=nc_web_output_len","--export=nc_web_error","--export=malloc","-z","stack-size=8388608","--initial-memory=67108864","-o","_site/nanoc.wasm"]
    for o objs
      link=push(link,o)
    r:=run(link)
    log("wasm link: "+str(r[0])+" "+r[2])
sz:=replace(exec(["sh","-c","echo $(( $(stat -c %s _site/nanoc.wasm 2>/dev/null || echo 0) / 1024 ))"]),"\n","")
write("build/blocks/wasm-size.html",sz+" KB")
