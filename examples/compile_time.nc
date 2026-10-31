#include <stdio.h>
@ct
  f square(n) = n*n
  for i 1..5
    emit("@f square_"+str(i)+" int = "+str(square(i))+"\n")
@f main int
  sum:=0
  for i 0..4
    sum+=i
  printf("sum=%d, square_4=%d\n",sum,square_4())
  0
