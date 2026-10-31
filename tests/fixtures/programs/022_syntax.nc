static int calls;
int lo(void) { return ++calls - 1; }
int hi(void) { return ++calls + 1; }
@fn main()->int {
  @let sum:int = 0;
  @for (int i in lo() .. hi()) { sum += i; }
  @for (int j in 3 .. 1) { sum += j; }
  return calls != 2 || sum != 3;
}
