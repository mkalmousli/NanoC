+ <stdio.h>
f parse(text: const char *) -> int
  value := 0
  sign := 1
  if *text == '-'
    sign = -1
    text++
  while *text >= '0' && *text <= '9'
    value = value * 10 + *text++ - '0'
  return sign * value
f main() -> int
  return parse("-123tail") != -123 || parse("0") != 0 || parse("42") != 42
