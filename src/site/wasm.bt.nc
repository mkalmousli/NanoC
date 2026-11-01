// Site step 3: build the compiler as WebAssembly (nanoc.wasm) and write the builtins/size blocks.
@bt
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
    srcs:=split(exec(["git","ls-files","-co","--exclude-standard","bootstrap/src","web/wasm"]),"\n")
    mkdir("build/wasm")
    ok:=true
    for f srcs
      if len(f)>2
        if slice(f,len(f)-2,len(f))==".c"
          if !contains(f,"cli/main.c")
            if !contains(f,"manage_")
              if !contains(f,"host_run")
                if !contains(f,"meta/files.c")
                  o:="build/wasm/"+replace(f,"/","_")+".o"
                  r:=run(["clang","--target=wasm32","-O2","-ffreestanding","-nostdlib","-Iweb/wasm/include","-Ibootstrap/include","-c",f,"-o",o])
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
  sz:=replace(exec(["sh","-c","echo $(( $(stat -c %s _site/nanoc.wasm) / 1024 ))"]),"\n","")
  write("build/blocks/wasm-size.html",sz+" KB")
