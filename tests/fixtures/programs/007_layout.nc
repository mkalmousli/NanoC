@fn main():int =
  var sum = 0
  let yes = true
  for i in 0..<4:
    for j:int in 0..3:
      if i == 0 or not yes:
        continue
      sum += i+j
  while sum>27:
    sum -= 1
  sum != 27
