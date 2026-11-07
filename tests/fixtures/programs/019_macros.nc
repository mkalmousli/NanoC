@m constant($name:ident,$value:tokens)
  @ct
    id:=quote($name)
    n:=$value
    emit(quote(enum { $$id=$$n };))
@constant(answer,6*7)
f main() -> int = answer!=42
