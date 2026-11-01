// Regenerates README.md, AGENTS.md and docs/*.md from NanoC data and prose.
// Run: build/nanoc src/docs.bt.nc -o build/docs.c   (or: ./builder docs)
@bt
  eval(read("src/dsl/gen.bt.nc"))
  eval(read("src/dsl/md.bt.nc"))
  eval(read("src/dsl/web.bt.nc"))
  eval(read("src/dsl/doc.bt.nc"))
  LIMIT:="200"
  REPO:="https://github.com/mkalmousli/NanoC"
  INSTALL:="git clone --depth 1 "+REPO+" && cd NanoC && cc -std=c11 -O2 build.c -o builder && ./builder install"
  for part ["readme","language","cards","agents"]
    eval(read("src/docs/"+part+".bt.nc"))
