#include <vector>
@fn main()->int {
  std::vector<int> values{1,2,3};
  @let sum:int = 0;
  @for (int i in 0 .. 3) { sum += values[i]; }
  return sum != 6;
}
