// Site step 4: compose the pages from widgets (src/web/ui); each page ships only the css and js it uses.
@bt
  eval(read("src/dsl/gen.bt.nc"))
  eval(read("src/dsl/web.bt.nc"))
  eval(read("src/dsl/ui.bt.nc"))
  put("var:built",slice(exec(["date","-u","+%F"]),0,10))
  put("var:wasmsize",read("build/blocks/wasm-size.html"))
  for p ["index","compare","play"]
    out("_site/"+p+".html",render(p))
    out("_site/"+p+".js",js(bundle("js",split(get("ui:used",""),","))))
  all:=split(get("ui:all",""),",")
  order:=["Page"]
  for i range(len(all)-2)
    order=push(order,all[len(all)-1-i])
  out("_site/style.css",css(bundle("css",order)))
  write("build/handles.txt",get("h:map",""))
  out("_site/worker.js",js(read("src/web/worker.js.nc")))
  exec(["rm","-rf","_site/blocks","_site/worker-test"])
  exec(["chmod","-R","a+rX","_site"])
  log("pages: composed from widgets")
