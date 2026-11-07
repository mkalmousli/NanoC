+ <stdio.h>
$ SQUARE(x) = ((x)*(x))
$ TEXT(x) = #x
$ CAT(a,b) = a##b
$ TEMP = 99
$- TEMP
?+ FIRST
  $ VALUE = 1
:# defined(SECOND)
  $ VALUE = 2
:
  $ VALUE = 3
?- EXPECTED
  $ EXPECTED = 3
?# 0
  !! "inactive error"
f main() -> int
  if VALUE == EXPECTED
    ?# VALUE == 1
      ?- UNUSED
        int item = 1
      :
        int item = 9
    :# VALUE == 2
      double item = 2.0
    :
      long item = 3
    printf("%d %s %d\n", VALUE, TEXT(hello), SQUARE(3))
    return CAT(it,em) != VALUE
  else
    return 1
