+ <stdio.h>
s Pair a,b:int32_t
f gcd(a: u32, b: u32) -> u32
  return b ? gcd(b, a % b) : a
f main() -> int
  p:Pair = {84, 36}
  small:u8 = 200
  big:i64 = 1L << 40
  printf("gcd %d %d = %u\n", p.a, p.b, gcd(p.a, p.b))
  printf("u8 %u i64 %ld\n", small, (long)big)
  return 0
