@ct
  xs:=[2,3]+[5]
  i:=0
  total:=0
  while i<len(xs)
    total+=xs[i]
    i++
  if false && (1/0)
    fail("short circuit")
  if true || unknown()
    emit(quote(enum { total=$total };))
f main() -> int = total != 10
