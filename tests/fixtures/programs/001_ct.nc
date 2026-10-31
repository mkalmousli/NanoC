@ct {
  fn factorial(n) {
    if (n <= 1) { return 1; }
    return n * factorial(n-1);
  }
  for i in range(1, 5) {
    let name = ident("value" + str(i));
    let value = factorial(i);
    emit(quote { enum { $name = $value }; });
  }
}
@fn main()->int { return value1 != 1 || value4 != 24; }
