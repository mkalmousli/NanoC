#include <vector>
@fn main():int =
  std::vector<int> xs{1,2,3}
  let f = [](int n) { return n*2; }
  let text = R"tag(and "not" @fn)tag"
  f((int)xs.size()) != 6 or text[0] != 'a'
