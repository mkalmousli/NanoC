@m generic($name:ident,$type:tokens)
  f $name(a: $type, b: $type) $type
    < a>b?a:b
@generic(maxint,int)
@generic(maxdouble,double)
f main()
  < maxint(1,2)!=2 || maxdouble(1.5,2.5)!=2.5
