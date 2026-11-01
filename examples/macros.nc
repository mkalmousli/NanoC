@use std
@m max($a, $b)
  (($a) > ($b) ? ($a) : ($b))
@m clamp($x, $lo, $hi)
  @max($lo, ($x) < ($hi) ? ($x) : ($hi))
@m getter($name, $field)
  @f $name(Shape *s) f64 = s->$field
@s Shape w,h:f64
@getter(width, w)
@getter(height, h)
@f main int
  s:Shape = {3, 4}
  say "max", @max(3, 9), "clamp", @clamp(15, 0, 10), @clamp(-4, 0, 10)
  say "w x h =", width(&s), height(&s)
  0
