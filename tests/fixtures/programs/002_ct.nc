@ct {
  let xs = [2,3] + [5];
  let i = 0;
  let total = 0;
  while (i < len(xs)) { total = total + xs[i]; i = i + 1; }
  if (false && (1/0)) { emit("invalid"); }
  if (true || unknown()) { emit(quote { enum { total = $total }; }); }
  let text = "ok";
  if (text[0] == "o" && !false) { emit("int marker;"); }
}
@fn main()->int { return total != 10; }
