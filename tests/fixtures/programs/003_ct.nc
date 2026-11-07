+ <string.h>
@ct
  name:=fresh("greet")
  message:="hello\nworld"
  emit("f "+str(name)+"() -> const char * = "+str(quote($message))+"\n")
  emit("f main() -> int = strcmp("+str(name)+"(), "+str(quote($message))+")\n")
