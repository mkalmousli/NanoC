+ <stdio.h>
// Runs while compiling: the table below is computed by the compiler, not at run time.
@tt
  vals:=[]
  for i 0..8
    vals = push(vals, str(i * i))
  emit("static const int squares[] = {" + join(vals, ", ") + "};")
f main()
  for i := 0; i < 8; i++
    printf("square %d = %d\n", i, squares[i])
  < 0
