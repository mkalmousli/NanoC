@fn add(a,b:int)->int { return a+b; }
@fn main()->int { @let a,b:int = 3; return add(a,b) != 6; }
