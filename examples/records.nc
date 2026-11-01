@use std
@e Kind CIRCLE, SQUARE, TRIANGLE
@s Shape kind:Kind; size:f64
@f area(Shape s) f64
  k:=0.0
  match s.kind
    CIRCLE
      k = 3.14159
    SQUARE
      k = 1
    else
      k = 0.433
  k * s.size * s.size
@f main int
  Shape shapes[3] = {{CIRCLE, 1}, {SQUARE, 2}, {TRIANGLE, 3}}
  for i 0..3 then printf("shape %d area %g\n", i, area(shapes[i]))
  0
