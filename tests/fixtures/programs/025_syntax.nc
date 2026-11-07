+ <vector>
f main() -> int
  std::vector<int> values{1,2,3}
  sum:=0
  for i:=0; i<3; i++
    sum+=values[i]
  return sum!=6
