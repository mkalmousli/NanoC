#include <stdio.h>
@f clamp(int x,lo,hi) int
  if x<lo
    lo
  elif x>hi
    hi
  else
    x
@f main int
  total:=0
  for i 0..10
    total+=clamp(i,2,7)
  printf("%d\n",total)
  total!=45
