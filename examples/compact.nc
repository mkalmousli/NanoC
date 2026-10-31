#include <stdio.h>
@f clamp(int x,lo,hi)->int => x<lo?lo:x>hi?hi:x;
@f main()->int {
  int total=0;
  for(int i=0;i<10;i++) total+=clamp(i,2,7);
  printf("%d\n",total);
  => total!=45;
}
