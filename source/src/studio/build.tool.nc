// Explicit optional Studio build. Requires an existing raylib installation; never downloads dependencies.
prefix:=env("NANOC_RAYLIB_PREFIX")
flags:=""
if prefix!=""
  flags="-I"+prefix+"/include -L"+prefix+"/lib"
else
  flags=exec(["pkg-config","--cflags","--libs-only-L","raylib"])
exec(["mkdir","-p","build/studio-c"])
h:=exec(["build/nanoc","src/studio/model.types.nc"])
mods:=split(exec(["find","src/studio","-name","*.studio.nc"]),"\n")
for m mods
  if m!=""
    h+=exec(["build/nanoc","--prototypes",m])
    exec(["build/nanoc",m,"-o","build/studio-c/"+replace(slice(m,11,len(m)),".studio.nc",".c")])
write("build/studio-c/studio.h","#ifndef STUDIO_H\n#define STUDIO_H\n"+h+"#endif\n")
core:=replace(exec(["find","build/stage2/src","-name","*.c","-not","-name","main.c"]),"\n"," ")
studio:=replace(exec(["find","build/studio-c","-name","*.c"]),"\n"," ")
command:=env("CC")+" -std=c11 -D_POSIX_C_SOURCE=200809L -O2 -Wall -Wextra -Wpedantic -Werror -Ibuild/include -Ibuild/studio-c "+flags+" "+core+" "+studio+" -lraylib -lm -lpthread -ldl -lX11 -o build/nanoc-studio"
r:=sh(command)
if r[0]!=0
  fail(r[1]+r[2])
log("Built optional build/nanoc-studio")
