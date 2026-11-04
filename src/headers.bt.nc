// Writes the generated headers nanoc/nanoc.h and
// nanoc/manage.h. Types come from src/types/NAME.types.nc
// (in dependency order); prototypes come from the
// compiler itself (--prototypes) for every src module.
// Run: NC_BIN=build/nanoc NC_OUT=build/include
//   build/nanoc src/headers.bt.nc -o build/headers.c
@bt
  nc:=env("NC_BIN")
  out:=env("NC_OUT")
  exec(["mkdir","-p",out+"/nanoc"])
  mods:=split(exec(["find","src","-name","*.nc","-not","-name","*.*.nc"]),"\n")
  main:="#ifndef NC_NANOC_H\n#define NC_NANOC_H\n"
  for t ["base","host","token","core","macro","layout","eval","meta","cli"]
    main+=exec([nc,"src/types/"+t+".types.nc"])
  mg:="#ifndef NC_MANAGE_H\n#define NC_MANAGE_H\n"
  mg+=exec([nc,"src/types/manage.types.nc"])
  for m mods
    if len(m)>3
      protos:=exec([nc,"--prototypes",m])
      if contains(read(m),"\"nanoc/manage")
        mg+=protos
      else
        main+=protos
  write(out+"/nanoc/nanoc.h",main+"#endif\n")
  write(out+"/nanoc/manage.h",mg+"#endif\n")
