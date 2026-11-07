@m constant($name:ident,$value:tokens)
  @tt
    id:=quote($name)
    n:=$value
    emit(quote(enum { $$id=$$n };))
@constant(answer,6*7)
f main()
  < answer!=42
