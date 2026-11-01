@use std
@f main int
  total:=0
  for i 1..11 then total += i
  say "sum 1..10 =", total
  n:=27
  steps:=0
  while n != 1
    n = n % 2 ? 3 * n + 1 : n / 2
    ++steps
  say "collatz(27) takes", steps, "steps"
  0
