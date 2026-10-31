@macro scoped($body:block) {
  { int $fresh(local) = 1; $body (void)$fresh(local); }
}
@fn main()->int {
  int nanoc_local_1 = 7;
  @scoped!({ nanoc_local_1++; })
  return nanoc_local_1 != 8;
}
