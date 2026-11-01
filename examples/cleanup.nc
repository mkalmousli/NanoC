@use std
@f load(cstr path) int
  FILE *f = fopen(path, "r")
  if not f then ret -1
  defer fclose(f)
  n:=0
  while fgetc(f) != EOF then ++n
  n
@f main int
  say "bytes:", load("/dev/null")
  say "missing:", load("/no/such/file")
  0
