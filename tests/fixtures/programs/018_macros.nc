@macro generic($name:ident,$type:tokens) {
  @fn $name(a,b:$type)->$type { return a>b?a:b; }
}
@generic!(maxint,int)
@generic!(maxdouble,double)
@fn main()->int { return maxint(1,2)!=2 || maxdouble(1.5,2.5)!=2.5; }
