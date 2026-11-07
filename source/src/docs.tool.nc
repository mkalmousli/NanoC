// Regenerates README.md, AGENTS.md and docs/*.md from NanoC data and prose.
// Run: build/nctool src/docs.tool.nc   (or: ./builder docs)
eval(read("src/dsl/gen.tool.nc"))
eval(read("src/dsl/md.tool.nc"))
eval(read("src/dsl/web.tool.nc"))
eval(read("src/dsl/doc.tool.nc"))
LIMIT:="200"
REPO:="https://github.com/mkalmousli/NanoC"
INSTALL:="git clone --depth 1 "+REPO+" && cd NanoC && cc -std=c11 -O2 build.c -o builder && ./builder install"
for part ["readme","language","cards","agents"]
  eval(read("src/docs/"+part+".tool.nc"))
