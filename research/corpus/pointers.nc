f reverse(values: *int, size: int) -> void
  for left := 0; left < size/2; left++
    other: int = size-left-1
    tmp: int = values[left]
    values[left] = values[other]
    values[other] = tmp
f main() -> int
  int values[] = {1,2,3,4,5}
  reverse(values, 5)
  return values[0] != 5 || values[4] != 1 || values[2] != 3
