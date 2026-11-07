@m twice($x:tokens) { (($x)+($x)) }
@m four($x:tokens) { @twice(@twice($x)) }
f main()
  < @four(2+1) != 12
