@m maxfn($name,$type)
  @f $name($type a,b) $type = a>b?a:b
@maxfn(max_int,int)
@maxfn(max_double,double)
@f main int = max_int(2,3)!=3 || max_double(1.5,2.5)!=2.5
