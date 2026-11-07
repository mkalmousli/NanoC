f main()
  sum:=0
  yes:=true
  for i:=0; i<4; i++
    for j:=0; j<3; j++
      if i==0 || !yes
        ^
      sum+=i+j
  while sum>27
    sum--
  < sum != 27
