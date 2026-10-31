#include <vector>
#include <iostream>
@f main()->int {
  auto values=std::vector<int>{1,2,3};
  int sum=0;
  for(int value:values) sum+=value;
  std::cout<<sum<<'\n';
  => 0;
}
