f add(int a, int b) int
  < a+b
f main()
  int (*p)(int,int)=add
  x: int = p(1,2)
  for i:=0; i<2; i++
    y: int = i
    x+=y
  < x!=4
