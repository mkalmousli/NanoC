+ <stdio.h>
e Kind CIRCLE, SQUARE, TRIANGLE
s Shape
  kind: Kind
  size: double
f area(s: Shape) double
  k:=0.0
  if s.kind == CIRCLE
    k = 3.14159
  elif s.kind == SQUARE
    k = 1
  else
    k = 0.433
  < k * s.size * s.size
f main()
  Shape shapes[3] = {{CIRCLE, 1}, {SQUARE, 2}, {TRIANGLE, 3}}
  for i := 0; i < 3; i++
    printf("shape %d area %g\n", i, area(shapes[i]))
  < 0
