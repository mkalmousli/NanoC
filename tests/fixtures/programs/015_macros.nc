@macro twice($x:tokens) { (($x)+($x)) }
@macro four($x:tokens) { @twice!(@twice!($x)) }
@fn main()->int { return @four!(2+1) != 12; }
