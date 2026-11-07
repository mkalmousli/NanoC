f sign(n: int) -> int
  if n>0
    return 1
  elif n<0
    return -1
  else
    return 0
f main() -> int = sign(-7)!=-1 || sign(8)!=1 || sign(0)!=0
