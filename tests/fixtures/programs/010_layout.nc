#include <vector>
@fn count(xs:const std::vector<int>&):int = (int)xs.size()
@fn main():int =
  let xs = std::vector<int>{1,2,3}
  count(xs) != 3
