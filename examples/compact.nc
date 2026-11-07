+ <stdio.h>
$ SQUARE(x) = ((x)*(x))
?+ _WIN32
  $ PLATFORM = "Windows"
:# defined(__linux__)
  $ PLATFORM = "Linux"
:
  $ PLATFORM = "Other"
s Point
  x,y: int
f sum(a: *int, n: int) -> int
  total := 0
  for i := 0; i < n; i++
    if a[i] < 0
      continue
    elif a[i] == 0
      break
    total += a[i]
  return total
f main() -> int
  int nums[] = {1,2,-3,4,0,5}
  result: int = sum(nums, 6)
  ?# defined(TEST)
    if result > 5
      puts(PLATFORM)
    else
      return 1
  :
    result = SQUARE(result)
  while result > 7
    result--
  return result != 7
