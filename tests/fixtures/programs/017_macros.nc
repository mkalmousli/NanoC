@m array($name:ident,$xs:tokens...) { int $name[] = { $($xs),* }; }
@m sum($xs:tokens...) { (0 $(+($xs))*) }
@array(a,1,(2+3),4)
f main() -> int = a[1]!=5 || @sum()!=0 || @sum(1,2,3)!=6
