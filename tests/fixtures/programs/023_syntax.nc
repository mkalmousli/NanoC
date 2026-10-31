@fn add(a,b:int)->int { return a+b; }
@fn main()->int {
  int (*p)(int,int) = add;
  @let x:int = p(1,2);
  @for (int i in 0..2) { @let y:int = i; x += y; }
  return x != 4;
}
