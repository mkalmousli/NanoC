// Site step 4: fill {{block}} placeholders in the pages from docs/blocks/ and build/blocks/.
@bt
  today:=slice(exec(["date","-u","+%F"]),0,10)
  for n ["nav","footer","prism","lang-table"]
    put("block:"+n,read("build/blocks/"+n+".html"))
  for n ["ex-table","builtins","builtins-count","wasm-size"]
    put("block:"+n,read("build/blocks/"+n+".html"))
  put("block:built",today)
  for p ["index","compare","play"]
    t:=read("_site/"+p+".html")
    for pass range(3)
      for n ["nav","footer","prism","lang-table","ex-table","builtins","builtins-count","wasm-size","built"]
        t=replace(t,"{{"+n+"}}",get("block:"+n,""))
    write("_site/"+p+".html",t)
  exec(["rm","-rf","_site/blocks","_site/worker-test"])
  exec(["chmod","-R","a+rX","_site"])
  log("pages: assembled from blocks")
