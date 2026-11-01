@use std, math
@c
  static double hyp(double a, double b) { return sqrt(a * a + b * b); }
@f main int
  say "hypot(3,4) =", hyp(3, 4)
  say "cbrt(27) =", cbrt(27)
  0
