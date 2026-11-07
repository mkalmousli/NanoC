+ <stdio.h>
+ <stdint.h>
+ <inttypes.h>
s Pair a,b:int
f gcd(a: unsigned int, b: unsigned int) unsigned int
  < b ? gcd(b, a % b) : a
f main()
  p:Pair = {84, 36}
  small:uint8_t = 200
  big:int64_t = INT64_C(1) << 40
  printf("gcd %d %d = %u\n", p.a, p.b, gcd(p.a, p.b))
  printf("u8 %u i64 %" PRId64 "\n", (unsigned int)small, big)
  0
