@c { static int calls; int lo(void){return ++calls-1;} int hi(void){return ++calls+1;} }
f main() -> int
  sum:=0
  low: int = lo()
  high: int = hi()
  for i: int = low; i<high; i++
    sum+=i
  for j:=3; j<1; j++
    sum+=j
  return calls!=2 || sum!=3
