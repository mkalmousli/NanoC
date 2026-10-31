@fn sign(n:int):int =
  if n>0:
    1
  elif n<0:
    -1
  else:
    0
@fn main():int = sign(-7) != -1 or sign(8) != 1 or sign(0) != 0
