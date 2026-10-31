@fn main()->int {
  int i = 2, sum = 0;
  if (i) @for (int i in i .. i+2) { sum += i; } else sum = -1;
  @for (int j in 0 .. 3) { if (j == 0) continue; if (j == 2) break; sum++; }
  return sum != 6 || i != 2;
}
