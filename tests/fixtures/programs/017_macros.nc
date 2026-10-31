@macro array($name:ident,$xs:tokens...) { int $name[] = { $($xs),* }; }
@macro sum($xs:tokens...) { (0 $(+($xs))*) }
@array!(a, 1, (2+3), 4)
@fn main()->int { return a[1] != 5 || @sum!() != 0 || @sum!(1,2,3) != 6; }
