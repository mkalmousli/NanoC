// BT prefix + executable macro + idempotent source rewrite.
@bt { emit("#define BUILD_VALUE 40\n"); }
@m add($x,$y) => quote { (($x)+($y)) };
@ct { rewrite(rename(source(),"answer_impl","answer")); }
@f answer_impl()->int => @add(BUILD_VALUE,2);
@f main()->int => answer()!=42;
