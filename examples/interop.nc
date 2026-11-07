+ <stdio.h>
+ <math.h>
@c
  static double hyp(double a, double b) { return sqrt(a * a + b * b); }
f main() -> int
  printf("hypot(3,4) = %g\n", hyp(3, 4))
  printf("cbrt(27) = %g\n", cbrt(27))
  return 0
