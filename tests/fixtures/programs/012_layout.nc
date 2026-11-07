+ <vector>
f main()
  @c {
    std::vector<int> xs{1,2,3};
    auto f=[](int n) { return n*2; };
    auto text=R"tag(and "not" @fn)tag";
    return f((int)xs.size())!=6 || text[0]!='a';
  }
