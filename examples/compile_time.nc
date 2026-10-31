#include <stdio.h>
@ct {
  f square(n)=>n*n;
  for(i:=1;i<5;i++) {
    name:=ident("square_"+str(i)); value:=square(i);
    emit(quote { enum { $name=$value }; });
  }
}
@f main()->int {
  int sum=0;
  for(int i=0;i<4;i++) sum+=i;
  printf("sum=%d, square_4=%d\n",sum,square_4);
  => 0;
}
