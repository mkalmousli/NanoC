f main()
  i:=2
  sum:=0
  if i
    for int j=i, end=i+2; j<end; j++
      sum+=j
  else
    sum=-1
  for j:=0; j<3; j++
    if j==0
      ^
    if j==2
      !
    sum++
  < sum!=6 || i!=2
