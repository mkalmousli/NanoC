@ct
  f factorial(n)
    if n <= 1
      1
    else
      n*factorial(n-1)
  for i range(1,5)
    name:=ident("value"+str(i))
    value:=factorial(i)
    emit(quote(enum { $name=$value };))
f main() -> int = value1 != 1 || value4 != 24
