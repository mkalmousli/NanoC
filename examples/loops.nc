@use std
@f main int
  total:=0
  for i 1..11 then total += i
  printf("sum 1..10 = %d\n", total)
  n:=27
  steps:=0
  while n != 1
    n = n % 2 ? 3 * n + 1 : n / 2
    ++steps
  printf("collatz(27) takes %d steps\n", steps)
  0
