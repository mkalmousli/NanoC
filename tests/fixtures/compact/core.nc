+ <stdio.h>
s Pair
  left,right: int
f noop()
  <
f sum(a: *int, n: int) int
  total := 0
  for i := 0; i < n; i++
    if a[i] < 0
      ^
    elif a[i] == 0
      !
    else
      total += a[i]
  while total > 7
    total--
  < total
f main()
  int values[] = {1,2,-3,4,0,5}
  result: int = sum(values, 6)
  Pair p = {3,4}
  noop()
  if result == p.left + p.right
    if !0 && (3 ^ 1) == 2 && ~0 == -1
      puts("ok")
    else
      < 1
  else
    < 2
  < 0
