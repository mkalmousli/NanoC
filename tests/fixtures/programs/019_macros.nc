@macro constant($name:ident,$value:tokens) {
  @ct {
    let id = quote { $name };
    let n = $value;
    emit(quote { enum { $$id = $$n }; });
  }
}
@constant!(answer,6*7)
@fn main()->int { return answer != 42; }
