@use std
// Runs while compiling: the table below is computed by the compiler, not at run time.
@ct
  vals:=[]
  for i 0..8
    vals = push(vals, str(i * i))
  emit("static const int squares[] = {" + join(vals, ", ") + "};")
@f main int
  for i 0..8 then printf("square %d = %d\n", i, squares[i])
  0
