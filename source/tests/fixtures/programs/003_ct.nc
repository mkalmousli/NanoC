+ <string.h>
@tt
  name:=fresh("greet")
  message:="hello\nworld"
  emit("f "+str(name)+"() const char *\n  < "+str(quote($message))+"\n")
  emit("f main()\n  < strcmp("+str(name)+"(), "+str(quote($message))+")\n")
