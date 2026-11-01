@use std
@s Pair a,b:i32
@f gcd(u32 a, u32 b) u32
  b ? gcd(b, a % b) : a
@f main int
  p:Pair = {84, 36}
  small:u8 = 200
  big:i64 = 1L << 40
  say "gcd", p.a, p.b, "=", gcd(p.a, p.b)
  say "u8", small, "i64", (long)big
  0
