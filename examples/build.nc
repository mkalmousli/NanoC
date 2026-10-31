// This example runs cc and writes build/nanoc-generated.h on a normal build.
// --check / --no-effects reject those effects before running them.
@bt {
  mkdir("build");
  write("build/nanoc-generated.h","#define GENERATED 42\n");
  emit(read("build/nanoc-generated.h"));
  version:=exec(["cc","--version"]);
  log(slice(version,0,find(version,"\n")));
}
@f main()->int => GENERATED!=42;
