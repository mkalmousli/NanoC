+ <stdio.h>
s Pair
  left,right: int
f noop() -> void
  return
f sum(a: *int, n: int) -> int
  total := 0
  for i := 0; i < n; i++
    if a[i] < 0
      continue
    elif a[i] == 0
      break
    else
      total += a[i]
  while total > 7
    total--
  return total
f main() -> int
  int values[] = {1,2,-3,4,0,5}
  result: int = sum(values, 6)
  Pair p = {3,4}
  noop()
  if result == p.left + p.right
    if !0 && (3 ^ 1) == 2 && ~0 == -1
      puts("ok")
    else
      return 1
  else
    return 2
  return 0
